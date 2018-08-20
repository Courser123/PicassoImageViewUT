//
//  LoganLogInput.m
//  NVNetworkLogger
//
//  Created by yxn on 2017/4/13.
//  Copyright © 2017年 xiangnan.yang. All rights reserved.
//

#import "LoganLogInput.h"
#import "LoganLogFileManager.h"
#import "LoganUtils.h"
#import "LoganLogOutput.h"
#import "Logan.h"
#import "LoganDataProcess.h"
#include "clogan_core.h"

@interface LoganLogInput ()<NSStreamDelegate>

@property(nonatomic, copy) NSString *lastLogDate;

@end

@implementation LoganLogInput {
    NSMutableString *_wait4WriteString;
    NSTimeInterval _lastCheckFreeSpace;
}

- (nonnull instancetype)init{
    if (self = [super init]) {
        _logQueue = dispatch_queue_create("com.dianping.logan", DISPATCH_QUEUE_SERIAL);
        _wait4WriteString = [NSMutableString new];
        
        dispatch_async(self.logQueue, ^{
            [[LoganDataProcess sharedInstance] initAndOpenCLib];
        });
    }
    return self;
}

- (void)writeLog:(nonnull NSString *)log
            type:(LoganType)type
            time:(NSTimeInterval)time
       localTime:(NSTimeInterval)localTime
      threadName:(nullable NSString *)threadName
       threadNum:(NSInteger)threadNum
    threadIsMain:(BOOL)threadIsMain
       callStack:(nullable NSString *)callStack
        snapShot:(nullable NSString *)snapShot
             tag:(nullable NSString *)tag{
    
    // 确保剩余空间
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    if (now > (_lastCheckFreeSpace+60)) {
        _lastCheckFreeSpace = now;
        // 每隔至少1分钟，检查一下剩余空间
        long long freeDiskSpace = [LoganUtils freeDiskSpaceInBytes];
        if (freeDiskSpace <= ([[LoganUtils sharedInstance] minFreeSpace]*1024*1024)) {
            // 剩余空间不足，不再写入
            return;
        }
    }
    
    // tag最大长度为128
    if (tag.length > 128) {
        tag = [tag substringToIndex:128];
    }
    dispatch_async(self.logQueue, ^{
        if ([[LoganUtils sharedInstance] useCLib]) {
            NSString *today = [LoganUtils currentDate];
            if (self.lastLogDate && ![self.lastLogDate isEqualToString:today]) {
                // 日期变化，立即写入日志文件
                [self forceWriteFile];
                clogan_open((char *)today.UTF8String);
            }
            self.lastLogDate = today;
            char *threadNameC = threadName?(char *)threadName.UTF8String:"";
            char *tagChar = tag?(char *)tag.UTF8String:NULL;
            clogan_write_tag((int)type, (char *)log.UTF8String, (long long)time, (long long)localTime, threadNameC, (long long)threadNum,  (int)threadIsMain, tagChar);
        } else {
            NSMutableDictionary *logDic = [NSMutableDictionary new];
            [logDic setObject:@(type) forKey:@"f"];
            [logDic setObject:log forKey:@"c"];
            [logDic setObject:@(time) forKey:@"d"];
            [logDic setObject:@(localTime) forKey:@"l"];
            [logDic setObject:(threadName.length > 0 ? threadName : @"") forKey:@"n"];
            [logDic setObject:@(threadNum) forKey:@"i"];
            [logDic setObject:@(threadIsMain) forKey:@"m"];
            if (tag.length) {
                [logDic setObject:tag forKey:@"t"];
            }
            NSString *logString = [[LoganUtils dataToJsonString:logDic] stringByAppendingString:@"\n"];
            if (logString) {
                [self writeLog:logString];
            }
        }
    });
}

