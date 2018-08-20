//
//  Logan.h
//  NVNetworkLogger
//
//  Created by yxn on 2017/4/11.
//  Copyright © 2017年 xiangnan.yang. All rights reserved.

/*
 LoganSDK提供了日志的存储和回捞服务。
 详情见WIKI：https://wiki.sankuai.com/pages/viewpage.action?pageId=847898315
*/

#import <Foundation/Foundation.h>
#import "LogReportSwitcher.h"
#import "LoganTypes.h"
#import "LoganEnvironment.h"
#import "LoganLinkerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

#define LoganSDKVersion @"3"
// 以下是LoganLogEx的Mask参数：
#define LoganCallStack  1 // 记录日志的同时，记录当前的方法调用堆栈
#define LoganSnapShot   2 // 记录日志的通知，记录当前的屏幕截图
/**
 记录Logan日志
 
 @param type 日志类型，请使用宏定义中的预埋类型。logan的日志类型全集团唯一。增加日志类型请联系周辉(hui.zhou)。
 @param log  日志字符串
 
 @brief
 用例：
 LLog(LoganTypeCode, @"this is a test");
 */
extern void LLog(LoganType type, NSString *log);
extern void log2Cat(char *item, int code);
extern void LLogEx(LoganType type, NSString *log, int mask);

/**
 记录Logan日志
 
 @param type 日志类型，请使用宏定义中的预埋类型。logan的日志类型全集团唯一。增加日志类型请联系周辉(hui.zhou)。
 @param log  日志字符串
 @param tags 标签，可传入多个标签
 
 @brief
 用例：
 LLog(LoganTypeCode, @"this is a test",@["tag",@"normal"]);
 */
extern void LLogAndTags(LoganType type, NSArray<NSString *> *tags, NSString *log);
// 上报的状态码
#define LoganUploadFileNotExist     401 // 日志文件不存在
#define LoganUploadFileCopyFileFail 402 // 文件操作出错
#define LoganUploadFileFileError    403 // 上报文件不存在
#define LoganUploadFileNetworkError 404 // 上报网络故障
#define LoganUploadFileServerError  500 // 服务端错误

//上报的source
#define SEND_LOGAN_ACTION 1 //主动上报
#define SEND_LOGAN_PUSH 2 //回捞上报
#define SEND_LOGAN_DIAGNOSE 3 //网络诊断上报

typedef void (^LoganUploadBlock)(BOOL succ, int errorCode, NSString *errorMsg);

typedef void (^LoganCatBlock)(NSString *cmd,int code,int uploadPercent);

@interface Logan : NSObject<LoganLinkerProtocol>

+ (instancetype)sharedInstance;


+ (void)setCatBlock:(LoganCatBlock)cat;

/**
 立即写入日志文件
 */
+ (void)flash;

/**
 删除所有日志文件
 */
+ (void)clearAllLogs;

/**
 主动上报日志
 @param date    the file of update date, like: "2017-05-27". if you want to upload today's log file, you can call [Logan todaysDate]
 @param appid   appid
 @param unionid unionid
 
 @brief
 用例：
 [Logan uploadLogWithDate:[Logan todaysDate] appid:@"1" unionid:@"1423453452453"];
 */
+ (void)uploadLogWithDate:(nonnull NSString *)date appid:(nonnull NSString *)appid unionid:(nonnull NSString *)unionid ;

/**
 主动上报日志
 @param date    the file of update date, like: "2017-05-27". if you want to upload today's log file, you can call [Logan todaysDate]
 @param appid   appid
 @param unionid unionid
 @param complete complete block
 
 @brief
 用例：
 [Logan uploadLogWithDate:[Logan todaysDate] appid:@"1" unionid:@"1423453452453" complete:];
 */
+ (void)uploadLogWithDate:(nonnull NSString *)date
                    appid:(nonnull NSString *)appid
                  unionid:(nonnull NSString *)unionid
                 complete:(nullable LoganUploadBlock)complete ;

/**
 主动上报日志
 @param date    the file of update date, like: "2017-05-27". if you want to upload today's log file, you can call [Logan todaysDate]
 @param appid   appid
 @param unionid unionid
 @param environment environment
 @param complete complete block
 
 */
+ (void)uploadLogWithDate:(nonnull NSString *)date
                    appid:(nonnull NSString *)appid
                  unionid:(nonnull NSString *)unionid
              environment:(nullable NSString *)environment
                 complete:(nullable LoganUploadBlock)complete ;


/**
 主动上报日志

 @param date the file of update date, like: "2017-05-27". if you want to upload today's log file, you can call [Logan todaysDate]
 @param appid appid
 @param uniqueString 日志分类标识
 @param source 来源
 @param environment 额外环境变量
 @param complete complete block
 */
+ (void)uploadLogWithDate:(nonnull NSString *)date
                    appid:(nonnull NSString *)appid
             uniqueString:(nullable NSString *)uniqueString
                   source:(int)source
              environment:(nullable LoganEnvironment *)environment
                 complete:(nullable LoganUploadBlock)complete;


/**
 返回今天的日期

 @return 今天的日期
 */
+ (NSString *)todaysDate;


/**
 将日志全部输出到控制台的开关，默认NO

 @param useASL 开关
 */
+ (void)useASL:(BOOL)useASL;

/**
 CLogan库中的日志信息输出开关，默认NO
 
 @param print 开关
 */
+ (void)printCLibLog:(BOOL)print;

/**
 获取当前所有logan日志文件

 @return filename:filesize
 */
+ (NSDictionary *)loganFiles;



@end

NS_ASSUME_NONNULL_END
