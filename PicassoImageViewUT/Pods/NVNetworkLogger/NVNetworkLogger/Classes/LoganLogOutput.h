//
//  LoganLogOutput.h
//  NVNetworkLogger
//
//  Created by yxn on 2017/4/13.
//  Copyright © 2017年 xiangnan.yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Logan.h"


NS_ASSUME_NONNULL_BEGIN

@interface LoganLogOutput : NSObject


/**
 upload by push

 @param date file date
 @param taskID job id
 @param isWifi can upload under wifi
 @param fileSize max file size
 */
- (void)uploadLogWithDate:(nonnull NSString *)date
                   taskID:(nonnull NSString *)taskID
                   isWifi:(BOOL)isWifi
                 fileSize:(long)fileSize
                  isForce:(BOOL)isForce;


/**
 主动上报日志

 @param date    the file of update date
 @param appid   appid
 @param unionid unionid
 */
- (void)uploadLogWithDate:(nonnull NSString *)date
                    appid:(nonnull NSString *)appid
                  unionid:(nonnull NSString *)unionid
                 complete:(nullable LoganUploadBlock)complete;

/**
 主动上报日志
 
 @param date    the file of update date
 @param appid   appid
 @param unionid unionid
 @param environment environment
 */
- (void)uploadLogWithDate:(nonnull NSString *)date
                    appid:(nonnull NSString *)appid
                  unionid:(nonnull NSString *)unionid
              environment:(nullable NSString*)environment
                 complete:(nullable LoganUploadBlock)complete;



/**
 主动上报日志

 @param date the file of update date
 @param appid appid
 @param unionid unionid
 @param uniqueString uniqueString
 @param source source
 @param environment environment
 @param complete complete
 */
- (void)uploadLogWithDate:(nonnull NSString *)date
                    appid:(nonnull NSString *)appid
                  unionid:(nullable NSString *)unionid
                   source:(int)source
              environment:(nullable NSString *)environment
                 complete:(nullable LoganUploadBlock)complete;

- (void)uploadFailedTasks;

@end


NS_ASSUME_NONNULL_END

