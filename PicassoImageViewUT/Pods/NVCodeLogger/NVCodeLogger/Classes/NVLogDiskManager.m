//
//  NVLogDiskManager.m
//  Nova
//
//  Created by MengWang on 14-12-25.
//  Copyright (c) 2014年 dianping.com. All rights reserved.
//
#import "EXTSelectorChecking.h"
#import "LogReportSwitcher.h"
#import "NVLogDiskManager.h"
#import "TMDiskCache.h"

#import "NSObject+JSON.h"
#include <sys/sysctl.h>
#import "NSData+Logger.h"
#import "Logan.h"
#import "NVMonitorCenter.h"

@interface NVLogDiskManager()

@property (strong, nonatomic) NSArray *localArray;  // 内存中保存的log数组
@property (strong, atomic) NSMutableArray *errorArray;  // 数组来判断断言重复的log
@property (strong, nonatomic) dispatch_queue_t barrierQueue;
@property (assign, nonatomic) NSUInteger maxCount;     // 最大条数限制

@end

@implementation NVLogDiskManager

/**
 *  获取当前类的实例
 */
+ (instancetype)sharedInstance {
    static NVLogDiskManager *gLogDiskManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gLogDiskManager = [[NVLogDiskManager alloc] init];
        gLogDiskManager.barrierQueue = dispatch_queue_create("com.log.barrierQueue", DISPATCH_QUEUE_SERIAL);   //  串行队列
    });
    
    return gLogDiskManager;
}

- (void)setAppID:(NSString *)appID {
    if (_appID == nil) {
        // 初始化LogReportSwitcher需要的参数
        NSDictionary *dic = @{ @"dpid" : [[self params] objectForKey:@"dpid"] ?: @"",
                               @"unionId" :[[self params] objectForKey:@"unionId"] ?: @""};
        [[LogReportSwitcher shareInstance] setAppID:appID defaultParameters:dic];
        
    }
    _appID = appID;
}

- (NSUInteger)maxCount {
    if (_maxCount == 0) {
        _maxCount = [[[self params] objectForKey:@"maxCount"] intValue];
        _maxCount = _maxCount > 2000 ? 2000 : _maxCount;
        if (_maxCount == 0) {
            _maxCount = 2000;   // 默认2000条数据上限
        }
    }
    return _maxCount;
}

/**
 *  初始化
 *
 *  @return 返回
 */
