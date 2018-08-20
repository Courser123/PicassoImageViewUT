//
//  NVCrashMonitor.m
//  MonitorDemo
//
//  Created by yxn on 16/9/2.
//  Copyright © 2016年 dianping. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NVCrashMonitor.h"
#import "NVMonitorCenter.h"
#import "NVFrequencyLimit.h"
#import "Logan.h"

extern BOOL NVMONITORDEBUG;

static inline NSString * CatNull2Empty(NSString *str){
    if (!str) return @"";
    return str;
}

@interface NVCrashMonitor ()

@property(nonatomic, strong)NVFrequencyLimit *limitHelper;

@end

@implementation NVCrashMonitor

+ (nonnull instancetype)defaultMonitor
{
    static NVCrashMonitor *gMonitor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gMonitor = [NVCrashMonitor new];
        
    });
    return gMonitor;
}

- (instancetype)init{
    if (self = [super init]) {
        _limitHelper = [NVFrequencyLimit sharedInstance];
        _crashTimesLimit = 9;
    }
    return self;
}

- (void)recordCrashTime:(NSTimeInterval)time crashReason:(nonnull NSString *)reason crashContent:(nonnull NSString *)crashContent category:(nonnull NSString *)category{
    if (![self.limitHelper crashMonitorFrequencyLimit:self.crashTimesLimit]) {
        return;
    }
    NSMutableDictionary *crashDic = [NSMutableDictionary new];
    if ([[NVMonitorCenter defaultCenter] appID] >0) {
        [crashDic setObject:@([[NVMonitorCenter defaultCenter] appID]).stringValue forKey:@"appId"];
    }
    [crashDic setObject:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] forKey:@"appVersion"];
    [crashDic setObject:[[UIDevice currentDevice] systemVersion] forKey:@"platVersion"];
    [crashDic setObject:[self deviceModel] forKey:@"deviceBrand"];
    [crashDic setObject:[[NVMonitorCenter defaultCenter] platformString] forKey:@"deviceModel"];
    [crashDic setObject:@(time).stringValue forKey:@"crashTime"];
    [crashDic setObject:[[NVMonitorCenter defaultCenter] getUnionId] forKey:@"unionId"];
    [crashDic setObject:@"ios" forKey:@"platform"];
    [crashDic setObject:CatNull2Empty(reason) forKey:@"reason"];
    [crashDic setObject:CatNull2Empty(crashContent) forKey:@"crashContent"];
    [crashDic setObject:CatNull2Empty(category) forKey:@"category"];
    [self reportWithCrash:crashDic];
    
    // 记录到Logan中
    NSData *jsonData =[NSJSONSerialization dataWithJSONObject:crashDic options:NSJSONWritingPrettyPrinted error:nil];
    if (!jsonData) {
        return;
    }
    NSString *log = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    LLog(LoganTypeCrash, log);
}

- (void)recordCrashTime:(NSTimeInterval)time crashReason:(NSString *)reason crashContent:(NSString *)crashContent{
    [self recordCrashTime:time crashReason:reason crashContent:crashContent category:@""];
}

- (void)reportWithCrash:(NSDictionary *)dic{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@/broker-service/crashlog",[NVMonitorCenter defaultCenter].serverHost]];
    NSMutableURLRequest *req   = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:15];
    req.HTTPShouldHandleCookies = false;
    [req setHTTPMethod:@"POST"];
    [req addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    NSError *error;
    NSData *jsonData =[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        return;
    }
    [req setHTTPBody:jsonData];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];

    NSURLSession *session      = [NSURLSession sessionWithConfiguration:config];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (NVMONITORDEBUG) {
            NSLog(@"NVCrashMonitor response : %@", response);
        }
    }];
    [task resume];
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

- (void)setCrashTimes:(NSInteger)times{
    self.crashTimesLimit = times;
}

- (NSNumber *)currentUploadTimes{
    return [self.limitHelper currentLimit];
}

- (BOOL)reachCrashReportLimit{
    return [[self currentUploadTimes] integerValue] > self.crashTimesLimit ? YES : NO;
}

@end
