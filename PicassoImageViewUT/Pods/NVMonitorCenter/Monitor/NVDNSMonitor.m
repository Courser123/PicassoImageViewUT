//
//  NVHiJackMonitor.m
//  MonitorDemo
//
//  Created by yxn on 16/9/22.
//  Copyright © 2016年 dianping. All rights reserved.
//

#import "NVDNSMonitor.h"
#import "NVMonitorCenter.h"
#import "NVFrequencyLimit.h"
#import <UIKit/UIKit.h>

//#define kWaitSendingTime 5
#define kWaitSendingTime 60 //等待上报的时间间隔（单位：秒）
//#define kUploadHost @"http://broker-service01.beta"

#define kDNSMonitorVersion 3


extern BOOL NVMONITORDEBUG;


@interface NVDNSMonitor ()

@property(nonatomic, assign)    NSInteger duration;
@property(nonatomic, strong)    NVFrequencyLimit *limitHelper;
@property (nonatomic, retain)   NSThread    *thread;
@property (nonatomic, retain)   NSCondition *condition;
@property (nonatomic, assign)   BOOL        stop;
@property (nonatomic, assign)   BOOL        force;
@property (assign)              BOOL waitSending;
@property (nonatomic, assign) BOOL        isBeta;

@end


@implementation NVDNSMonitor {
    NSMutableArray *_buffer;
}

+ (nonnull instancetype)defaultMonitor
 {
    static NVDNSMonitor *gCenter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gCenter = [NVDNSMonitor new];
    });
    return gCenter;
}

-(NSString *)serverHost{
    if (self.isBeta) {
        return @"https://catdot.51ping.com";
    }else{
        return @"https://catdot.dianping.com";
    }
}

- (void)setupIsBeta:(BOOL)beta{
    self.isBeta = beta;
}

- (instancetype)init{
    if (self = [super init]) {
        _waitSending = NO;
        _limitHelper= [NVFrequencyLimit sharedInstance];
        _condition = [[NSCondition alloc] init];
        _buffer = [NSMutableArray array];
        _duration = 300;
    }
    return self;
}

- (void)launchSendThread {
    if (_thread) {
        return;
    }
    @synchronized (self) {
        if (!_thread) {
            _thread = [[NSThread alloc] initWithTarget:self selector:@selector(run) object:nil];
            [_thread start];
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
        }
    }
}

- (void)applicationDidEnterBackground:(NSNotification *)n {
    @try {
        // 统计数据立即上传
        [self flush];
    }
    @catch (NSException *exception) {
        NSLog(@"applicationDidEnterBackground, DNSMonitor forceUpload occured exception: %@", exception);
    }
}

- (void)applicationWillTerminate:(NSNotification *)n {
    @try {
        // 统计数据立即上传
        [self flush];
    }
    @catch (NSException *exception) {
        NSLog(@"applicationWillTerminate, DNSMonitor forceUpload occured exception: %@", exception);
    }
}

- (void)uploadNow {
    [_condition signal];
}

- (void)flush {
    [_condition lock];
    _force = YES;
    [_condition signal];
    [_condition unlock];
}

- (void)run {
    while (!_stop) {
        @autoreleasepool {
            [_condition lock];
            while(!_force && _buffer.count == 0) {
                [_condition wait];
            }
            [_condition unlock];
            if(_stop)
                return;
            _force = NO;
            
            
            NSInteger lines = 0;
            NSMutableString *datas = [NSMutableString string];
            
            @synchronized (_buffer) {
                if (_buffer.count > 0) {
                    for (NSString *s in _buffer) {
                        [datas appendString:s];
                        [datas appendString:@"\n"];
                        lines++;
                    }
                    [_buffer removeAllObjects];
                } else {
                    continue;
                }
            }
            
            NSString *percentDatas = [datas stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSString *body = [NSString stringWithFormat:@"v=%d&content=\n%@", kDNSMonitorVersion, percentDatas];
            
            NSURL *uploadURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/broker-service/hijack?v=%d", [self serverHost], kDNSMonitorVersion]];

            
            NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:uploadURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:15];
            req.HTTPShouldHandleCookies = false;
            [req setHTTPMethod:@"POST"];
            [req setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
            [req addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            NSHTTPURLResponse *resp = nil;
            NSError *error = nil;
            if([NSURLConnection sendSynchronousRequest:req returningResponse:&resp error:&error] && [resp statusCode] / 100 == 2) {
                if (NVMONITORDEBUG) {
                    NSLog(@"DNS HIJACK UPLOAD FINISHED: COUNT = %ld", (long)lines);
                }
            } else {
                if (NVMONITORDEBUG) {
                    NSLog(@"DNS HIJACK UPLOAD FAILED: COUNT = %ld. \nERROR(%ld):%@", (long)lines, (long)[resp statusCode], error);
                }
            }
            self.waitSending = NO;
        }
    }
}

- (void)sendHiJackedUrl:(nonnull NSString *)hiJackedUrl WithIpList:(nonnull NSArray *)host{
    [self sendHiJackedUrl:hiJackedUrl WithIpList:host pageName:nil uploadPercent:100];
}

- (void)sendHiJackedUrl:(nonnull NSString *)hiJackedUrl
             WithIpList:(nonnull NSArray *)host
               pageName:(nullable NSString *)pagename
          uploadPercent:(NSUInteger)percent{
    
    if (percent == 0 || percent > 100) {
        return;
    }
    
    uint32_t random = arc4random_uniform(1000000);
    if (random >= (percent*10000)) {
        return;
    }
    
    if (![self.limitHelper hiJackMonitorFrequencyLimitWith:self.duration and:hiJackedUrl]) {
        return;
    }
    
    [self launchSendThread];
    
    NSString *hosts = [host componentsJoinedByString:@","];
    NSString *s = nil;
    if (pagename) {
        s = [[NSString alloc] initWithFormat:@"%@\t%@\t%@", hiJackedUrl, hosts,pagename];
    }else{
        s = [[NSString alloc] initWithFormat:@"%@\t%@", hiJackedUrl, hosts];
    }
    
    if (NVMONITORDEBUG) {
        NSLog(@"DNS hijack: %@", s);
    }
    
    @synchronized (_buffer) {
        [_buffer addObject:s];
    }
    
    if (self.waitSending) {
        return;
    }
    
    self.waitSending = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(uploadNow) object:nil];
        [self performSelector:@selector(uploadNow) withObject:nil afterDelay:kWaitSendingTime];
    });
}

- (void)setDNSDuration:(NSInteger)duration{
    if (duration > 0) {
        self.duration = duration;
    }else
        self.duration = 300;//5分钟
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _stop = YES;
}

@end
