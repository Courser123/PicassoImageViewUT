//
//  NVMetricsMonitor.h
//  MonitorDemo
//
//  Created by ZhouHui on 16/7/19.
//  Copyright © 2016年 dianping. All rights reserved.
//

#import <Foundation/Foundation.h>



typedef NS_ENUM(NSUInteger, NVMetricsMonitorCategory) {
    NVMetricsMonitorCategoryCPU,
    NVMetricsMonitorCategoryMEM,
    NVMetricsMonitorCategoryFPS
};


/** NVMetricsMonitor提供了自定义上报的功能。
 *  相关的配置都在NVMonitorCenter中，使用NVMetricsMonitor不需要额外设置。
 *  《Cat自定义打点方案及接口说明》wiki地址：http://wiki.sankuai.com/pages/viewpage.action?pageId=531467789
 *  《iOS接入文档》wiki地址：http://wiki.sankuai.com/pages/viewpage.action?pageId=501557351
 *   内部未做线程保护，请在主线程调用
 */
@interface NVMetricsMonitor : NSObject

#pragma mark 通用格式

/**
 * 添加kvs字段，必须为NSNumber型的数据
 */
- (void)addValue:(nonnull NSNumber *)value forKey:(nonnull NSString *)key;
/**
 * 添加一组kvs字段，必须为NSNumber型的数组数据
 */
- (void)addValues:(nonnull NSArray<NSNumber *> *)values forKey:(nonnull NSString *)key;

/**
 * 添加tag字段，tag必须为NSString类型
 */
- (void)addTag:(nonnull NSString *)tag forKey:(nonnull NSString *)key;


/**
 设置本次上报的appid，仅对当前实例有效

 @param appid appid
 */
- (void)setAppID:(int)appid;


- (void)setExtra:(nonnull NSString *)extra;

/**
 * 上报数据.
 * 上报的服务器地址配置于NVMonitorCenter中(setServerHost:).
 * NVMetricsMonitor为一次性上报的对象，不建议复用
 */
- (void)send;


#pragma mark  定制格式


/**
 * 添加tag字段，tag必须为NSString类型,必须指定数据类型,单个实例请只使用一种类型
 */

- (void)sendCPUUpload:(nonnull NSString *)page value:(nonnull NSNumber *)value,...NS_REQUIRES_NIL_TERMINATION;
- (void)sendMEMUpload:(nonnull NSString *)page value:(nonnull NSNumber *)value,...NS_REQUIRES_NIL_TERMINATION;
- (void)sendFPSUpload:(nonnull NSString *)page value:(nonnull NSNumber *)value,...NS_REQUIRES_NIL_TERMINATION ;


@end
