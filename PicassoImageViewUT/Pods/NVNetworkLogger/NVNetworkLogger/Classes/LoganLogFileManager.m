//
//  LoganLogFileManager.m
//  NVNetworkLogger
//
//  Created by yxn on 2017/4/13.
//  Copyright © 2017年 xiangnan.yang. All rights reserved.
//

#import "LoganLogFileManager.h"
#import "LoganUtils.h"
#import "ios-ntp.h"

@interface LoganLogFileManager ()

@property(nonatomic, strong)NSFileManager *fileManager;

@end

@implementation LoganLogFileManager


+ (instancetype)sharedInstance{
    static id __singleton__objc;
    static dispatch_once_t __singleton__token;
    dispatch_once(&__singleton__token, ^{
        __singleton__objc = [[self alloc] init];
    });
    return __singleton__objc;
}

- (nonnull instancetype)init{
    if (self = [super init]) {
        _fileManager = [NSFileManager defaultManager];
    }
    return self;
}

- (void)processLocalFiles{
    [self deleteOutdatedFiles];
    [self deleteOldNetworkLogFile];
}

- (BOOL)checkFileExist:(nonnull NSString *)filePath{
    if (filePath.length == 0) {
        return NO;
    }
    if (![self.fileManager fileExistsAtPath:filePath]) {
        return NO;
    }
    return YES;
}

- (BOOL)createLogFileDirectory:(nonnull NSString *)directory fileName:(nonnull NSString *)fileName{
    if (directory.length == 0 || fileName.length == 0) {
        return NO;
    }
    NSString *filePath = [directory stringByAppendingPathComponent:fileName];
    if ([self checkFileExist:filePath]) {
        return YES;
    }
    
    if (![self.fileManager fileExistsAtPath:directory]) {
        if ([self.fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil]) {
           return [self.fileManager createFileAtPath:filePath contents:nil attributes:nil];
        }else{
            return NO;
        }
    }
    return [self.fileManager createFileAtPath:filePath contents:nil attributes:nil];
}


- (void)deleteOutdatedFiles{
    NSArray *allFiles = [LoganUtils localFilesArray];
    __block NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    NSString *dateFormatString = @"yyyy-MM-dd";
    [formatter setDateFormat:dateFormatString];
    [allFiles enumerateObjectsUsingBlock:^(NSString *_Nonnull dateStr, NSUInteger idx, BOOL * _Nonnull stop) {
        // 检查后缀名
        if ([dateStr pathExtension].length>0) {
            [self deleteLoganFile:dateStr];
            return;
        }
        
        // 检查文件名长度
        if (dateStr.length != (dateFormatString.length)) {
            [self deleteLoganFile:dateStr];
            return;
        }
        
        // 文件名转化为日期
        dateStr = [dateStr substringToIndex:dateFormatString.length];
        NSDate *date = [formatter dateFromString:dateStr];
        if (!date || [LoganUtils getDaysFrom:date To:[NSDate threadsafeNetworkDate]] >= [[LoganUtils sharedInstance] maxReversedDate]) {
            // 删除过期文件
            [self deleteLoganFile:dateStr];
        }
    }];
}

- (NSDictionary *)allFilesInfo{
    NSArray *allFiles = [LoganUtils localFilesArray];
    NSString *dateFormatString = @"yyyy-MM-dd";
    NSMutableDictionary *infoDic = [NSMutableDictionary new];
    [allFiles enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *dateStr = (NSString *)obj;
        if ([dateStr pathExtension].length>0) {
            // 无拓展名
            return;
        }
        dateStr = [dateStr substringToIndex:dateFormatString.length];
        NSString *filePath = [LoganUtils logFilePath:dateStr];
        unsigned long long gzFileSize = [LoganUtils fileSizeAtPath:filePath];
        [infoDic setObject:@(gzFileSize/1024).stringValue forKey:dateStr];
    }];
    return infoDic.copy;
}

- (NSString *)filesInfoString {
    
    NSArray *allFiles = [LoganUtils localFilesArray];
    NSString *dateFormatString = @"yyyy-MM-dd";
    
    __block NSString *files = @"";
    [allFiles enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *dateStr = (NSString *)obj;
        if ([dateStr pathExtension].length>0) {
            // 无拓展名
            return;
        }
        dateStr = [dateStr substringToIndex:dateFormatString.length];
        NSString *filePath = [LoganUtils logFilePath:dateStr];
        unsigned long long gzFileSize = [LoganUtils fileSizeAtPath:filePath];
        if (files.length) {
            files = [files stringByAppendingString:@"|"];
        }
        files = [files stringByAppendingString:dateStr];
        files = [files stringByAppendingString:@":"];
        double gzsize = (double)gzFileSize/1024;
        NSString *size = [NSString stringWithFormat:@"%.2lf",gzsize];
        files = [files stringByAppendingString:size?:@""];
    }];
    return files;
}

- (void)deleteLoganFile:(NSString *)name {
    [self.fileManager removeItemAtPath:[[LoganUtils loganLogDirectory] stringByAppendingPathComponent:name] error:nil];
}

- (void)deleteOldNetworkLogFile{
    if ([self.fileManager fileExistsAtPath:[LoganUtils loganLogOldDirectory]]) {
        [self.fileManager removeItemAtPath:[LoganUtils loganLogOldDirectory] error:nil];
    }
    if ([self.fileManager fileExistsAtPath:[LoganUtils loganLogDirectoryV2]]) {
        [self.fileManager removeItemAtPath:[LoganUtils loganLogDirectoryV2] error:nil];
    }
}

@end
