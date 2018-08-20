//
//  LogReportSwitcher.m
//  Pods
//
//  Created by lmc on 16/6/1.
//
//
#import "LogReportSwitcher.h"
#import "SwitcherTask.h"
#include <sys/sysctl.h>
#include <zlib.h>
#import "LogReportSwitchModel.h"

NSNotificationName const SwitcherConfigChangedNotification = @"SwitcherConfigChangedNotification";

#define SWITCHSERVERRETURNRESULTDATA    @"SWITCHSERVERRETURNRESULTDATA"
#define SWITCHDATATIMESTAMP             @"SWITCHDATATIMESTAMP"
#define SWITCHSERVERRETURNINTERAL       @"SWITCHSERVERRETURNINTERAL"
#define SWITCHAPPVERSISON               @"SWITCHAPPVERSISON"
#define SWITCHDEFAULTREQUESTINTERAL     5*60
#define SWITCHMAXREQUESTINTERAL         24*60*60

BOOL DoubleEqualCheck(double A,double B){
    return fabs(A-B)<DBL_EPSILON?YES:NO;
}

@interface LogReportSwitcher () <NSURLSessionDataDelegate,NSURLSessionTaskDelegate>

@property (nonatomic, strong) NSUserDefaults *switchUserDefault;
@property (atomic, strong) NSString *appIDStr;
@property (atomic, strong) NSDictionary *parametersDic;
@property (atomic, assign) __block BOOL haveRequest;
@property (nonatomic, copy) HertzConfigBlock hertzConfigBlock;
@property (atomic, strong) NSDictionary *switchTypeDic; //type数组组装新的Dic
@property (atomic, assign) BOOL isBeta;

@end

@implementation LogReportSwitcher {
    LogReportSwitchModel *_switchModel;
    NSArray *_sampleRateArray;
    NSDictionary *_hertzDic;
    NSString *_configVersion;
    NSArray *_loganConfigs;
    
    SwitcherConfigBlock _configBlock;
}

+ (instancetype)shareInstance {
    static LogReportSwitcher *logReportSwitcher;
    static dispatch_once_t onceFlag;
    dispatch_once(&onceFlag, ^{
        logReportSwitcher = [LogReportSwitcher new];
    });
    return logReportSwitcher;
}

- (void)setupIsBeta:(BOOL)beta{
    self.isBeta = beta;
}

- (id)init {
    self = [super init];
    if (self) {
        if (!_switchUserDefault) {
            _switchUserDefault = [[NSUserDefaults alloc] initWithSuiteName:@"LogReportSwitch"];
        }
        NSDictionary *resultDic = [_switchUserDefault objectForKey:SWITCHSERVERRETURNRESULTDATA];
        NSString *appVersion = [_switchUserDefault objectForKey:SWITCHAPPVERSISON];
        BOOL sameVersion = YES;
        if (appVersion.length > 0 && ![appVersion isEqualToString:[self appVersion]]) {
            [self clearCache];
            sameVersion = NO;
        }
        
        if (resultDic && sameVersion) {
            [self fillContent:resultDic checkVersion:NO];
        } else {
            _switchModel = nil;
            _configVersion = @"0";
            _switchTypeDic = [NSDictionary new];
            _sampleRateArray = [NSArray new];
            _hertzDic = nil;
            _loganConfigs = [NSArray array];
        }
        _haveRequest = NO;
    }
    
    return self;
}

- (void)fillContent:(NSDictionary *)resultDic checkVersion:(BOOL)isCheck{
    @synchronized (self) {
        // 数据类型转换
        _switchModel = [LogReportSwitchModel modelWithJSONDictionary:resultDic];
        
        // 版本
        NSString *str = [_switchModel configVersion];
        
        if (![str isKindOfClass:[NSString class]] || str.length<1) {
            _configVersion = @"0";
        } else {
            if (isCheck && _configVersion.length > 0) {
                if ([str longLongValue] < [_configVersion longLongValue]) {
                    return;
                }
            }
            _configVersion = str;
        }
        // 获得所有开关数值
        [self __typeArrayPackageNewDic:_switchModel.types];
        
        // 设置采样率
        if (_switchModel.sampleConfig) {
            _sampleRateArray = [SwitchSampleConfig JSONDicArray:_switchModel.sampleConfig];
        } else {
            _sampleRateArray = [NSArray new];
        }
        
        // 获得测速配置
        _hertzDic = @{@"hertz" : [SwitchHertz JSONDicArray:_switchModel.hertz]};
        // 测速配置callback
        if (self.hertzConfigBlock && _switchModel.hertz) {
            self.hertzConfigBlock(_hertzDic);
        }
        
        // 获得Logan配置
        _loganConfigs = [resultDic objectForKey:@"appProperties"];
        if (!_loganConfigs) {
            _loganConfigs = [NSArray array];
        }
        
        //服务下发的请求间隔
        for (SwitchProperty *switchProperty in _switchModel.appProperties) {
            if ([switchProperty.configId isEqualToString:@"req_interval"]) {
                if ([switchProperty.content doubleValue] > 0) {
                    [self.switchUserDefault setObject:switchProperty.content forKey:SWITCHSERVERRETURNINTERAL];
                }
                break;
            }
        }
    }
}

