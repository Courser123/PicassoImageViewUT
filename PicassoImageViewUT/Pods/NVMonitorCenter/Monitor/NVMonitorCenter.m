//
//  NVMonitorCenter.m
//  MonitorDemo
//
//  Created by ZhouHui on 16/1/12.
//  Copyright © 2016年 dianping. All rights reserved.
//

#import "NVMonitorCenter.h"
#import <sys/time.h>
#import <UIKit/UIKit.h>
#import "NVNetworkReachability.h"
#import "LogReportSwitcher.h"
#import "NSData+mcGzipHelper.h"
#include <sys/sysctl.h>
#import "NVDNSMonitor.h"
#import "NVCrashMonitor.h"
#import "NVSpeedMonitor.h"
#import "Logan.h"

#define kCatVersion 4
#define NVMonitorCenterQueueSize 15

BOOL DoubleEqual(double A,double B){
    return fabs(A-B)<DBL_EPSILON?YES:NO;
}

BOOL NVMONITORDEBUG = NO;

@interface NVMonitorCenter ()

@property (nonatomic, assign) NSInteger   versionCode;
@property (nonatomic, retain) NSThread    *thread;
@property (nonatomic, retain) NSCondition *condition;
@property (nonatomic, assign) BOOL        stop;
@property (nonatomic, assign) BOOL        force;
@property (nonatomic, assign) BOOL        isBeta;

@end

@implementation NVMonitorCenter {
    NSURL *_serverURL;
    NSURL *_failoverURL;
    NSMutableArray *_buffer;
    NSMutableArray *_pvBuffer;
    UnionIDBlock _unionIdBlock;
    int _appID;
}

+ (instancetype)defaultCenter {
    static NVMonitorCenter *gCenter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gCenter = [NVMonitorCenter new];
    });
    return gCenter;
}

+ (void)isDebug:(BOOL)isDebug{
    NVMONITORDEBUG = isDebug;
}

- (id)init {
    self = [super init];
    if (self) {
//        _host = @"broker-service01.beta";
        self.versionCode = [self getVersionCode];
        _thread = [[NSThread alloc] initWithTarget:self selector:@selector(run) object:nil];
        _condition = [[NSCondition alloc] init];
        _buffer = [NSMutableArray arrayWithCapacity:16];
        _pvBuffer = [NSMutableArray array];
        [_thread start];
        
        [[LogReportSwitcher shareInstance] setSwitcherConfigBlock:^(SwitcherConfigFrom from, NSString *config) {
            LLog(LoganTypeLogan, [NSString stringWithFormat:@"%@%@", (from==SwitcherConfigFromCat)?@"[CONFIG FROM CAT]":@"[CONFIG FROM HTTP]", config]);
        }];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
    }
    return self;
}


- (void)applicationDidEnterBackground:(NSNotification *)n {
    @try {
        // 统计数据立即上传
        [self flush];
    }
    @catch (NSException *exception) {
        LLog(LoganTypeLogan, [NSString stringWithFormat:@"[Cat]applicationDidEnterBackground, forceUpload occured exception: %@", exception]);
    }
}

- (void)applicationWillTerminate:(NSNotification *)n {
    @try {
        // 统计数据立即上传
        [self flush];
    }
    @catch (NSException *exception) {
        LLog(LoganTypeLogan, [NSString stringWithFormat:@"[Cat]applicationWillTerminate, forceUpload occured exception: %@", exception]);
    }
}

- (void)setServerUrl:(NSString *)url {
    if (url.length<1) {
        _serverURL = nil;
    } else {
        _serverURL = [NSURL URLWithString:url];
    }
}

- (void)setFailoverURL:(NSString *)url {
    if (url.length<1) {
        _failoverURL = nil;
    } else {
        _failoverURL = [NSURL URLWithString:url];
    }
}

-(NSString *)serverHost{
    
    if (self.isBeta) {
        return @"catdot.51ping.com";
    }else{
        return @"catdot.dianping.com";
    }
}

- (void)setupIsBeta:(BOOL)beta{
    self.isBeta = beta;
}
//让sdk使用者无感知，不需修改，取消设置host功能，sdk直接内置
-(void)setServerHost:(NSString *)host{

}

- (void)setAppID:(int)p{
    _appID = p;
    [self initLogSwitch];
}


- (void)initLogSwitch{
    if (!_appID || !_unionIdBlock) {
        return;
    }
    [self performSelectorOnMainThread:@selector(setLogReport) withObject:nil waitUntilDone:NO];
}

