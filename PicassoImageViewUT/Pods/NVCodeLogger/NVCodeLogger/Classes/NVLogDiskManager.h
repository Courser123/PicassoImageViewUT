//
//  NVLogDiskManager.h
//  Nova
//
//  Created by MengWang on 14-12-25.
//  Copyright (c) 2014年 dianping.com. All rights reserved.
//


typedef NSDictionary *(^LoggerParams)();
//本地log日志的管理器
@interface NVLogDiskManager : NSObject
@property (nonatomic, copy) LoggerParams loggerParams;
@property (nonatomic, copy) NSString *appID;      // 唯一标识app的


/**
*  获取当前类的实例
*/
+ (instancetype)sharedInstance;

/**
 *  打印log字符串
 *
 *  @param printLogStr 要保存的日志 category:聚合的分类
 */
+ (void)cachePrintLog:(NSString *)printLogStr withCategory:(NSString *)category;

/**
 *  @param printLogStr 要保存的日志 category:聚合的分类 tags:标签（写入logan使用）
 */
+ (void)cachePrintLog:(NSString *)printLogStr withCategory:(NSString *)category andTags:(NSArray<NSString *> *)tags;

/**
 *  获取本地保存的keys
 *
 *  @return 返回本地保存的keys数组 
 */
+ (NSArray *)logCacheKeys;

/**
 *  断言打印log
 *
 *  @param printLogStr 要保存的日志 category:聚合的分类 moduleClass:模块类名 keyWithLog:去重的key(行数和文件名组合)
 */
+ (void)cacheAssertLog:(NSString *)printLogStr withCategory:(NSString *)category withModuleClass:(NSString *)moduleClass withKey:(NSString *)keyWithLog;

/**
 *  查询n条log记录，返回数组的block
 */
- (void)queryLogs:(NSUInteger)count withBlock:(void(^)(NSArray *))block;

/**
 *  查询n条log记录，返回数组。只用于程序crash之后，直接通过这个接口捞日志(同步查询，会卡线程，其他业务线请慎用)
 */
- (NSArray *)querySyncLogs:(NSUInteger)count;

@end
