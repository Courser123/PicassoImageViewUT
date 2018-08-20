//
//  LoganUtils.m
//  NVNetworkLogger
//
//  Created by yxn on 2017/4/13.
//  Copyright © 2017年 xiangnan.yang. All rights reserved.
//

#import "LoganUtils.h"
#import "LogReportSwitcher.h"
#import "NVNetworkReachability.h"
#import "ios-ntp.h"
#include <sys/param.h>
#include <sys/mount.h>
#import "LoganLogFileManager.h"

static NSString * const PUSH_UPLOAD_USER_DEFAULT = @"loganUploadUserDefault";
static NSString * const PUSH_UPLOAD_TASK_IDS = @"loganUploadTaskIds";

@interface LoganUtils ()

@property(nonatomic, strong)NSNumber *maxQueueObj;
@property(nonatomic, strong)NSNumber *maxReversedDateObj;
@property(nonatomic, strong)NSNumber *minFreeSpaceObj;
@property(nonatomic, strong)NSNumber *maxBufferSizeObj;
@property(nonatomic, strong)NSNumber *maxLogFileObj;
@property(nonatomic, strong)NSNumber *useCLibObj;

@end

@implementation LoganUtils

+ (instancetype)sharedInstance{
    static id __singleton__objc;
    static dispatch_once_t __singleton__token;
    dispatch_once(&__singleton__token, ^{
        __singleton__objc = [[self alloc] init];
    });
    return __singleton__objc;
}

- (instancetype)init{
    if (self = [super init]) {
        [self config];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switcherConfigChanged) name:SwitcherConfigChangedNotification object:nil];
    }
    return self;
}

- (void)switcherConfigChanged {
    [self config];
}

- (void)config{
    @synchronized (self) {
        NSArray *arr = [[LogReportSwitcher shareInstance] getLoganConfig];
        [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary *configObject = (NSDictionary *)obj;
            NSString *key = [configObject objectForKey:@"configId"];
            if (key.length > 0) {
                if ([key isEqualToString:@"logan_maxQueue"]) {
                    self.maxQueueObj = [configObject objectForKey:@"content"];
                } else if ([key isEqualToString:@"logan_saveTime"]) {
                    self.maxReversedDateObj = [configObject objectForKey:@"content"];
                } else if ([key isEqualToString:@"logan_minFreeSpace"]) {
                    self.minFreeSpaceObj = [configObject objectForKey:@"content"];
                } else if ([key isEqualToString:@"logan_maxBufferSize"]) {
                    self.maxBufferSizeObj = [configObject objectForKey:@"content"];
                } else if ([key isEqualToString:@"logan_maxLogFile"]) {
                    self.maxLogFileObj = [configObject objectForKey:@"content"];
                } else if ([key isEqualToString:@"logan_useCLib"]) {
                    self.useCLibObj = [configObject objectForKey:@"content"];
                }
            }
        }];
    }
}

#pragma mark  -------- configs

- (int)maxReversedDate{
    @synchronized (self) {
        return (_maxReversedDateObj&&(_maxReversedDateObj.intValue > 0)) ? _maxReversedDateObj.intValue : 7;
    }
}

- (int)maxQueue{
    @synchronized (self) {
        return (_maxQueueObj&&(_maxQueueObj.intValue > 0)) ? _maxQueueObj.intValue : 50;
    }
}

- (int)minFreeSpace{
    @synchronized (self) {
        return (_minFreeSpaceObj&&(_minFreeSpaceObj.intValue > 0)) ? _minFreeSpaceObj.intValue : 50;
    }
}

- (int)maxBufferSize{
    @synchronized (self) {
        return (_maxBufferSizeObj&&(_maxBufferSizeObj.intValue > 0)) ? _maxBufferSizeObj.intValue : 32;
    }
}

- (int)maxLogFile{
    @synchronized (self) {
        return (_maxLogFileObj&&(_maxLogFileObj.intValue > 0)) ? _maxLogFileObj.intValue : 10;
    }
}

- (BOOL)useCLib {
    @synchronized (self) {
        return (_useCLibObj) ? _useCLibObj.boolValue : YES;
    }
}

#pragma mark  --------  file matters

+ (NSString *)loganLogDirectory{
    static NSString *dir = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dir = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"LoganLoggerv3"];
    });
    return dir;
}

+ (NSString *)loganLogDirectoryV2{
   return  [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"LoganLogger"];
}

