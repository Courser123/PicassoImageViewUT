//
//  NVHiJackMonitor.h
//  MonitorDemo
//
//  Created by yxn on 16/9/22.
//  Copyright © 2016年 dianping. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NVDNSMonitor : NSObject

+ (nonnull instancetype)defaultMonitor;

/*
 * 设置LogReportSwitcher
 * beta  YES:表示是beta环境 环境为:catdot.51ping.com
 */
- (void)setupIsBeta:(BOOL)beta;

/**
 设置重复DNS的上报间隔，默认5分钟。
 该函数在NVMonitorCenter中设置，app开发需要在NVMonitorCenter初始化时设置，不需要单独调用

 @param duration 单位:秒
 */

- (void)setDNSDuration:(NSInteger)duration;

/**
 上报
 @param hiJackedUrl host
 @param host        iplist
 */
- (void)sendHiJackedUrl:(nonnull NSString *)hiJackedUrl WithIpList:(nonnull NSArray *)host;
/**
 上报
 @param hiJackedUrl host
 @param host        iplist
 @param pagename    name
 @param percent     0-100
 */
- (void)sendHiJackedUrl:(nonnull NSString *)hiJackedUrl
             WithIpList:(nonnull NSArray *)host
               pageName:(nullable NSString *)pagename
          uploadPercent:(NSUInteger)percent;

@end