- (void)__typeArrayPackageNewDic:(NSArray *)typesArray {
    // 获得所有的配置开关
    if (!typesArray || typesArray.count <= 0) {
        self.switchTypeDic = [NSDictionary new];
        return;
    }
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    for (SwitchTypes *types in typesArray) {
        NSString *uidStr = types.uid;
        NSNumber *value = types.enable;
        
        [dic setValue:value forKey:uidStr];
    }
    
    self.switchTypeDic = [NSDictionary dictionaryWithDictionary:dic];
}

- (NSString *)configVersion {
    @synchronized (self) {
        return _configVersion;
    }
}

- (void)setAppID:(NSString *)appid defaultParameters:(NSDictionary *)parameters {
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self initOnlyOnceCheck:appid defaultParameters:(NSDictionary *)parameters];
        });
    }else {
        [self initOnlyOnceCheck:appid defaultParameters:(NSDictionary *)parameters];
    }
}

- (void)initOnlyOnceCheck:(NSString *)appid defaultParameters:(NSDictionary *)parameters{
    if (self.appIDStr.length != 0) {
        return;
    }
    
    self.appIDStr = appid;
    if (!self.parametersDic) {
        self.parametersDic = parameters;
    }
    
    [self checkIsFetchServerData:self.appIDStr];
}

- (BOOL)checkTimeStamp {
    BOOL timeOut = NO;
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    
    NSTimeInterval lastFetchTime = [(NSNumber *)[self.switchUserDefault objectForKey:SWITCHDATATIMESTAMP] doubleValue];
    NSNumber *serverReturnInterval = [self.switchUserDefault objectForKey:SWITCHSERVERRETURNINTERAL];
    
    if (serverReturnInterval) {
        NSTimeInterval serverReturnTime = MIN([serverReturnInterval doubleValue], SWITCHMAXREQUESTINTERAL);
        
        if (now - lastFetchTime > serverReturnTime) {
            timeOut = YES;
        }
    }else {
        if (DoubleEqualCheck(lastFetchTime, 0)) {
            timeOut = YES;
        }else{
            if (now - lastFetchTime > SWITCHDEFAULTREQUESTINTERAL) {
                timeOut = YES;
            }
        }
    }
    
    return timeOut;
}

- (void)checkIsFetchServerData:(NSString *)appid {
    if ([[self.switchTypeDic objectForKey:@"base"] boolValue]) {
        // cat开关打开，会从cat中返回配置。不需要进行网络请求
        return;
    }
    if ([self checkTimeStamp]) {
        if (!self.haveRequest) {
            [self requestReportResultWithAppID:appid];
        }
    }
}

#pragma mark - 采样率

- (NSArray *)getSampleRateArray {
    @synchronized (self) {
        return _sampleRateArray;
    }
}

#pragma mark - 测速配置

- (void)getHertzConfig:(HertzConfigBlock)config {
    self.hertzConfigBlock = config;
    
    @synchronized (self) {
        if (config && _switchModel.hertz && _hertzDic) {
            self.hertzConfigBlock(_hertzDic);
        }
    }
}

#pragma mark - 日志上报

- (BOOL)isLogReport:(NSString *)logType {
    return [self isLogReport:logType defaultValue:YES];
}

- (BOOL)isLogReport:(NSString *)logType defaultValue:(BOOL)value {
    
    if (logType.length == 0) {
        return value;
    }
    
    [self checkIsFetchServerData:self.appIDStr];
    
    @synchronized (self) {
        if (!self.switchTypeDic) {
            return value;
        }
        
        NSNumber *obj = [self.switchTypeDic objectForKey:logType];
        if (!obj || ![obj isKindOfClass:[NSNumber class]]) {
            return value;
        }
        
        return [obj boolValue];
    }
}

#pragma mark - 获取日志大管家Logan配置信息

- (NSArray *)getLoganConfig {
    @synchronized (self) {
        return _loganConfigs;
    }
}

#pragma mark - request data

- (NSString *)serverURL {
    if (self.isBeta) {
        return @"https://catdot.51ping.com/broker-service/api/config";
    }else{
        return @"https://catdot.dianping.com/broker-service/api/config";
    }
//    return @"http://10.72.254.63:8080/broker-service/api/config";
}

