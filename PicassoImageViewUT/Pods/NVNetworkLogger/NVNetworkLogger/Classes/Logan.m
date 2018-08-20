//
//  Logan.m
//  NVNetworkLogger
//
//  Created by yxn on 2017/4/11.
//  Copyright © 2017年 xiangnan.yang. All rights reserved.
//

#import "Logan.h"
#import "LoganLogInput.h"
#import "LoganLogOutput.h"
#import "LoganUtils.h"
#import "UIKit/UIKit.h"
#include <libkern/OSAtomic.h>
#include <execinfo.h>
#import "LoganLogFileManager.h"
#import "clogan_core.h"
#import "NVReachability.h"
#import "clogan_status.h"
#import "NVLinker.h"

BOOL LOGANUSEASL = NO;

static int lastCode;

static NSString * const PUSH_UPLOAD_TASK_IDS = @"loganUploadTaskIds";

@interface Logan ()

@property (nonatomic, strong)LoganLogInput *logInput;
@property (nonatomic, strong)LoganLogOutput *logOutput;
@property (nonatomic, copy)LoganCatBlock catBlock;
+ (void)Logan2Cat:(NSString *)cmd code:(int)code uploadPercent:(int)uploadPercent;

@end

typedef void (^snapShotFinish)(NSString *imgStr);

@implementation Logan

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
        _logInput = [[LoganLogInput alloc] init];
        _logOutput = [[LoganLogOutput alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadLogFile:) name:@"PUSH_PASSTHROUGH_logan" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidFinishLaunching:) name:UIApplicationDidFinishLaunchingNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appSignificantTimeChange) name:UIApplicationSignificantTimeChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidReceiveMemoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillTerminate) name:UIApplicationWillTerminateNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityHasChanged) name:NVReachabilityChanged object:nil];
    }
    [self cleanTimeoutTaskIds];
    return self;
}

- (void)cleanTimeoutTaskIds{
    NSDictionary *uploadedTaskIds = [[NSUserDefaults standardUserDefaults] valueForKey:PUSH_UPLOAD_TASK_IDS];
    if(!uploadedTaskIds) return;
    NSMutableDictionary *newTaskDic = [uploadedTaskIds mutableCopy];
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    [uploadedTaskIds.allKeys enumerateObjectsUsingBlock:^(NSString*  _Nonnull date, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDate *uploadedDate = [dateFormatter dateFromString:date];
        if(!uploadedDate) return ;
        NSTimeInterval uploadInterval = [uploadedDate timeIntervalSince1970];
        NSTimeInterval nowInterval = [[NSDate date] timeIntervalSince1970];
        if(nowInterval - uploadInterval > 7*24*60*60){
            [newTaskDic removeObjectForKey:date];
        }
    }];
    [[NSUserDefaults standardUserDefaults] setObject:newTaskDic forKey:PUSH_UPLOAD_TASK_IDS];
}

- (void)appDidBecomeActive {
    LLog(LoganTypeLogan, @"app did become active.");
}

- (void)appDidFinishLaunching:(NSNotification *)no {
    LLog(LoganTypeLogan, [NSString stringWithFormat:@"app did finish launching. object:%@ userInfo:%@", no.object, no.userInfo]);
}

- (void)appSignificantTimeChange {
    LLog(LoganTypeLogan, @"app significant time change.");
}

- (void)appDidReceiveMemoryWarning {
    LLog(LoganTypeLogan, @"app did receive memory warning.");
}

- (void)appWillResignActive {
    LLog(LoganTypeLogan, @"app will resign active.");
    [self needFlash];
}

- (void)appDidEnterBackground {
    LLog(LoganTypeLogan, @"app did enter background.");
    [self needFlash];
}

- (void)appWillEnterForeground {
    LLog(LoganTypeLogan, @"app will enter foreground.");
    [self needFlash];
}

- (void)appWillTerminate {
    LLog(LoganTypeLogan, @"app will terminate.");
    [self needFlash];
}

- (void)reachabilityHasChanged{
    NVNetworkReachability status = NVGetAccurateNetworkReachability();
    if (status == NVNetworkReachabilityWifi || status == NVNetworkReachabilityMobile4G) {
        [self.logOutput uploadFailedTasks];
    }
}

void LLog(LoganType type, NSString *log) {
    if ([[LogReportSwitcher shareInstance] isLogReport:@"logan"]) {
        [Logan writeLog:log logType:type flags:0 tags:nil];
    }
}

void LLogAndTags(LoganType type, NSArray<NSString *> *tags, NSString *log) {
    if ([[LogReportSwitcher shareInstance] isLogReport:@"logan"]) {
        [Logan writeLog:log logType:type flags:0 tags:tags];
    }
}

void LLogEx(LoganType type, NSString *log, int mask) {
    if ([[LogReportSwitcher shareInstance] isLogReport:@"logan"]) {
        [Logan writeLog:log logType:type flags:mask tags:nil];
    }
}


