//
//  NVCrashMonitor.h
//  MonitorDemo
//
//  Created by yxn on 16/9/2.
//  Copyright © 2016年 dianping. All rights reserved.
//

#import <Foundation/Foundation.h>

//从第一次上报开始计时，24小时内最多上报10次，超过24小时重新开始计时

@interface NVCrashMonitor : NSObject

@property(nonatomic, assign)NSInteger crashTimesLimit;

+ (nonnull instancetype)defaultMonitor;

- (void)setCrashTimes:(NSInteger)times;

- (BOOL)reachCrashReportLimit;

/**
 上报接口，自动上报

 @param time         crash时间戳
 @param reason       crash简要原因
 @param crashContent crash堆栈
 */

- (void)recordCrashTime:(NSTimeInterval)time crashReason:(nonnull NSString *)reason crashContent:(nonnull NSString *)crashContent;


/**
 @param category 卡顿类型
 */
- (void)recordCrashTime:(NSTimeInterval)time crashReason:(nonnull NSString *)reason crashContent:(nonnull NSString *)crashContent category:(nonnull NSString *)category;

@end