- (id)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@checkselector(self, didEnterBackGround:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**
 *  log日志条数，比如400条数据
 *
 *  @return 返回设定的日志条数
 */
+ (NSInteger)maxCacheCount {
    return (NSInteger)floor((double)[NVLogDiskManager sharedInstance].maxCount / [NVLogDiskManager maxLogKeyCount]);
}

/**
 *  最大的key的数量
 *
 *  @return 返回键的数量
 */
+ (NSInteger)maxLogKeyCount {
    return 5;
}

/**
 *  一条log大小限制,3000字符
 *
 *  @return 返回键的数量
 */
+ (NSInteger)maxLogCount {
    return 3000;
}

/**
 *  存入本地的键
 *
 *  @return 返回键名
 */
+ (NSString *)kNVPrintLogCacheKey {
    return @"kNVPrintLogCacheKey";
}

/**
 *  获取本地保存的keys
 *
 *  @return 返回本地保存的keys数组
 */
+ (NSArray *)logCacheKeys {
    
    NSArray *saveKeyArray = [(NSArray *)[[NSUserDefaults standardUserDefaults] objectForKey:[NVLogDiskManager kNVPrintLogCacheKey]] mutableCopy];
    if (saveKeyArray == nil || saveKeyArray.count == 0) {
        
        // 第一次保存
        saveKeyArray = [[NSArray alloc] init];
        saveKeyArray = [saveKeyArray arrayByAddingObject:[self keyName]];
        
        [[NSUserDefaults standardUserDefaults] setObject:saveKeyArray forKey:[NVLogDiskManager kNVPrintLogCacheKey]];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
        
    return saveKeyArray;
}

+ (NSString *)keyName {
    NSTimeInterval interval = [NSDate date].timeIntervalSince1970;
    NSString *keyName = [NSString stringWithFormat:@"%@", [NSNumber numberWithDouble:(interval * 1000.f)]];
    return keyName;
}

/**
 *  保存log
 *
 *  @param model 对应的数据model
 */
+ (void)cacheLog:(NSDictionary *)model {
dispatch_async([NVLogDiskManager sharedInstance].barrierQueue, ^{
    
    if ([NVLogDiskManager sharedInstance].localArray.count == 0 || [NVLogDiskManager sharedInstance].localArray == nil) {
        NSArray *saveKeyArray = [NVLogDiskManager logCacheKeys];
        NSString *cacheKey = [saveKeyArray lastObject];
        
        //step 1 获取之前的log日志
        NSArray *logArray = (NSArray *)[[self.class cache] objectForKey:cacheKey];
        
        if (logArray.count == 0 || logArray == nil) {
            logArray = [[NSArray alloc] init];
        }
        
        @synchronized (self) {
            [NVLogDiskManager sharedInstance].localArray = [logArray mutableCopy];
        }
    }
   
    if([NVLogDiskManager sharedInstance].localArray.count >= [NVLogDiskManager maxCacheCount]){
        NSArray *saveKeyArray = [NVLogDiskManager logCacheKeys];
        NSString *cacheKey = [saveKeyArray lastObject];
        
        //step 3 当内存中添加满数据，则保存当前的日志数组
        NSArray *copyArray = [NVLogDiskManager sharedInstance].localArray;
        
        [[self.class cache] setObject:copyArray forKey:cacheKey block:^(TMDiskCache *cache, NSString *key, id<NSCoding> object, NSURL *fileURL) { }];
        
        @synchronized (self) {
            [NVLogDiskManager sharedInstance].localArray = [[NSArray alloc] init];
        }
        
        // 条数满了
        if (saveKeyArray.count >= [NVLogDiskManager maxLogKeyCount]) {
            // 如果超过定义的大小，则删除最早的那个key,再添加最新的key来存储
            [[self.class cache] removeObjectForKey:[[saveKeyArray firstObject] copy]];
            
            NSMutableArray *tmpArray = [saveKeyArray mutableCopy];
            [tmpArray removeObjectAtIndex:0];

            saveKeyArray = [[NSArray alloc] init];
            saveKeyArray = [saveKeyArray arrayByAddingObjectsFromArray:tmpArray];
        }
        
        saveKeyArray = [saveKeyArray arrayByAddingObject:[self keyName]];

        [[NSUserDefaults standardUserDefaults] setObject:saveKeyArray forKey:[NVLogDiskManager kNVPrintLogCacheKey]];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    @synchronized (self) {
        [NVLogDiskManager sharedInstance].localArray = [[NVLogDiskManager sharedInstance].localArray arrayByAddingObject:model];
    }
    
});
}

/**
 *  获取当前时间
 *
 *  @return 返回时间戳
 */
+ (NSTimeInterval)currentTime {
    return [[NSDate date] timeIntervalSince1970];
}

/**
 *  返回最大限制的log
 *
 *  @param printLogStr 日志
 */
- (NSString *)printLogMaxStr:(NSString *)printLogStr {
    if (printLogStr.length > [NVLogDiskManager maxLogCount]) {
        printLogStr = [printLogStr substringToIndex:[NVLogDiskManager maxLogCount]];
    }
    return printLogStr;
}

/**
 *  断言打印log
 *
 *  @param printLogStr 要保存的日志 category:聚合的分类 keyWithLog:去重的key(行数和文件名组合)
 */
+ (void)cacheAssertLog:(NSString *)printLogStr withCategory:(NSString *)category withModuleClass:(NSString *)moduleClass withKey:(NSString *)keyWithLog {
    
    if (printLogStr.length == 0) {
        return;
    }
    
    printLogStr = [[NVLogDiskManager sharedInstance] printLogMaxStr:printLogStr];
    
    NSDictionary *logInfoModel = @{@"log" : printLogStr,
                                   @"time": @([NVLogDiskManager currentTime] * 1000),
                                   @"level": @"error",
                                   @"module": moduleClass ? : @"",
                                   @"category" : category ? : @""};
    
    [NVLogDiskManager cacheLog:logInfoModel];   // 错误日志保存本地
    
    //写入日志大管家
    NSDictionary *loganDic = @{@"timestamp" : @([NVLogDiskManager currentTime] * 1000),
                               @"category" : category ? : @"",
                               @"level": @"error",
                               @"log": printLogStr};
    [self writeLogToLogan:loganDic];

    if ([NVLogDiskManager sharedInstance].errorArray == nil) {
        [NVLogDiskManager sharedInstance].errorArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    NSString *unikey = keyWithLog ? : @"";
    // 根据文件名和行数去重,因为log可能不相同
    if ([[NVLogDiskManager sharedInstance].errorArray containsObject:unikey]) {
        // 相同的错误日志，不需要上传
        [[NVMonitorCenter defaultCenter] pvWithCommand:@"codelog.repeat.count" network:0 code:200 tunnel:1 requestBytes:0 responseBytes:0 responseTime:0 ip:nil uploadPercent:100 extend:nil];
        
        return;
    } else {
        [[NVLogDiskManager sharedInstance].errorArray addObject:unikey];
    }
    
    // error日志，直接上报
    NSArray *errorLogArray = @[logInfoModel];
    [[NVLogDiskManager sharedInstance] reportErrorLog:errorLogArray];
 
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AssertLogNotification" object:nil userInfo:nil];
}

/**
 *  打印log字符串
 *
 *  @param printLogStr 要保存的日志 category:聚合的分类
 */
+ (void)cachePrintLog:(NSString *)printLogStr withCategory:(NSString *)category {
     [NVLogDiskManager cachePrintLog:printLogStr withCategory:category andTags:nil];
}

/**
 *  @param printLogStr 要保存的日志 category:聚合的分类 tags:标签（写入logan使用）
 */
+ (void)cachePrintLog:(NSString *)printLogStr withCategory:(NSString *)category andTags:(NSArray<NSString *> *)tags {
    if (printLogStr.length == 0) {
        return;
    }
    
    printLogStr = [[NVLogDiskManager sharedInstance] printLogMaxStr:printLogStr];
    
    NSDictionary *logInfoModel = @{@"log" : printLogStr,
                                   @"time": @([NVLogDiskManager currentTime] * 1000),
                                   @"level": @"normal",
                                   @"category" :category ? : @""};
    
    
    [NVLogDiskManager cacheLog:logInfoModel];  // 保存log
    
    //写入日志大管家
    NSDictionary *loganDic = @{@"timestamp" : @([NVLogDiskManager currentTime] * 1000),
                               @"category" : category ? : @"",
                               @"level": @"normal",
                               @"log": printLogStr};
    [self writeLogToLogan:loganDic withTags:tags];
}

/**
 *  写入日志大管家Logan
 */
+ (void)writeLogToLogan:(NSDictionary *)logDic {
    [NVLogDiskManager writeLogToLogan:logDic withTags:nil];
}

+ (void)writeLogToLogan:(NSDictionary *)logDic withTags:(NSArray<NSString *> *)tags {
    if (!logDic) return;
    
    NSString *jsonString = @"";
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:logDic options:NSJSONWritingPrettyPrinted error:&error];
    if (!jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    if (tags.count > 0) { //带标签
        LLogAndTags(LoganTypeCode, tags, jsonString);
    }else {
         LLog(LoganTypeCode, jsonString);
    }
   
}

/**
 *  本地创建PrintLog
 *
 *  @return
 */
+ (TMDiskCache *)cache {
    static TMDiskCache *cache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[TMDiskCache alloc] initWithName:@"PrintLog"];
    });
    return cache;
}

/**
 *  获取全部日志
 *
 *  @return 全部日志数组
 */
+ (NSMutableArray *)getPrintAllLogs {
    // 根据映射表里面的key，取出对应所有的log日志数组，拼接成一个总的log日志数组
    NSMutableArray *alllogsArray = [[NSMutableArray alloc] initWithCapacity:0];
    __block NSInteger logLength = 0;

    // 逆序遍历
    [[NVLogDiskManager logCacheKeys] enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *keyStop) {
        NSString *datekey = (NSString *)obj;
        
        // 计算log日志大小
        NSArray *logArray = (NSArray *)[[self.class cache] objectForKey:datekey];
        [logArray enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *dic = (NSDictionary *)obj;
            // 判断日志大小
            if(logLength > [NVLogDiskManager maxLogDataCount]){
                *stop = YES;
                *keyStop = YES;
            } else {
                logLength += [dic[@"log"] lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
                [alllogsArray insertObject:dic atIndex:0];  // 始终在0位置添加
            }
        }];
    }];
    
    return alllogsArray;
}