- (void)setLogReport{
    NSString *unionID = [self getUnionId];
    if (![unionID isKindOfClass:[NSString class]] || unionID.length == 0) {
        unionID = @"";
    }
    [[LogReportSwitcher shareInstance] setAppID:@(_appID).stringValue  defaultParameters:@{@"unionId":unionID}];
}

- (int)appID{
    return _appID;
}
// 6.8 = 68, 6.8.5 = 685, 6.13.3 = 6133
- (NSInteger)getVersionCode {
    NSString * build = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    if (build.length > 0) {
        NSString *version = [build stringByReplacingOccurrencesOfString:@"." withString:@""];
        return [version integerValue];
    }else{
        return 0;
    }
}

- (NSString *)commandWithUrl:(NSString *)url {
    if(!url)
        return @"";
    NSURL *commandUrl = [NSURL URLWithString:url];
    NSString *command = [NSString stringWithFormat:@"%@%@",commandUrl.host,commandUrl.path];
    
    return command?:@"";
}

- (void)pvWithCommand:(NSString *)cmd network:(int)network code:(int)code requestBytes:(int)reqBytes responseBytes:(int)respBytes responseTime:(int)respTime {
    [self pvWithCommand:cmd network:network code:code tunnel:0 requestBytes:reqBytes responseBytes:respBytes responseTime:respTime ip:nil uploadPercent:100];
}

- (void)pvWithCommand:(NSString *)cmd network:(int)network code:(int)code requestBytes:(int)reqBytes responseBytes:(int)respBytes responseTime:(int)respTime ip:(NSString *)ip {
    [self pvWithCommand:cmd network:network code:code tunnel:0 requestBytes:reqBytes responseBytes:respBytes responseTime:respTime ip:ip uploadPercent:100];
}

- (void)pvWithCommand:(NSString *)cmd network:(int)network code:(int)code tunnel:(int)tunnel requestBytes:(int)reqBytes responseBytes:(int)respBytes responseTime:(int)respTime ip:(NSString *)ip {
    [self pvWithCommand:cmd network:network code:code tunnel:tunnel requestBytes:reqBytes responseBytes:respBytes responseTime:respTime ip:ip uploadPercent:100];
}

- (void)pvWithCommand:(NSString *)cmd network:(int)network code:(int)code tunnel:(int)tunnel requestBytes:(int)reqBytes responseBytes:(int)respBytes responseTime:(int)respTime ip:(NSString *)ip uploadPercent:(int)uploadPercent {
    [self pvWithCommand:cmd network:network code:code tunnel:tunnel requestBytes:reqBytes responseBytes:respBytes responseTime:respTime ip:ip uploadPercent:uploadPercent extend:nil];
}

- (float)getUploadSample:(NSString *)cmd{
    NSArray *cmdArr = [[LogReportSwitcher shareInstance] getSampleRateArray];
    NSString *lowerCmd = [cmd lowercaseString];
    if (!lowerCmd) {
        return -1;
    }
    for (NSDictionary *dic in cmdArr) {
        if ([(NSString *)[dic objectForKey:@"id"] hasPrefix:lowerCmd]) {
             return ((NSString *)[dic objectForKey:@"sample"]).floatValue;
        }
    }
    return -1;
}