- (void)LLog:(NSString *)log type:(NSUInteger)type{
    LLog(type, log);
}

- (void)LLog:(NSString *)log type:(NSUInteger)type tags:(NSArray<NSString *> *)tags{
    LLogAndTags(type, tags, log);
}

+ (void)writeLog:(NSString *)log logType:(LoganType)type flags:(int)flags tags:(NSArray<NSString *> *)tags{
    if (log.length == 0) {
        return;
    }
    NSString *tag = nil;
    if (tags.count) {
        tag = [tags componentsJoinedByString:@"&"];
    }
    NSString *callStack = nil;
    NSTimeInterval logTime = [LoganUtils loganTimeStamp];
    NSTimeInterval localTime = [LoganUtils loganLocalTimeStamp];
    NSString *threadName = [[NSThread currentThread] name];
    NSInteger threadNum = [LoganUtils getThreadNum];
    BOOL threadIsMain = [[NSThread currentThread] isMainThread];
    
    if (LOGANUSEASL) {
        printf("LLog:%s (%ld) %s\n",[LoganUtils loganCurrentTime].UTF8String,(long)threadNum,log.UTF8String);
    }
    
    if (hasQuakerBirdLinker()) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [quakerBirdLinker() qbWriteLog:log type:type time:logTime localTime:localTime threadName:threadName threadNum:threadNum threadIsMain:threadIsMain tag:tags];
        });
    }
    
    if (flags&LoganCallStack) {
        callStack = [Logan callStack];
    }
    if (flags&LoganSnapShot) {
        [Logan snapShot:^(NSString *imgStr) {
            [[Logan sharedInstance].logInput writeLog:log
                                                 type:type
                                                 time:logTime
                                            localTime:localTime
                                           threadName:threadName
                                            threadNum:threadNum
                                         threadIsMain:threadIsMain
                                            callStack:callStack
                                             snapShot:imgStr
                                                 tag:tag
             ];
        }];
        return;
    }
    
    [[Logan sharedInstance].logInput writeLog:log
                                         type:type
                                         time:logTime
                                    localTime:localTime
                                   threadName:threadName
                                    threadNum:threadNum
                                 threadIsMain:threadIsMain
                                    callStack:callStack
                                     snapShot:nil
                                         tag:tag
     ];
}

- (void)uploadLogFile:(NSNotification *)notification{
    
    if (notification.userInfo.count == 0) {
        LLog(LoganTypeLogan, @"push userInfo is nil");
        return;
    }

    NSString *logankickString = [notification.userInfo objectForKey:@"logankick"];

    NSDictionary *logankick = [LoganUtils dictionaryWithJsonString:logankickString];
    if (logankick.count == 0) {
        LLog(LoganTypeLogan, @"push logankick is nil");
        return;
    }
    
    LLog(LoganTypeLogan, [NSString stringWithFormat:@"receive push notification:%@", logankickString]);
    
    NSString *taskid;
    id taskIdObj = [logankick objectForKey:@"taskId"]; // task id, like 100
    if ([taskIdObj isKindOfClass:[NSString class]]) {
        taskid = taskIdObj;
    } else if ([taskIdObj isKindOfClass:[NSNumber class]]) {
        taskid = [taskIdObj stringValue];
    }
    long fileSize = [[logankick objectForKey:@"fileSize"] longValue]; // file size, in KB, like "100"
    NSString *date = [logankick objectForKey:@"logDate"]; // update log date, like "2017-05-17"
    BOOL isWifi = [[logankick objectForKey:@"isWifi"] boolValue]; // only update in wifi, like 0|1
    BOOL isForce = [[logankick objectForKey:@"isForce"] boolValue]; //
    
    if (date.length == 0 || taskid.length == 0) {
        LLog(LoganTypeLogan, [NSString stringWithFormat:@"push date is (%@), task id is (%@)", date, taskid]);
        return;
    }
    [self uploadWithDate:date taskId:taskid isWifi:isWifi fileSize:fileSize isForce:isForce];
}

- (void)uploadWithDate:(NSString *)date taskId:(NSString *)taskid isWifi:(BOOL)isWifi fileSize:(long)fileSize isForce:(BOOL)isForce{
    if(!taskid || !date) return;
    if ([date isEqualToString:[[self class] todaysDate]]) {
        // 当日日志需要先写入本地文件
        [self.logInput flashWithComplete:^{
            [self.logOutput uploadLogWithDate:date taskID:taskid isWifi:isWifi fileSize:fileSize isForce:isForce];
        }];
    } else {
        // 非当日日志可以直接上报
        [self.logOutput uploadLogWithDate:date taskID:taskid isWifi:isWifi fileSize:fileSize isForce:isForce];
    }
}

- (void)needFlash {
    [self.logInput flash];
}

+ (void)flash {
    [[Logan sharedInstance] needFlash];
}