/**
 *  日志大小，比如500k,500k会造成请求时候crash，经试验400k不会导致crash
 */
+ (NSUInteger)maxLogDataCount {
    return 400 * 1024;
}

#pragma mark - Notification

/**
 *  进入后台通知执行事件
 *
 *  @param notifi
 */
- (void)didEnterBackGround:(NSNotification *)notifi {
    if ([NVLogDiskManager sharedInstance].localArray.count > 0) {
        // 有数据，则保存
        NSArray *saveKeyArray = [NVLogDiskManager logCacheKeys];
        NSString *cacheKey = [saveKeyArray lastObject];
        
        NSArray *copyArray = [NVLogDiskManager sharedInstance].localArray;
        [[self.class cache] setObject:copyArray forKey:cacheKey];
    }
    
}

#pragma mark - 接口相关

- (NSString *)hostUrl {
    return @"https://catdot.dianping.com/broker-service/applog";
}

/**
 *  上传错误的log
 */
- (void)reportErrorLog:(NSArray *)errorLogArray {
    if (![[LogReportSwitcher shareInstance] isLogReport:@"codelog"]) {
        return;
    }
    
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
    [paramsDic setObject:[self dicToJsonString:[self customParam]] forKey:@"customParam"];
    [paramsDic setObject:[errorLogArray JSONRepresentation] forKey:@"content"];

    NSURL *url = [NSURL URLWithString:[self hostUrl]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    
    [request setValue:@"gzip" forHTTPHeaderField:@"Content-Encoding"];
    [request setHTTPBody:[[[self dicToJsonString:paramsDic] dataUsingEncoding:NSUTF8StringEncoding] encodeGZip]];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
    completionHandler:^(NSData * _Nullable data,
                        NSURLResponse * _Nullable response,
                        NSError * _Nullable error) {
        if((!error) && ([(NSHTTPURLResponse *)response statusCode] == 200)) {
            NSLog(@"----------errorlog uploaded!");
        } else {
            NSLog(@"----------errorlog upload failed!");
        }
    }];
    [task resume];
}