- (void)pvWithCommand:(NSString *)cmd network:(int)network code:(int)code tunnel:(int)tunnel requestBytes:(int)reqBytes responseBytes:(int)respBytes responseTime:(int)respTime ip:(NSString *)ip uploadSample:(float)uploadSample extend:(NSString *)extend {
    
    BOOL isReport =  [[LogReportSwitcher shareInstance] isLogReport:@"base"];
    if (!isReport) return;
    
    NSMutableString *pv = [NSMutableString string];
    
    [pv appendFormat:@"%lld\t", (int64_t)([[NSDate date] timeIntervalSince1970] * 1000.0)];
    
    if(!network) {
        NVNetworkReachability re = NVGetAccurateNetworkReachability();
        switch (re) {
            case NVNetworkReachabilityWifi:
                network = 1;
                break;
            case NVNetworkReachabilityMobile2G:
                network = 2;
                break;
            case NVNetworkReachabilityMobile3G:
                network = 3;
                break;
            case NVNetworkReachabilityMobile4G:
                network = 4;
                break;
            default:
                network = 0;
                break;
        }
    }
    [pv appendFormat:@"%d\t", network];
    
    [pv appendFormat:@"%@\t", @(self.versionCode)];
    
    [pv appendFormat:@"%d\t", tunnel]; // tunnel
    
    [pv appendFormat:@"%@\t", [self urlEncode:cmd]];
    
    [pv appendFormat:@"%d\t", code];
    
    [pv appendString:@"2\t"]; // ios
    
    [pv appendFormat:@"%d\t", reqBytes];
    
    [pv appendFormat:@"%d\t", respBytes];
    
    [pv appendFormat:@"%d\t", respTime];
    
    [pv appendFormat:@"%@\t", ip?:@""];//为空的时候传空值
    
    [pv appendFormat:@"%@\t",[[UIDevice currentDevice] systemVersion]];
    
    [pv appendFormat:@"%@", extend?:@""];//为空的时候传空值
    
    float tempSample = [self getUploadSample:cmd];
    if (tempSample > -1) {
        uploadSample = tempSample;
    }
    uint32_t random = arc4random_uniform(1000000);
    if (uploadSample <= 0.0f || (uploadSample < 1.0f && random >= (uploadSample*1000000))) {
        // 不上传，但记录到logan中
        NSString *log = [NSString stringWithFormat:@"[noupload]%@", pv];
        LLog(LoganTypeCat, log);
        return;
    } else {
        // 记录到logan中
        LLog(LoganTypeCat, pv);
    }
    
    NSUInteger n = 0;
    @synchronized (_buffer) {
        n = _buffer.count;
        [_buffer addObject:pv];
    }
    
    if (NVMONITORDEBUG) {
        NSLog(@"CAT: %@", pv);
    }
    
    if (n == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSelector:@selector(uploadNow) withObject:nil afterDelay:15];
        });
    } else if(n > (NVMonitorCenterQueueSize - 2)) {//宏定义
        dispatch_async(dispatch_get_main_queue(), ^{
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(uploadNow) object:nil];
        });
        [self uploadNow];
    }
}

- (void)pvWithCommand:(NSString *)cmd network:(int)network code:(int)code tunnel:(int)tunnel requestBytes:(int)reqBytes responseBytes:(int)respBytes responseTime:(int)respTime ip:(NSString *)ip uploadPercent:(int)uploadPercent extend:(NSString *)extend{

    [self pvWithCommand:cmd network:network code:code tunnel:tunnel requestBytes:reqBytes responseBytes:respBytes responseTime:respTime ip:ip uploadSample:uploadPercent/100.0f extend:extend];
}

- (int)networkStatus {
    int network = 0;
    NVNetworkReachability re = NVGetAccurateNetworkReachability();
    switch (re) {
        case NVNetworkReachabilityWifi:
            network = 1;
            break;
        case NVNetworkReachabilityMobile2G:
            network = 2;
            break;
        case NVNetworkReachabilityMobile3G:
            network = 3;
            break;
        case NVNetworkReachabilityMobile4G:
            network = 4;
            break;
        default:
            network = 0;
            break;
    }
    return network;
}