+ (void)clearAllLogs {
    [[Logan sharedInstance].logInput clearAllLogs];
    LLog(LoganTypeLogan, @"clear all logs");
}

+ (void)useASL:(BOOL)useASL{
    LOGANUSEASL = useASL;
}

+ (void)printCLibLog:(BOOL)print {
    clogan_setDebug(!!print);
}

+ (void)setCatBlock:(LoganCatBlock)cat{
    if ([Logan sharedInstance].catBlock == NULL) {
        [Logan sharedInstance].catBlock = cat;
    }
}

+ (void)Logan2Cat:(NSString *)cmd code:(int)code uploadPercent:(int)uploadPercent{
//NSAssert([Logan sharedInstance].catBlock, @"init catblock first");
    dispatch_async(dispatch_get_main_queue(), ^{
        if([cmd isEqualToString:@"clogan_write"]){
            if(code == lastCode){//过滤重复code
                return;
            }
            lastCode = code;
        }
        ![Logan sharedInstance].catBlock ? : [Logan sharedInstance].catBlock(cmd, code, uploadPercent);
    });
}

void log2Cat(char *cmd, int code){
    [Logan Logan2Cat:[NSString stringWithUTF8String:cmd] code:code uploadPercent:10];
}

+ (void)uploadLogWithDate:(nonnull NSString *)date appid:(nonnull NSString *)appid unionid:(nonnull NSString *)unionid {
    return [self uploadLogWithDate:date appid:appid unionid:unionid environment:nil complete:NULL];
}


+ (void)uploadLogWithDate:(nonnull NSString *)date
                    appid:(nonnull NSString *)appid
                  unionid:(nonnull NSString *)unionid
                 complete:(nullable LoganUploadBlock)complete{
    return [self uploadLogWithDate:date appid:appid unionid:unionid environment:nil complete:complete];
}
+ (void)uploadLogWithDate:(nonnull NSString *)date
                    appid:(nonnull NSString *)appid
             uniqueString:(nullable NSString *)uniqueString
                   source:(int)source
              environment:(nullable LoganEnvironment *)environment
                 complete:(nullable LoganUploadBlock)complete{
    [self uploadLogWithDate:date appid:appid unionid:uniqueString  source:source environment:[environment getEnvironmentString] complete:complete];
}

+ (void)uploadLogWithDate:(nonnull NSString *)date
                    appid:(nonnull NSString *)appid
                  unionid:(nonnull NSString *)unionid
              environment:(nullable NSString *)environment
                 complete:(nullable LoganUploadBlock)complete{
    [self uploadLogWithDate:date appid:appid unionid:unionid  source:0 environment:environment complete:complete];
}

+ (void)uploadLogWithDate:(nonnull NSString *)date
                    appid:(nonnull NSString *)appid
                  unionid:(nullable NSString *)unionid
                   source:(int)source
              environment:(nullable NSString *)environment
                 complete:(nullable LoganUploadBlock)complete{
    LLog(LoganTypeLogan, [NSString stringWithFormat:@"upload date:%@, appid:%@, unionid:%@", date, appid, unionid]);
    Logan *logan = [Logan sharedInstance];
    if ([date isEqualToString:[self todaysDate]]) {
        // 当日日志需要先写入本地文件
        [logan.logInput flashWithComplete:^{
            [logan.logOutput uploadLogWithDate:date appid:appid unionid:unionid  source:source environment:environment complete:complete];
        }];
    } else {
        // 非当日日志可以直接上报
        [logan.logOutput uploadLogWithDate:date appid:appid unionid:unionid  source:source environment:environment complete:complete];
    }
}


+ (NSString *)todaysDate {
    return [LoganUtils currentDate];
}

+ (NSString *)callStack {
    void* callstack[128];
    int frames = backtrace(callstack, 128);
    char **strs = backtrace_symbols(callstack, frames);
    NSMutableString *backTrace = [NSMutableString new];
//    if (frames<=3) {
//        free(strs);
//        return nil;
//    }
    for (int i = 0;i < frames;i++){
        [backTrace appendString:[NSString stringWithUTF8String:strs[i]]];
        [backTrace appendString:@"\n"];
    }
    free(strs);
    return backTrace;
}

+ (void)snapShot:(snapShotFinish)block {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (block == NULL) {
            return;
        }
        float scale = [[UIScreen mainScreen] scale];
        scale = MIN(scale, 2.0);
        UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
        CGRect rect = [keyWindow bounds];
        UIGraphicsBeginImageContextWithOptions(rect.size, NO, scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [keyWindow.layer renderInContext:context];
        UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        // 经过大量试验，JPG格式、scale为2、压缩率为0.1的图片数据占用空间最小，并且图像比较清晰
        NSData *imageData = UIImageJPEGRepresentation(img, 0.1f);
        NSString *str = [imageData base64EncodedStringWithOptions:0];
        block(str);
    });
}

+ (NSDictionary *)loganFiles{
    return [[LoganLogFileManager sharedInstance] allFilesInfo];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