- (NSString *)version {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

// 品牌信息
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

- (NSDictionary *)customParam {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:self.appID ? : @"" forKey:@"appId"];
    [params setObject:[self version] forKey:@"appVersion"];
    [params setObject:[self deviceModel] forKey:@"deviceBrand"];
    [params setObject:[[UIDevice currentDevice] systemVersion] forKey:@"platVersion"];
    [params setObject:[self platformString] forKey:@"deviceModel"];
    [params setObject:[[self params] objectForKey:@"unionId"] ? : @"" forKey:@"unionId"];
    [params setObject:[[self params] objectForKey:@"dpid"] ? : @"" forKey:@"dpid"];
    [params setObject:@"ios" forKey:@"platform"];
    return params;
}

// 字典转换成json
- (NSString*)dicToJsonString:(NSDictionary *)dic {
    NSString *jsonString = @"";
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    if (!jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}

#pragma mark - 查询日志相关

- (void)queryLogs:(NSUInteger)count withBlock:(void(^)(NSArray *))block {
    dispatch_async([NVLogDiskManager sharedInstance].barrierQueue, ^{
        if (count == 0) return;
        NSArray *alllogsArray = [self queryLogs:count];
        if (block) {
            block(alllogsArray);
        }
    });
}

- (NSArray *)querySyncLogs:(NSUInteger)count {
    if (count == 0) return nil;
    return [self queryLogs:count];
}

- (NSArray *)queryLogs:(NSUInteger)count {
    if ([NVLogDiskManager sharedInstance].localArray.count > 0) {
        // 有数据，则保存
        NSArray *saveKeyArray = [NVLogDiskManager logCacheKeys];
        NSString *cacheKey = [saveKeyArray lastObject];
        
        NSArray *copyArray = [NVLogDiskManager sharedInstance].localArray;
        [[self.class cache] setObject:copyArray forKey:cacheKey];
    }
    
    NSUInteger number = count > [NVLogDiskManager sharedInstance].maxCount ? [NVLogDiskManager sharedInstance].maxCount : count;
    
    NSMutableArray *alllogsArray = [[NSMutableArray alloc] initWithCapacity:0];
    // 逆序遍历
    [[NVLogDiskManager logCacheKeys] enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *keyStop) {
        NSString *datekey = (NSString *)obj;
        
        // 计算log日志大小
        NSArray *logArray = (NSArray *)[[self.class cache] objectForKey:datekey];
        [logArray enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *dic = (NSDictionary *)obj;
            // 判断日志大小
            if(alllogsArray.count >= number){
                *stop = YES;
                *keyStop = YES;
            } else {
                [alllogsArray insertObject:dic atIndex:0];  // 始终在0位置添加
            }
        }];
    }];
    return alllogsArray;
}

- (NSDictionary *)params {
    if ([NVLogDiskManager sharedInstance].loggerParams) {
        return [NVLogDiskManager sharedInstance].loggerParams();
    } else {
#ifdef DEBUG
        NSAssert(NO, @"必须初始化NVLogger的installWithAppID方法！！！设置dpid或者unionId");
#endif
        return @{};
    }
}

@end