+ (NSString *)loganLogOldDirectory{
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"NetworkLogger"];
}

+ (NSString *)loganLogCurrentFileName{
    return [self currentDate];
}

+ (NSString *)currentDate{
    NSString *key = @"LOGAN_CURRENTDATE";
    NSMutableDictionary *dictionary = [[NSThread currentThread] threadDictionary];
    NSDateFormatter *dateFormatter = [dictionary objectForKey:key];
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dictionary setObject:dateFormatter forKey:key];
        [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    }
    return [dateFormatter stringFromDate:[NSDate threadsafeNetworkDate]];
}

+ (NSString *)loganLogCurrentFilePath{
    return [[self loganLogDirectory] stringByAppendingPathComponent:[self loganLogCurrentFileName]];
}

+ (NSString *)logTodayFileName {
    return [self logFileName:[self currentDate]];
}

+ (NSString *)logFileName:(NSString *)date {
    return [NSString stringWithFormat:@"%@", date];
}

+ (NSString *)latestLogFilePath {
    return [[self loganLogDirectory] stringByAppendingPathComponent:[self logTodayFileName]];
}

+ (NSString *)logFilePath:(NSString *)date {
    return [[self loganLogDirectory] stringByAppendingPathComponent:[self logFileName:date]];
}

+ (NSString *)uploadFilePath:(NSString *)date {
    return [[self loganLogDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.temp", date]];
}

+ (NSArray *)localFilesArray {
    return [[[[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self loganLogDirectory] error:nil] filteredArrayUsingPredicate: [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] '-'"]] sortedArrayUsingSelector:@selector(compare:)];//[c]不区分大小写 , [d]不区分发音符号即没有重音符号 , [cd]既不区分大小写，也不区分发音符号。
}

#pragma mark  --------  time

+ (NSString *)loganCurrentTime{
    NSString *key = @"LOGAN_CURRENTTIME";
    NSMutableDictionary *dictionary = [[NSThread currentThread] threadDictionary];
    NSDateFormatter *dateFormatter = [dictionary objectForKey:key];
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dictionary setObject:dateFormatter forKey:key];
        [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
        [dateFormatter setDateFormat:@"HH:mm:ss.SSS"];
    }
    return [dateFormatter stringFromDate:[NSDate threadsafeNetworkDate]];
}

+ (NSTimeInterval)loganTimeStamp{
    return [[NSDate threadsafeNetworkDate] timeIntervalSince1970] * 1000;
}

+ (NSTimeInterval)loganLocalTimeStamp{
    return [[NSDate date] timeIntervalSince1970] * 1000;
}


+ (NSInteger)getDaysFrom:(NSDate *)serverDate To:(NSDate *)endDate
{
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDate *fromDate;
    NSDate *toDate;
    [gregorian rangeOfUnit:NSCalendarUnitDay startDate:&fromDate interval:NULL forDate:serverDate];
    [gregorian rangeOfUnit:NSCalendarUnitDay startDate:&toDate interval:NULL forDate:endDate];
    NSDateComponents *dayComponents = [gregorian components:NSCalendarUnitDay fromDate:fromDate toDate:toDate options:0];
    return dayComponents.day;
}

+(NSInteger)getThreadNum
{
    NSString * description = [[NSThread currentThread] description];
    NSRange beginRange = [description rangeOfString:@"{"];
    NSRange endRange = [description rangeOfString:@"}"];
    
    if (beginRange.location == NSNotFound || endRange.location == NSNotFound) return -1;
    
    NSInteger length =endRange.location-beginRange.location-1;
    if (length < 1) {
        return -1;
    }
    
    NSRange keyRange = NSMakeRange(beginRange.location+1, length);
    
    if (keyRange.location == NSNotFound) {
        return -1;
    }
    
    if (description.length > (keyRange.location + keyRange.length)) {
        NSString *keyPairs = [description substringWithRange:keyRange];
        NSArray * keyValuePairs = [keyPairs componentsSeparatedByString:@","] ;
        for( NSString * keyValuePair in keyValuePairs){
            NSArray * components = [keyValuePair componentsSeparatedByString:@"="] ;
            if(components.count){
                NSString * key = components[0] ;
                key = [ key stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] ;
                if (([key isEqualToString:@"num"] || [key isEqualToString:@"number"]) && components.count > 1){
                    return [components[1] integerValue] ;
                }
            }
        }
    }
    return -1;
}

+ (long long)freeDiskSpaceInBytes {
    struct statfs buf;
    long long freespace = -1;
    if(statfs("/var", &buf) >= 0){
        freespace = (long long)(buf.f_bsize * buf.f_bfree);
    }
    return freespace;
}

#pragma mark  -------- helpers


+ (unsigned long long)fileSizeAtPath:(NSString *)filePath{
    if (filePath.length == 0) {
        return 0;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExist = [fileManager fileExistsAtPath:filePath];
    if (isExist){
        return [[fileManager attributesOfItemAtPath:filePath error:nil] fileSize];
    } else {
        return 0;
    }
}

+(NSString*)dataToJsonString:(id)object
{
    NSString *jsonString = nil;
    if (object && [NSJSONSerialization isValidJSONObject:object]) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                           options:0
                                                             error:&error];
        if (!jsonData || ![jsonData isKindOfClass:[NSData class]]) {
            NSLog(@"Got an error: %@", error);
        } else {
            @try {
                jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            } @catch (NSException *exception) {
                jsonString = nil;
            } @finally {}
        }
    }
    return jsonString;
}

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

+ (void)transferError:(NSString *)taskID errorCode:(int)code{
    if (taskID.length > 0) {
        [[LoganUtils sharedInstance] transferStatus:taskID isWifi:(NVGetAccurateNetworkReachability() == 1) fileSize:0 upload:NO  errorCode:code oldTaskId:nil];
    }
}

- (void)transferStatus:(NSString *)taskID
                isWifi:(BOOL)isWifi
              fileSize:(long)fileSize // file size in KB
                upload:(BOOL)upload
             errorCode:(int)code
             oldTaskId:(NSString *)oldTaskId{
    if (taskID.length < 1) {
        return;
    }
    
    //#ifdef DEBUG
    //    NSURL *url                 = [NSURL URLWithString:@"http://beta-logan.sankuai.com/logger/kick.json"];
    //#else
    NSURL *url                 = [NSURL URLWithString:@"https://logan.sankuai.com/logger/kick.json"];
    //#endif
    
    NSMutableURLRequest *req   = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    [req setHTTPMethod:@"POST"];
    
    NSString *bodyString = @"";
    if (upload) {
        bodyString = [NSString stringWithFormat:@"taskId=%ld&isWifi=%d&fileSize=%ld&upload=%d&client=ios&kickCode=%d&oldtaskid=%@",(long)taskID.integerValue,isWifi,fileSize,upload,code,oldTaskId];
    }else {
        //当不需要上传文件时，将文件信息保存在kick body中。
        NSString *f = [[LoganLogFileManager sharedInstance] filesInfoString];
        NSString *bundleVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
        bodyString = [NSString stringWithFormat:@"taskId=%ld&isWifi=%d&fileSize=%ld&upload=%d&client=ios&kickCode=%d&oldtaskid=%@&buildID=%@&filesInfo=%@",(long)taskID.integerValue,isWifi,fileSize,upload,code,oldTaskId,bundleVersion,f];
    }
    [req setHTTPBody:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
    
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    NSURLSession *session      = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_semaphore_signal(sema);
    }];
    [task resume];
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
}

+ (NSDictionary *)uploadedTaskIds{
    NSUserDefaults * taskIdUserDefault = [[NSUserDefaults alloc] initWithSuiteName:PUSH_UPLOAD_USER_DEFAULT];
    NSDictionary * taskIds = [taskIdUserDefault valueForKey:PUSH_UPLOAD_TASK_IDS];
    if(!taskIds){
        taskIds = @{};
    }
    return taskIds;
}

+ (void)storeSucceedTaskId:(NSString *)taskId withDate:(NSString *)date{
    if(!taskId || !date) return;
    NSUserDefaults * taskIdUserDefault = [[NSUserDefaults alloc] initWithSuiteName:PUSH_UPLOAD_USER_DEFAULT];
    NSMutableDictionary * uploadedTaskIds = [[taskIdUserDefault valueForKey:PUSH_UPLOAD_TASK_IDS] mutableCopy];
    if(!uploadedTaskIds){
        uploadedTaskIds = @{}.mutableCopy;
    }
    [uploadedTaskIds setObject:taskId forKey:date];
    [taskIdUserDefault setObject:uploadedTaskIds forKey:PUSH_UPLOAD_TASK_IDS];
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
