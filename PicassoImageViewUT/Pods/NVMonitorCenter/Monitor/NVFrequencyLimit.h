//
//  NVFrequencylimit.h
//  MonitorDemo
//
//  Created by yxn on 16/9/21.
//  Copyright © 2016年 dianping. All rights reserved.
//


#import <Foundation/Foundation.h>


#define NVCrashMonitorLimit @"NVCrashMonitorLimit"


@interface NVFrequencyLimit : NSObject

+ (instancetype)sharedInstance;

- (BOOL)crashMonitorFrequencyLimit:(NSInteger)limit;

- (NSNumber *)currentLimit;

- (BOOL)hiJackMonitorFrequencyLimitWith:(NSInteger)duration and:(NSString *)url;

@end
