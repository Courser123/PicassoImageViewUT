//
//  NVMetricsMonitor.m
//  MonitorDemo
//
//  Created by ZhouHui on 16/7/19.
//  Copyright © 2016年 dianping. All rights reserved.
//

#import "NVMetricsMonitor.h"
#import "NVMonitorCenter.h"
#import "NVNetworkReachability.h"
#import "LogReportSwitcher.h"
#import <UIKit/UIKit.h>


extern BOOL NVMONITORDEBUG;

@implementation NVMetricsMonitor {
    NSMutableDictionary *_kvs;
    NSMutableDictionary *_tags;
    int                 _internalAppID;
    NSString *          _extraStr;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _kvs = [NSMutableDictionary new];
        _tags = [NSMutableDictionary new];
    }
    return self;
}

- (void)addValue:(nonnull NSNumber *)value forKey:(nonnull NSString *)key {
    NSNumber *holdValues = value;
    NSString *holdKey = key;
    if (!holdValues || !holdKey) {
        return;
    }
    [_kvs setObject:@[holdValues] forKey:holdKey];
}

- (void)addValues:(nonnull NSArray<NSNumber *> *)values forKey:(nonnull NSString *)key {
    NSArray<NSNumber *> *holdValues = values;
    NSString *holdKey = key;
    if (!holdValues || !holdKey) {
        return;
    }
    [_kvs setObject:holdValues forKey:holdKey];
}

- (void)addTag:(nonnull NSString *)tag forKey:(nonnull NSString *)key {
    NSString *holdTag = tag;
    NSString *holdKey = key;
    if (!holdTag || !holdKey) {
        return;
    }
    [_tags setObject:holdTag forKey:holdKey];
}

- (void)send {
    //是否需要上报
    BOOL isReport = [[LogReportSwitcher shareInstance] isLogReport:@"base"];
    if (!isReport) return;
    
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    NSMutableDictionary *dataDic = [NSMutableDictionary new];
  
    if (![_tags objectForKey:@"version"]) {
        [_tags setObject:version forKey:@"version"];
    }
    [self sendRequest:dataDic];
}

#pragma mark  自定义上报

- (void)sendCPUUpload:(nonnull NSString *)page value:(nonnull NSNumber *)value,...NS_REQUIRES_NIL_TERMINATION{
    NSMutableArray *valueArr = @[].mutableCopy;
    va_list args;
    va_start(args, value);
    for (id otherString = value; otherString != nil; otherString = va_arg(args, id)) {
        [valueArr addObject:otherString];
    }
    va_end(args);
    [self addValues:valueArr forKey:@"value"];
    [self addTag:page forKey:@"page"];
    [self sendWithType:NVMetricsMonitorCategoryCPU];
    
}

- (void)sendMEMUpload:(nonnull NSString *)page value:(nonnull NSNumber *)value,...NS_REQUIRES_NIL_TERMINATION{
    NSMutableArray *valueArr = @[].mutableCopy;
    va_list args;
    va_start(args, value);
    for (id otherString = value; otherString != nil; otherString = va_arg(args, id)) {
        [valueArr addObject:otherString];
    }
    va_end(args);
    [self addValues:valueArr forKey:@"value"];
    [self addTag:page forKey:@"page"];
    [self sendWithType:NVMetricsMonitorCategoryMEM];
}

- (void)sendFPSUpload:(nonnull NSString *)page value:(nonnull NSNumber *)value,...NS_REQUIRES_NIL_TERMINATION{
    NSMutableArray *valueArr = @[].mutableCopy;
    va_list args;
    va_start(args, value);
    for (id otherString = value; otherString != nil; otherString = va_arg(args, id)) {
        [valueArr addObject:otherString];
    }
    va_end(args);
    [self addValues:valueArr forKey:@"value"];
    [self addTag:page forKey:@"page"];
    [self sendWithType:NVMetricsMonitorCategoryFPS];

}

- (void)sendWithType:(NVMetricsMonitorCategory)category{
    //是否需要上报
    BOOL isReport = [[LogReportSwitcher shareInstance] isLogReport:@"base"];
    if (!isReport) return;
    
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSMutableDictionary *dataDic = [NSMutableDictionary new];
    NSString *type = @"";
    switch (category) {
        case NVMetricsMonitorCategoryCPU:
            type = @"cpu";
            break;
        case NVMetricsMonitorCategoryMEM:
            type = @"mem";
            break;
        case NVMetricsMonitorCategoryFPS:
            type = @"fps";
            break;
        default:
            break;
    }
    
    if (![_tags objectForKey:@"category"]) {
        [_tags setObject:type forKey:@"category"];
    }
    
    if (![_tags objectForKey:@"appVersion"]) {
        [_tags setObject:version forKey:@"appVersion"];
    }
    
    if (![_tags objectForKey:@"sysVersion"]) {
        [_tags setObject:[[UIDevice currentDevice] systemVersion] forKey:@"sysVersion"];
    }
 
    if (![_tags objectForKey:@"model"]) {
        [_tags setObject:[[NVMonitorCenter defaultCenter] platformString] forKey:@"model"];
    }
    [self sendRequest:dataDic];
}

- (void)setAppID:(int)appid{
    _internalAppID = appid;
}

- (void)setExtra:(nonnull NSString *)extra{
    if (extra.length == 0) {
        return;
    }
    _extraStr = [extra copy];
}

- (void)sendRequest:(nonnull NSMutableDictionary *)dataDic{
    long ts = [[NSDate date] timeIntervalSince1970];
    [dataDic setObject:@(ts) forKey:@"ts"];
    [dataDic setObject:_kvs forKey:@"kvs"];
    int appid = _internalAppID > 0 ?_internalAppID:[[NVMonitorCenter defaultCenter] appID];
    if (![_tags objectForKey:@"appId"]) {
        [_tags setObject:[NSString stringWithFormat:@"%d", appid] forKey:@"appId"];
    }
    
    if (![_tags objectForKey:@"platform"]) {
        [_tags setObject:@"2" forKey:@"platform"];
    }
    
    [dataDic setObject:_tags forKey:@"tags"];
    if (_extraStr.length) {
        [dataDic setObject:_extraStr forKey:@"extra"];
    }

    NSData *postData = [NSJSONSerialization dataWithJSONObject:dataDic options:0 error:NULL];
    NSString *dataString = [[[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@/broker-service/metrictag?v=1&p=%d&unionId=%@&data=%@",[NVMonitorCenter defaultCenter].serverHost, appid, [[NVMonitorCenter defaultCenter] getUnionId],dataString]];
    if (NVMONITORDEBUG) {
        NSLog(@"NVMetricsMonitor request: %@", url.absoluteString);
    }
    NSMutableURLRequest *req   = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:15];
    req.HTTPShouldHandleCookies = false;
    [req setHTTPMethod:@"POST"];
    [req addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [req setHTTPBody:postData];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session      = [NSURLSession sessionWithConfiguration:config];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (NVMONITORDEBUG) {
            NSLog(@"NVMetricsMonitor response : %@", response);
        }
    }];
    [task resume];

}




@end
