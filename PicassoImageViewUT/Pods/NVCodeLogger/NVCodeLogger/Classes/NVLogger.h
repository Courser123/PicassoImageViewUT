//
//  NVLogger.h
//  Pods
//
//  Created by MengWang on 16/5/11.
//
//


typedef NSDictionary *(^LoggerParams)();
@interface NVLogger : NSObject

/*
 * 注册
 * appID 唯一标识APP的
 * loggerParams 需要传进来的参数信息：如unionId（可能会变）
 */
+ (void)installWithAppID:(NSString*)appID LoggerParams:(LoggerParams)loggerParams;


/**
 *  查询n条log记录，返回数组的block。异步查询
 */
+ (void)queryLogs:(NSUInteger)count withBlock:(void(^)(NSArray *))block;


/**
 *  查询n条log记录，返回数组。只用于程序crash之后，直接通过这个接口捞日志(同步查询，会卡线程，其他业务线请慎用)
 */
+ (NSArray *)querySyncLogs:(NSUInteger)count;


@end