- (void)catWithUrl:(NSString *)url
         originUrl:(NSString *)originUrl
               cmd:(NSString *)cmd
            method:(NSString *)method
     requestHeader:(NSDictionary *)requestHeader
      requestBytes:(long)requestBytes
      responseTime:(int)respTime
        statusCode:(NSInteger)statusCode
    responseHeader:(NSDictionary *)responseHeader
     responseBytes:(long)responseBytes
      uploadSample:(float)uploadSample
            tunnel:(int)tunnel
         subTunnel:(int)subTunnel
                ip:(NSString *)ip
       sharkStatus:(NSString *)sharkStatus
            extend:(NSString *)extend
             extra:(NSString *)extra {
    BOOL isReport =  [[LogReportSwitcher shareInstance] isLogReport:@"base"];
    if (!isReport) return;
    
    if (cmd.length<1) {
        cmd = [self commandWithUrl:url];
    }
    NSMutableString *pv = [NSMutableString string];
    
    [pv appendFormat:@"%lld\t", (int64_t)([[NSDate date] timeIntervalSince1970] * 1000.0)];
    
    [pv appendFormat:@"%d\t", [self networkStatus]];
    [pv appendFormat:@"%@\t", @(self.versionCode)];
    [pv appendFormat:@"%d\t", tunnel]; // tunnel
    [pv appendFormat:@"%@\t", [self urlEncode:cmd]];
    [pv appendFormat:@"%d\t", (int)statusCode];
    [pv appendString:@"2\t"]; // ios
    [pv appendFormat:@"%ld\t", requestBytes];
    [pv appendFormat:@"%ld\t", responseBytes];
    [pv appendFormat:@"%d\t", respTime];
    [pv appendFormat:@"%@\t", ip?:@""];//为空的时候传空值
    [pv appendFormat:@"%@\t",[[UIDevice currentDevice] systemVersion]];
    [pv appendFormat:@"%@", extend?:@""];//为空的时候传空值
    
    BOOL uploadCat = YES;
    float tempSample = [self getUploadSample:cmd];
    if (tempSample > -1) {
        uploadSample = tempSample;
    }
    uint32_t random = arc4random_uniform(1000000);
    if (uploadSample <= 0.0f || (uploadSample < 1.0f && random >= (uploadSample*1000000))) {
        // 不上传
        uploadCat = NO;
    }
    
    // 记录到Logan中
    {
        NSMutableDictionary *recordDic = [NSMutableDictionary new];
        if (url.length>0) {
            [recordDic setObject:url forKey:@"a"];
        }
        if (originUrl.length>0) {
            [recordDic setObject:originUrl forKey:@"b"];
        }
        [recordDic setObject:cmd forKey:@"c"];
        if (method.length>0) {
            [recordDic setObject:method forKey:@"d"];
        }
        NSString *headerString = nil;
        if (requestHeader) {
            NSData *data = [NSJSONSerialization dataWithJSONObject:requestHeader options:0 error:NULL];
            if (data) {
                headerString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                if (headerString.length>0) {
                    [recordDic setObject:headerString forKey:@"e"];
                }
            }
        }
        [recordDic setObject:@(requestBytes) forKey:@"f"];
        [recordDic setObject:@([self networkStatus]) forKey:@"g"];
        [recordDic setObject:@(respTime) forKey:@"h"];
        [recordDic setObject:@(statusCode) forKey:@"i"];
        if (responseHeader) {
            NSData *data = [NSJSONSerialization dataWithJSONObject:responseHeader options:0 error:NULL];
            if (data) {
                headerString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                if (headerString.length>0) {
                    [recordDic setObject:headerString forKey:@"j"];
                }
            }
        }
        [recordDic setObject:@(responseBytes) forKey:@"k"];
        [recordDic setObject:@(tunnel) forKey:@"l"];
        [recordDic setObject:@(subTunnel) forKey:@"m"];
        if (ip.length>0) {
            [recordDic setObject:ip forKey:@"n"];
        }
        if (sharkStatus.length>0) {
            [recordDic setObject:sharkStatus forKey:@"o"];
        }
        if (extend.length>0) {
            [recordDic setObject:extend forKey:@"p"];
        }
        if (extra.length>0) {
            [recordDic setObject:extra forKey:@"q"];
        }
        if (uploadCat) {
            [recordDic setObject:pv forKey:@"r"];
        }
        
        NSError *erro = nil;
        NSData *recordData = [NSJSONSerialization dataWithJSONObject:recordDic options:0 error:&erro];
        if(!recordData){
            return;
        }
        NSString *recordStr = [[NSString alloc] initWithData:recordData encoding:NSUTF8StringEncoding];
        if(!recordStr){
            return;
        }
        LLog(LoganTypeCat, recordStr);
    }
    
    if (!uploadCat) {
        return;
    }
    
    // 后续是上报流程
    NSUInteger n = 0;
    @synchronized (_buffer) {
        n = _buffer.count;
        [_buffer addObject:pv];
    }
    
    if (n == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSelector:@selector(uploadNow) withObject:nil afterDelay:15];
        });
    } else if(n > (NVMonitorCenterQueueSize - 2)) {//宏定义
        dispatch_async(dispatch_get_main_queue(), ^{
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(uploadNow) object:nil];
        });
        [self uploadNow];
    }
}

- (void)uploadNow {
    @synchronized (_buffer) {
        if (_buffer.count > 0) {
            NSMutableArray *pvArr = [NSMutableArray arrayWithArray:_buffer];
                @synchronized (_pvBuffer) {
                    [_pvBuffer addObject:pvArr];
                }
                [_buffer removeAllObjects];
        }
    }
    [_condition signal];
}

- (void)flush {
    [_condition lock];
    _force = YES;
    [_condition signal];
    [_condition unlock];
}

- (NSString *)getUnionId {
    if (_unionIdBlock) {
        NSString *unionId = _unionIdBlock();
        if (unionId == nil || ![unionId isKindOfClass:[NSString class]]) {
            return @"";
        } else {
            return unionId;
        }
    } else {
        return @"";
    }
}

