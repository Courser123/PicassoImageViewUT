//
//  NVFrequencylimit.m
//  MonitorDemo
//
//  Created by yxn on 16/9/21.
//  Copyright © 2016年 dianping. All rights reserved.
//

#import "NVFrequencyLimit.h"
#import "NVMoniterCenterDefines.h"
#import <objc/runtime.h>

#define NVFrequencyLimitOneDayDuration (60*60*24)

@interface NVFrequencyLimitHelper : NSObject
//限制次数
@property(nonatomic, strong)NSNumber *times;
//限制时间
@property(nonatomic, assign)NSTimeInterval startTime;

@end


@implementation NVFrequencyLimitHelper



MoniterCenterSerialize_Coder_Decoder()

@end



@interface NVFrequencyLimit ()
//缓存区
@property(nonatomic, strong)NSUserDefaults *userDefaults;
@property(strong)NSMutableDictionary *dnsUrlDic;

@end

@implementation NVFrequencyLimit


+ (instancetype)sharedInstance {
    static NVFrequencyLimit *limit = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        limit = [NVFrequencyLimit new];
    });
    return limit;
}

- (instancetype)init{
    if (self = [super init]) {
        _userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"MonitorCenter"];
        _dnsUrlDic = [NSMutableDictionary new];
    }
    return self;
}

#pragma mark  ----crash

- (BOOL)crashMonitorFrequencyLimit:(NSInteger)limit{
    NVFrequencyLimitHelper *limitHelper;
    NSData *data = [self.userDefaults objectForKey:NVCrashMonitorLimit];
    if (data) {
        limitHelper = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    if (!limitHelper) {
        limitHelper = [NVFrequencyLimitHelper new];
        [self initialLimitHelper:limitHelper];
        return YES;
    }else{
        NSTimeInterval currentInterval = [[NSDate date] timeIntervalSince1970];
        if ((currentInterval - NVFrequencyLimitOneDayDuration) > limitHelper.startTime) {
            [self initialLimitHelper:limitHelper];
            return YES;
        }else{
            if ([limitHelper.times integerValue] > (limit > 0 ? limit : 9)) {
                return NO;
            }else{
                limitHelper.times = @([limitHelper.times integerValue] + 1);
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:limitHelper];
                if (data) {
                    [self.userDefaults setObject:data forKey:NVCrashMonitorLimit];
                }
                return YES;
            }
        }
    }
    return NO;
}

- (void)initialLimitHelper:(NVFrequencyLimitHelper *)limitHelper{
    limitHelper.times = @(0);
    limitHelper.startTime = [[NSDate date] timeIntervalSince1970];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:limitHelper];
    if (data) {
        [self.userDefaults setObject:data forKey:NVCrashMonitorLimit];
    }
}

- (NSNumber *)currentLimit{
    NSData *data = [self.userDefaults objectForKey:NVCrashMonitorLimit];
    if (data) {
        NVFrequencyLimitHelper *limitHelper = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if (limitHelper && [limitHelper.times isKindOfClass:[NSNumber class]]) {
            return limitHelper.times;
        }
    }
    return @(0);
}


#pragma mark ----hijack

- (BOOL)hiJackMonitorFrequencyLimitWith:(NSInteger)duration and:(NSString *)url{
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    @synchronized (self.dnsUrlDic) {
        NSNumber *uploadTime = [self.dnsUrlDic objectForKey:url];
        if (!uploadTime) {
            [self.dnsUrlDic setObject:@(now) forKey:url];
            return YES;
        }else{
            if ((now - [uploadTime integerValue]) > duration) {
                [self.dnsUrlDic setObject:@(now) forKey:url];
                return YES;
            }else{
                return NO;
            }
        }
    }
    return NO;
}

@end