- (void)requestReportResultWithAppID:(NSString *)appid {
    if (appid.length == 0) return;
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?op=all&v=3&appId=%@&appVersion=%@&compress=%@",[self serverURL],appid,[self appVersion],@"true"];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:self.parametersDic];
    [dic setValue:[self appVersion]  forKey:@"appVersion"];
    [dic setValue:[self isDebug] ? @"1" : @"0" forKey:@"debug"];
    [dic setValue:[[UIDevice currentDevice] systemVersion] forKey:@"platVersion"];
    [dic setValue:[self deviceModel] forKey:@"deviceBrand"];
    [dic setValue:[self platformString] forKey:@"deviceModel"];
    [dic setValue:@"iOS" forKey:@"platform"];
    
    self.haveRequest = YES;
    
    SwitcherTask *switcherTask = [SwitcherTask task];
    switcherTask.url = urlStr;
    switcherTask.parameters = [NSDictionary dictionaryWithDictionary:dic];
    
    __weak typeof(self) weakSelf = self;
    switcherTask.success = ^(SwitcherTask *task, id result) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.haveRequest = NO;
        if(![NSThread isMainThread]){
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf handleConfigData:result from:SwitcherConfigFromHttp];
            });
        }else {
            [strongSelf handleConfigData:result from:SwitcherConfigFromHttp];
        }
    };
    
    switcherTask.fail = ^(SwitcherTask *task, id error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.haveRequest = NO;
        NSLog(@"log report switch response fail");
    };
    
    // 发起请求
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [switcherTask startRequest];
        });
    }else {
        [switcherTask startRequest];
    }
}

- (void)handleConfigData:(NSData *)result from:(SwitcherConfigFrom)from {
    NSData *decodeData = [self decodeGzip:result];
    if (decodeData.length) {
        NSError *error = nil;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:decodeData options:NSJSONReadingAllowFragments error:&error];
        
        if (error) {
            NSLog(@"%@",error);
            return;
        }
        
        if (dic.allKeys.count > 0) {
            [self.switchUserDefault setObject:@([[NSDate date] timeIntervalSince1970]) forKey:SWITCHDATATIMESTAMP];
            [self.switchUserDefault setObject:dic forKey:SWITCHSERVERRETURNRESULTDATA];
            [self.switchUserDefault setObject:[self appVersion] forKey:SWITCHAPPVERSISON];
            [self fillContent:dic checkVersion:YES];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:SwitcherConfigChangedNotification object:nil];
            
            if (_configBlock) {
                NSString *str = [[NSString alloc] initWithData:decodeData encoding:NSUTF8StringEncoding];
                _configBlock(from, str);
            }
        }
    }
}

- (void)clearCache{
    [self.switchUserDefault removeObjectForKey:SWITCHDATATIMESTAMP];
    [self.switchUserDefault removeObjectForKey:SWITCHSERVERRETURNRESULTDATA];
    [self.switchUserDefault removeObjectForKey:SWITCHAPPVERSISON];
}

- (BOOL)isDebug {
    BOOL isdebug;
#ifdef DEBUG
    isdebug = YES;
#else
    isdebug = NO;
#endif
    
    return isdebug;
}

#pragma mark - decode Gzip

- (NSData *)decodeGzip:(NSData *)zipData {
    if ([zipData length] == 0) return nil;
    
    unsigned full_length = (unsigned int)[zipData length];
    unsigned half_length = (unsigned int)[zipData length] / 2;
    
    NSMutableData *decompressed = [NSMutableData dataWithLength: full_length + half_length];
    BOOL done = NO;
    int status;
    
    z_stream strm;
    strm.next_in = (Bytef *)[zipData bytes];
    strm.avail_in = (uInt)[zipData length];
    strm.total_out = 0;
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    
    if (inflateInit2(&strm, (15+32)) != Z_OK) return nil;
    while (!done)
    {
        // Make sure we have enough room and reset the lengths.
        if (strm.total_out >= [decompressed length])
        [decompressed increaseLengthBy: half_length];
        strm.next_out = [decompressed mutableBytes] + strm.total_out;
        strm.avail_out = (uInt)([decompressed length] - strm.total_out);
        
        // Inflate another chunk.
        status = inflate (&strm, Z_SYNC_FLUSH);
        if (status == Z_STREAM_END) done = YES;
        else if (status != Z_OK) break;
    }
    if (inflateEnd (&strm) != Z_OK) return nil;
    
    // Set real length.
    if (done)
    {
        [decompressed setLength: strm.total_out];
        return [NSData dataWithData: decompressed];
    }
    else return nil;
}

#pragma mark - header parameter


- (NSString *)appVersion {
    NSString * build = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    if (build.length > 0) {
        return [build stringByReplacingOccurrencesOfString:@"." withString:@""];
    }else{
        return @"";
    }
}

- (NSString *)deviceModel {
    NSString *modelName = [[UIDevice currentDevice] model];
    if([modelName hasPrefix:@"iPhone"])
        return @"iPhone";
    else if([modelName hasPrefix:@"iPod"])
        return @"iPod";
    else if([modelName hasPrefix:@"iPad"])
        return @"iPad";
    return @"iOS";
}

- (NSString *)platformString{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    
    return platform;
}

- (void)handleCatResponse:(NSData *)data {
    if (data.length<1) {
        return;
    }
    
    {// 尝试检查数据是否是字符串
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (str.length>0) {
            // 服务端返回的string数据；非配置数据
            return;
        }
    }
    
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handleConfigData:data from:SwitcherConfigFromCat];
        });
    }else {
        [self handleConfigData:data from:SwitcherConfigFromCat];
    }
}

- (void)setSwitcherConfigBlock:(SwitcherConfigBlock)block {
    _configBlock = block;
}

@end
