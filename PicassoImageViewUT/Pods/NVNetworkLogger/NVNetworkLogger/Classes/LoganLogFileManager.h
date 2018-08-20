//
//  LoganLogFileManager.h
//  NVNetworkLogger
//
//  Created by yxn on 2017/4/13.
//  Copyright © 2017年 xiangnan.yang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LoganLogFileManager : NSObject

+ (instancetype)sharedInstance;

- (BOOL)checkFileExist:(nonnull NSString *)filePath;
- (BOOL)createLogFileDirectory:(nonnull NSString *)directory fileName:(nonnull NSString *)fileName;
- (void)processLocalFiles;
- (NSDictionary *)allFilesInfo;

//文件名1:大小1|文件名2:大小2 2018-05-08:1000|2018-05-07:1000
- (NSString *)filesInfoString;
@end

NS_ASSUME_NONNULL_END
