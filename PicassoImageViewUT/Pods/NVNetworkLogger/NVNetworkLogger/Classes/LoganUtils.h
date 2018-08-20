//
//  LoganUtils.h
//  NVNetworkLogger
//
//  Created by yxn on 2017/4/13.
//  Copyright © 2017年 xiangnan.yang. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LoganUtils : NSObject

+ (instancetype)sharedInstance;

#pragma mark  -------- configs


/**
 保存文件天数。

 @return 单位天，默认7
 */
- (int)maxReversedDate;
/**
 日志队列长度.

 @return 默认50
 */
- (int)maxQueue;
/**
 手机剩余空间大小小于该值时，停止写入。

 @return 单位为MB，默认50
 */
- (int)minFreeSpace;
/**
 日志内存缓存大小。

 @return 单位KB，默认32
 */
- (int)maxBufferSize;
/**
 单个日志文件最大占用空间大小。

 @return 单位MB，默认10
 */
- (int)maxLogFile;

/**
 是否使用C运行库。
 
 @return YES or NO
 */
- (BOOL)useCLib;

#pragma mark  --------  file matters

+ (NSString *)loganLogDirectory;
+ (NSString *)loganLogOldDirectory;
+ (NSString *)loganLogDirectoryV2;
+ (NSString *)loganLogCurrentFileName;
+ (NSString *)loganLogCurrentFilePath;
+ (NSString *)currentDate;
+ (NSString *)logFilePath:(NSString *)date;
+ (NSString *)uploadFilePath:(NSString *)date;
+ (NSString *)latestLogFilePath;
+ (NSString *)logTodayFileName;
+ (NSString *)logFileName:(NSString *)date;
+ (NSArray *)localFilesArray;

#pragma mark  --------  time

+ (NSString *)loganCurrentTime;
+ (NSTimeInterval)loganTimeStamp;
+ (NSTimeInterval)loganLocalTimeStamp;
+ (NSInteger)getDaysFrom:(NSDate *)serverDate To:(NSDate *)endDate;

#pragma mark  -------- helpers

// return file size, in Byte
+ (unsigned long long)fileSizeAtPath:(NSString *)filePath;
+ (NSString*)dataToJsonString:(id)object;
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;
#pragma mark  -------- thread num
+ (NSInteger)getThreadNum;

+ (long long)freeDiskSpaceInBytes;

+ (void)transferError:(NSString *)taskID errorCode:(int)code;


+ (NSDictionary *)uploadedTaskIds;

+ (void)storeSucceedTaskId:(NSString *)taskId withDate:(NSString *)date;

/**
 上报上传状态

 @param taskID   任务id
 @param isWifi   是否wifi
 @param fileSize 移动网络下限制上传的文件大小
 @param upload   客户端是否会上传日志文件
 @param code     状态码，见Logan.h中的定义
 */
- (void)transferStatus:(NSString *)taskID
                isWifi:(BOOL)isWifi
              fileSize:(long)fileSize // file size in KB
                upload:(BOOL)upload
             errorCode:(int)code
             oldTaskId:(NSString *)oldTaskId;

@end
