//
//  NVSpeedMonitor.h
//  MonitorDemo
//
//  Created by ZhouHui on 16/4/21.
//  Copyright © 2016年 dianping. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NVSpeedMonitor : NSObject

/**
 *  初始化monitor，获取当前时间为starttime
 *
 *  @param page 设置pagename
 *
 *  @return NVSpeedMonitor
 */
- (instancetype)initWithPageName:(NSString *)page;

/**
 *  初始化monitor
 *
 *  @param page 设置pagename
 *
 * @param time 设置手动指定时间
 *
 *  @return NVSpeedMonitor
 */
- (instancetype)initWithPageName:(NSString *)page time:(NSTimeInterval)time;

/**
 *  上报特殊时间点，与初始化时间拼接上传
 *
 *  @param modelIndex 约定每个时间点的index
 */
- (void)catRecord:(NSInteger)modelIndex;

/**
 *  上报特殊时间点，与初始化时间拼接上传, 支持自定义时间
 *
 *  @param modelIndex 约定每个时间点的index
 *  @param time       用户自定义时间
 */
- (void)catRecord:(NSInteger)modelIndex time:(NSTimeInterval)time;

/**
 *  同上
 *  @param maxInterval 超时，超过该时间不上报
 */
- (void)catRecord:(NSInteger)modelIndex maxInterval:(NSTimeInterval)maxInterval;

/**
 *  上报
 */
- (void)catEnd;

@end

