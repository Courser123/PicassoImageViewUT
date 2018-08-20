//
//  NVSpeedMonitor.m
//  MonitorDemo
//
//  Created by ZhouHui on 16/4/21.
//  Copyright © 2016年 dianping. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NVSpeedMonitor.h"
#import "NVNetworkReachability.h"
#import "NVMonitorCenter.h"
#import "LogReportSwitcher.h"

extern BOOL NVMONITORDEBUG;

@interface NVSpeedMonitor ()

@property (nonatomic, strong) NSMutableString *record;
@property (nonatomic, assign) NSTimeInterval  startTime;
@property (nonatomic, assign) BOOL            shouldUpload;

@end

@implementation NVSpeedMonitor

- (instancetype)initWithPageName:(NSString *)page time:(NSTimeInterval)time
{
    if (self = [super init]) {
        _startTime                      = time <= 0 ? [[NSDate date] timeIntervalSince1970] : time;
        NVNetworkReachability netStatus = NVGetNetworkReachability();
        _record                         = [NSMutableString stringWithFormat:@"%.f\t%@\t%@\t2\t%@\t%@\t%@", _startTime * 1000, @(netStatus), @([[NVMonitorCenter defaultCenter] getVersionCode]).stringValue,[[UIDevice currentDevice] systemVersion],[[NVMonitorCenter defaultCenter] platformString],page];
        _shouldUpload                   = YES;
    }
    return self;
}

- (instancetype)initWithPageName:(NSString *)page
{
    return [self initWithPageName:page time:0];
}

- (void)catRecord:(NSInteger)modelIndex
{
    [self catRecord:modelIndex maxInterval:0];
}

- (void)catRecord:(NSInteger)modelIndex maxInterval:(NSTimeInterval)maxInterval
{
    NSTimeInterval currentInterval = [[NSDate date] timeIntervalSince1970] - self.startTime;
    [self appendRecord:modelIndex max:maxInterval current:currentInterval];
}


- (void)catRecord:(NSInteger)modelIndex time:(NSTimeInterval)time{
    [self catRecord:modelIndex maxInterval:0 time:time];
}

- (void)catRecord:(NSInteger)modelIndex maxInterval:(NSTimeInterval)maxInterval time:(NSTimeInterval)time
{
    NSTimeInterval currentInterval;
    if (time > 0) {
        currentInterval = time;
    }else{
        currentInterval = [[NSDate date] timeIntervalSince1970] - self.startTime;
    }
    
    [self appendRecord:modelIndex max:maxInterval current:currentInterval];
}


- (void)appendRecord:(NSInteger)modelIndex max:(NSTimeInterval)maxInterval current:(NSTimeInterval)currentInterval{
    if ([NSThread isMainThread]) {
        [self mainAppendRecord:modelIndex max:maxInterval current:currentInterval];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self mainAppendRecord:modelIndex max:maxInterval current:currentInterval];
        });
    }
}


- (void)mainAppendRecord:(NSInteger)modelIndex max:(NSTimeInterval)maxInterval current:(NSTimeInterval)currentInterval{
    if (maxInterval == 0 || currentInterval < maxInterval) {
        self.shouldUpload = YES;
        if (self.record.length > 0) {
            [self.record appendFormat:@"\t%@-%.f", @(modelIndex), currentInterval * 1000];
        }
    } else {
        self.shouldUpload = NO;
    }
}


- (void)catEnd{
    if ([NSThread isMainThread]) {
        [self intenalCatEnd];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self intenalCatEnd];
        });
    }
}

- (void)intenalCatEnd{
    if (self.shouldUpload) {
        if (self.record.length > 0) {
            [self.record appendFormat:@"\n"];
            [self report];
        }
    }

}

- (void)report{
    NSString *postString       = [NSString stringWithFormat:@"v=2&unionId=%@&c=\n%@",[[NVMonitorCenter defaultCenter] getUnionId] ?: @"", self.record];
    if (NVMONITORDEBUG) {
        NSLog(@"postString : %@", postString);
    }
    //是否需要上报
    BOOL isReport =  [[LogReportSwitcher shareInstance] isLogReport:@"base"];
    if (!isReport) return;
    
    NSURL *url                 = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@/broker-service/api/speed?p=%d",[NVMonitorCenter defaultCenter].serverHost,[[NVMonitorCenter defaultCenter] appID]]];
    NSMutableURLRequest *req   = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:15];
    req.HTTPShouldHandleCookies = false;
    [req setHTTPMethod:@"POST"];
    [req addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [req setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session      = [NSURLSession sessionWithConfiguration:config];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (NVMONITORDEBUG) {
            NSLog(@"response : %@", response);
        }
    }];
    [task resume];

}

@end