- (void)writeLog:(NSString *)log {
    NSString *today = [LoganUtils currentDate];
    if (self.lastLogDate && ![self.lastLogDate isEqualToString:today]) {
        // 日期变化，立即写入日志文件
        [self forceWriteFile];
    }
    
    [_wait4WriteString appendString:log];
    
    self.lastLogDate = today;
    
    if (_wait4WriteString.length >= ([[LoganUtils sharedInstance] maxBufferSize]*1024)) {
        // 内存buffer已满，立即写入日志
        [self forceWriteFile];
    }
}

- (void)flash {
    dispatch_async(self.logQueue, ^{
        [self forceWriteFile];
    });
}

- (void)flashWithComplete:(nonnull LoganFlashBlock)complete {
    dispatch_async(self.logQueue, ^{
        [self forceWriteFile];
        complete();
    });
}

- (void)forceWriteFile {
    if ([[LoganUtils sharedInstance] useCLib]) {
        clogan_flush();
    } else {
        if (_wait4WriteString.length==0) {
            return;
        }
        
        // 写入日志
        NSString *path = [self prepareWrittenFile];
        if (path) {
            [self writeToFile:path logData:_wait4WriteString];
        }
        
        [_wait4WriteString setString:@""];
    }
}

- (NSString *)prepareWrittenFile{
    long long freeDiskSpace = [LoganUtils freeDiskSpaceInBytes];
    if (freeDiskSpace <= ([[LoganUtils sharedInstance] minFreeSpace]*1024*1024) + _wait4WriteString.length) {
        // 剩余空间不足
        return nil;
    }
    
    // 找到文件
    NSString *path = [LoganUtils latestLogFilePath];
    
    // 文件不存在创建文件
    BOOL isDstFileExist = YES;
    if (![[LoganLogFileManager sharedInstance] checkFileExist:path]) {
        isDstFileExist = [[LoganLogFileManager sharedInstance] createLogFileDirectory:[LoganUtils loganLogDirectory] fileName:[LoganUtils logTodayFileName]];
    }
    
    if (!isDstFileExist) {
        // 文件创建失败
        return nil;
    }
    
    unsigned long long size = [LoganUtils fileSizeAtPath:path];
    if (size + ([[LoganUtils sharedInstance] maxBufferSize]*1024) >= ([[LoganUtils sharedInstance] maxLogFile]*1024*1024)) {
        // 文件过大，停止写入
        return nil;
    }
    
    return path;
}

- (BOOL)writeToFile:(NSString *)path logData:(NSString *)str {
    NSData *data = [[LoganDataProcess sharedInstance] processData:str];
    
    NSOutputStream *writeStream = [NSOutputStream outputStreamToFileAtPath:path append:YES];
    [writeStream open];
    
    if (data.length == 0) {
        LLog(LoganTypeLogan, @"no data need to write");
        return NO;
    }
    
    if (writeStream.streamStatus != NSStreamStatusOpen) {
        LLog(LoganTypeLogan, [NSString stringWithFormat:@"file(%@) NSStreamStatusOpen failed!", path]);
        return NO;
    }
    
    if (!writeStream.hasSpaceAvailable) {
        LLog(LoganTypeLogan, [NSString stringWithFormat:@"file(%@) has no space available", path]);
        return NO;
    }
    
    NSInteger writedBytesLength = 0;
    const uint8_t *dataBytes = [data bytes];
    NSInteger dataLength = [data length];
    while (dataLength != writedBytesLength) {
        NSInteger bytes = [writeStream write:&dataBytes[writedBytesLength] maxLength:(dataLength - writedBytesLength)];
        if (bytes > 0) {
            writedBytesLength += bytes;
        }else{
            LLog(LoganTypeLogan, [NSString stringWithFormat:@"write file error:%@", writeStream.streamError]);
            [writeStream close];
            return NO;
        }
    }
    [writeStream close];
    return YES;
}

- (void)clearAllLogs {
    dispatch_async(self.logQueue, ^{
        NSArray *array = [LoganUtils localFilesArray];
        NSError *error = nil;
        BOOL ret;
        for (NSString *name in array) {
            NSString *path = [[LoganUtils loganLogDirectory] stringByAppendingPathComponent:name];
            
            ret = [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
        }
    });
}

@end