- (void)setUnionIdBlock:(UnionIDBlock)block {
    if (_unionIdBlock != block) {
        _unionIdBlock = block;
        [self initLogSwitch];
    }
}

- (void)setDNSDuration:(NSInteger)duration{
    if (duration > 0) {
        [[NVDNSMonitor defaultMonitor] setDNSDuration:duration];
    }
}

- (void)setCrashMonitorTimes:(NSInteger)times{
    if (times > 0) {
        [[NVCrashMonitor defaultMonitor] setCrashTimes:times];
    }
}

- (NSString *)urlEncode:(NSString *)url {
    if (![url length]) return @"";
    CFStringRef static const charsToEscape = CFSTR("!*'();:@&=+$,/?%#[]");
    CFStringRef escapedString = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                        (__bridge CFStringRef)url,
                                                                        NULL,
                                                                        charsToEscape,
                                                                        kCFStringEncodingUTF8);
    return (__bridge_transfer NSString *)escapedString;
}

- (void)run {
    while (!_stop) {
        @autoreleasepool {
            [_condition lock];
            while(!_force && _pvBuffer.count == 0) {
                [_condition wait];
            }
            [_condition unlock];
            if(_stop)
                return;
            _force = NO;
            
            NSAssert(_appID, @"请先设置appid");
            NSAssert(_unionIdBlock, @"请先设置unionId");
            NSInteger lines = 0;
            NSMutableString *body =_failoverURL ? [NSMutableString stringWithFormat:@"v=%d&p=%d&dpid=%@&c=\n", kCatVersion,_appID, [self getUnionId]] : @"".mutableCopy;
            
            @synchronized (_pvBuffer) {
                if (_pvBuffer.count > 0) {
                    NSMutableArray *pvArr = [_pvBuffer objectAtIndex:0];
                    lines = pvArr.count;
                    for (NSString *s in pvArr) {
                        [body appendString:s];
                        [body appendString:@"\n"];
                    }
                    
                    [_pvBuffer removeObjectAtIndex:0];
                } else {
                    continue;
                }
            }
        
            //是否需要上报
            NSURL *uploadURL;
            if (_failoverURL) {
                uploadURL = _failoverURL;
            }else{
//#warning need remove 
//                _host = @"10.72.254.63:8080";
//                _serverURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/broker-service/commandbatch?r=%@&v=5&p=%d&unionId=%@",_host, [[LogReportSwitcher shareInstance] configVersion],_appID,[[NVMonitorCenter defaultCenter] getUnionId]]];
                _serverURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@/broker-service/commandbatch?r=%@&v=5&p=%d&unionId=%@",[self serverHost], [[LogReportSwitcher shareInstance] configVersion],_appID,[[NVMonitorCenter defaultCenter] getUnionId]]];
                uploadURL =_serverURL;
            }
            if (!uploadURL) {
                return;
            }
            
            if (NVMONITORDEBUG) {
                NSLog(@"CAT BODY: %@", body);
            }
            
            NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:uploadURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:15];
            req.HTTPShouldHandleCookies = false;
            [req setHTTPMethod:@"POST"];
            if (uploadURL == _serverURL) {
                [req addValue:@"gzip" forHTTPHeaderField:@"Content-Encoding"];
                [req setHTTPBody:[[body dataUsingEncoding:NSUTF8StringEncoding] mcEncodeGZip]];
            }else{
                [req setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
            }
            [req addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            NSHTTPURLResponse *resp = nil;
            NSError *error = nil;
            NSData *respData = [NSURLConnection sendSynchronousRequest:req returningResponse:&resp error:&error];
            
            if(respData && [resp statusCode] / 100 == 2) {
                if (NVMONITORDEBUG) {
                    NSLog(@"CAT MONITOR UPLOAD FINISHED: COUNT = %@", @(lines));
                }
                
                [[LogReportSwitcher shareInstance] handleCatResponse:respData];
            } else {
                LLog(LoganTypeLogan, [NSString stringWithFormat:@"CAT MONITOR UPLOAD FAILED: ERROR = %@", error]);
            }
        }
    }
}

- (NSString *)platformString {
    static dispatch_once_t onceToken;
    static NSString *platform;
    dispatch_once(&onceToken, ^{
        size_t size;
        sysctlbyname("hw.machine", NULL, &size, NULL, 0);
        char *machine = malloc(size);
        sysctlbyname("hw.machine", machine, &size, NULL, 0);
        platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
        free(machine);
    });
    return platform;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _stop = YES;
}

@end
