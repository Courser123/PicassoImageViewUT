//
//  LoganLogOutput.m
//  NVNetworkLogger
//
//  Created by yxn on 2017/4/13.
//  Copyright © 2017年 xiangnan.yang. All rights reserved.
//

#import "LoganLogOutput.h"
#import "LoganUtils.h"
#import "LoganLogFileManager.h"
#import "NVNetworkMD5File.h"
#import "NVNetworkReachability.h"
#import "Logan.h"
#import "LoganDataProcess.h"
#import "LoganTaskManager.h"
#import "clogan_core.h"


typedef void (^GzipFileBlock)(BOOL success, NSString * _Nonnull md5);

@interface Logan ()
+ (void)Logan2Cat:(NSString *)cmd code:(int)code uploadPercent:(int)uploadPercent;
@end

@interface LoganDataProcess ()
- (NSString *)cryptKey;
@end

@interface LoganLogOutput ()

@property(nonatomic, strong)dispatch_queue_t uploadQueue;
@property (nonatomic, strong) LoganTaskManager *taskManager;

@end

@implementation LoganLogOutput

- (instancetype)init{
    if (self = [super init]) {
        _taskManager = [[LoganTaskManager alloc] initWithOutput:self];
        [self p_initial];
    }
    return self;
}

- (void)p_initial{
    dispatch_async(self.uploadQueue, ^{
        [[LoganLogFileManager sharedInstance] processLocalFiles];
    });
}

#pragma mark  --------  interface
- (void)uploadLogWithDate:(nonnull NSString *)date appid:(nonnull NSString *)appid unionid:(nonnull NSString *)unionid complete:(nullable LoganUploadBlock)complete {
    [self uploadWithTaskID:nil fileDate:date appid:appid unionid:unionid  source:0 environment:nil isWifi:NO fileSize:LONG_MAX isForce:YES complete:complete];
}

- (void)uploadLogWithDate:(nonnull NSString *)date taskID:(nonnull NSString *)taskID isWifi:(BOOL)isWifi fileSize:(long)fileSize isForce:(BOOL)isForce{
    [self.taskManager addTask:[LoganTaskObject taskObjectWithDate:date taskID:taskID isWifi:isWifi fileSize:fileSize taskStatus:TaskUploading]];
    [self uploadWithTaskID:taskID fileDate:date appid:nil unionid:nil  source:0 environment:nil isWifi:isWifi fileSize:fileSize  isForce:isForce complete:NULL];
}

- (void)uploadLogWithDate:(nonnull NSString *)date appid:(nonnull NSString *)appid unionid:(nonnull NSString *)unionid environment:(nullable NSString*)environment complete:(nullable LoganUploadBlock)complete {
    [self uploadWithTaskID:nil fileDate:date appid:appid unionid:unionid  source:0 environment:environment isWifi:NO fileSize:LONG_MAX isForce:YES complete:complete];
}

#pragma mark  -------- upload

- (void)uploadLogWithDate:(nonnull NSString *)date
                    appid:(nonnull NSString *)appid
                  unionid:(nullable NSString *)unionid
                   source:(int)source
              environment:(nullable NSString *)environment
                 complete:(nullable LoganUploadBlock)complete{
    [self uploadWithTaskID:nil fileDate:date appid:appid unionid:unionid  source:source environment:environment isWifi:NO fileSize:LONG_MAX isForce:YES complete:complete];
}

- (void)uploadWithTaskID:(nullable NSString *)taskID
                fileDate:(nonnull NSString *)date
                   appid:(nullable NSString *)appId
                 unionid:(nullable NSString *)unionId
                  source:(int)source
              environment:(nullable NSString *)environment
                  isWifi:(BOOL)isWifi
                fileSize:(long)fileSize
                 isForce:(BOOL)isForce
                complete:(nullable LoganUploadBlock)complete {
    
    dispatch_async(self.uploadQueue, ^{
        //todo 减少上报逻辑
        NSFileManager *fm = [NSFileManager defaultManager];
        if(isForce) {//走上传文件的逻辑
            
        } else {//减少上传次数
            NSDictionary *uploadedTaskIds = [LoganUtils uploadedTaskIds];
            NSString *oldTaskId = uploadedTaskIds[date];
            if(oldTaskId){//已经上传过指定日期的日志文件
               [[LoganUtils sharedInstance] transferStatus:taskID isWifi:(NVGetAccurateNetworkReachability() == 1) fileSize:fileSize upload:NO errorCode:200  oldTaskId:oldTaskId];
                return ;
            }
        }
        NSString *filePath = [LoganUtils logFilePath:date];
        // 文件不存在上报错误
        if (![fm fileExistsAtPath:filePath]) {
            LLog(LoganTypeLogan, [NSString stringWithFormat:@"upload fail, file not exist:%@", filePath]);
            [LoganUtils transferError:taskID errorCode:LoganUploadFileNotExist];
            [self callComplete:complete succ:NO errorCode:LoganUploadFileNotExist errorMsg:@"日志文件不存在"];
            [Logan Logan2Cat:@"logan/nofile" code:LoganUploadFileNotExist uploadPercent:100];
            LoganTaskObject *taskObject = [self.taskManager taskObjectWithTaskID:taskID];
            if (taskObject) {
                taskObject.taskStatus = TaskUploadFinish;
                [self.taskManager routeTaskResult:taskObject];
            }
            return;
        }
        BOOL isToday = [date isEqualToString:[LoganUtils currentDate]];
        NSString *uploadFilePath = filePath;
        // 如果是当天的文件，需要拷贝文件，防止文件发生变动
        if (isToday) {
            uploadFilePath = [LoganUtils uploadFilePath:date];
            [fm removeItemAtPath:uploadFilePath error:nil];
            NSError *error;
            if (![fm copyItemAtPath:filePath toPath:uploadFilePath error:&error]) {
                LLog(LoganTypeLogan, [NSString stringWithFormat:@"upload fail, copy file error:%@", error]);
                [LoganUtils transferError:taskID errorCode:LoganUploadFileCopyFileFail];
                [self callComplete:complete succ:NO errorCode:LoganUploadFileCopyFileFail errorMsg:@"文件操作出错"];
                [Logan Logan2Cat:@"logan/copyfilefail" code:LoganUploadFileCopyFileFail uploadPercent:100];
                LoganTaskObject *taskObject = [self.taskManager taskObjectWithTaskID:taskID];
                if (taskObject) {
                    taskObject.taskStatus = TaskUploadFinish;
                    [self.taskManager routeTaskResult:taskObject];
                }
                return;
            }
        }
        
        // 计算md5
        NSString *md5 = [NVNetworkMD5File fileMD5:uploadFilePath];
        // 计算文件大小
        unsigned long long gzFileSize = [LoganUtils fileSizeAtPath:uploadFilePath];
        // 判断网络环境是否合适上报
        BOOL willUploadFile = [self isAutoUpload:isWifi] || (gzFileSize < fileSize*1024);
        // 上报状态正常，准备上报。文件大小单位为KB
        [[LoganUtils sharedInstance] transferStatus:taskID isWifi:(NVGetAccurateNetworkReachability() == 1) fileSize:(gzFileSize/1024) upload:willUploadFile errorCode:200 oldTaskId:nil];
        // 准备上传文件
        if (willUploadFile) {
//#ifdef DEBUG
//            NSURL *url                 = [NSURL URLWithString:@"http://beta-logan.sankuai.com/logger/upload.file"];
//#else
            NSURL *url                 = [NSURL URLWithString:@"https://logan.sankuai.com/logger/upload.file"];
//#endif
            NSMutableURLRequest *req   = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60];
            [req setHTTPMethod:@"POST"];
            [req addValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
            
            
            if (taskID.length > 0) {
                [req addValue:taskID forHTTPHeaderField:@"taskId"];
            }
            [req addValue:LoganSDKVersion forHTTPHeaderField:@"version"];//宏定义
            char *uploadKey = clogan_upload_key();
            if (strlen(uploadKey) > 0) {
                [req setValue:[NSString stringWithUTF8String:uploadKey] forHTTPHeaderField:@"key"];
            }
            if (md5.length > 0) {
                [req addValue:md5 forHTTPHeaderField:@"md5"];
            }
            if (appId.length > 0) {
                [req addValue:appId forHTTPHeaderField:@"appId"];
            }
            if (date.length >0) {
                [req addValue:date forHTTPHeaderField:@"fileDate"];
            }
            if (unionId.length > 0) {
                [req addValue:unionId forHTTPHeaderField:@"unionId"];
            }
            if (environment.length > 0) {
                [req addValue:environment forHTTPHeaderField:@"environment"];
            }
            if (date.length > 0) {
                [req addValue:date forHTTPHeaderField:@"fileName"];
            }
            NSString *f = [[LoganLogFileManager sharedInstance] filesInfoString];
            if (f.length > 0) {
                [req addValue:f forHTTPHeaderField:@"filesInfo"];
            }
            NSString *bundleVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
            if (bundleVersion.length > 0) {
                [req addValue:bundleVersion forHTTPHeaderField:@"buildID"];
            }
            
            [req addValue:[NSString stringWithFormat:@"%d",1] forHTTPHeaderField:@"rv"];
            [req addValue:[NSString stringWithFormat:@"%d",source] forHTTPHeaderField:@"uploadType"];
            [req addValue:@"ios" forHTTPHeaderField:@"client"];
            [req addValue:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] forHTTPHeaderField:@"appVersion"];
            
            dispatch_semaphore_t sema = dispatch_semaphore_create(0);
            NSURLSession *session      = [NSURLSession sharedSession];
            
            NSURL *fileUrl =[NSURL fileURLWithPath:uploadFilePath];
            if (!fileUrl) {
                [LoganUtils transferError:taskID errorCode:LoganUploadFileFileError];
                [Logan Logan2Cat:@"logan/nofile" code:LoganUploadFileFileError uploadPercent:100];
                [self callComplete:complete succ:NO errorCode:LoganUploadFileFileError errorMsg:@"上报文件不存在"];
                return;
            }
            NSURLSessionUploadTask *task = [session uploadTaskWithRequest:req fromFile:fileUrl completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                [self handleUploadTaskResult:data response:response error:error taskID:taskID date:date complete:complete];
                dispatch_semaphore_signal(sema);
            }];
            [task resume];
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        }
        if (isToday) {
            // 当天文件，需要把拷贝的文件删除
            [fm removeItemAtPath:uploadFilePath error:nil];
        }
    });
}

- (void)handleUploadTaskResult:(NSData *)data response:(NSURLResponse *)response error:(NSError *)error taskID:(NSString *)taskID date:(NSString *)date complete:(LoganUploadBlock)complete{
    LoganTaskObject *taskObject = [self.taskManager taskObjectWithTaskID:taskID];
    if (error) {//网络失败
        if (taskObject) {
            taskObject.taskStatus = TaskUploadFail;
            [self.taskManager routeTaskResult:taskObject];
        }
        LLog(LoganTypeLogan, [NSString stringWithFormat:@"upload error(%@)", error]);
        NSString *msg = [NSString stringWithFormat:@"上报网络故障：%@", error];
        [Logan Logan2Cat:@"logan/networkerror" code:LoganUploadFileNetworkError uploadPercent:100];
        [self callComplete:complete succ:NO errorCode:LoganUploadFileNetworkError errorMsg:msg];
    } else {//网络成功
        if (taskObject) {
            taskObject.taskStatus = TaskUploadSuccess;
            [self.taskManager routeTaskResult:taskObject];
        }
        if(!data){
            LLog(LoganTypeLogan, [NSString stringWithFormat:@"upload finish:callbackData=nil"]);
            [self callComplete:complete succ:NO errorCode:LoganUploadFileServerError errorMsg:@"callback data is nil"];
            return;
        }
        LLog(LoganTypeLogan, [NSString stringWithFormat:@"upload finish:%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]]);
        
        // storage succeed task id
        NSError *err;
        NSDictionary *callBackDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&err];
        if(!err){
            BOOL success = [callBackDic[@"success"] boolValue];
            if(!success){//后端业务失败
                [self callComplete:complete succ:NO errorCode:LoganUploadFileServerError errorMsg:callBackDic[@"msg"]];
                return ;
            }else{//后端业务成功
                [self callComplete:complete succ:YES errorCode:0 errorMsg:@"上传成功"];
                if(callBackDic[@"data"] && [callBackDic[@"data"] isKindOfClass:[NSString class]]){
                    NSError *err2;
                    NSData *contentData = [callBackDic[@"data"] dataUsingEncoding:NSUTF8StringEncoding];
                    NSDictionary *contentDic = [NSJSONSerialization JSONObjectWithData:contentData options:NSJSONReadingAllowFragments error:&err2];
                    if(!err2){
                        if(contentDic[@"taskid"]){
                            [LoganUtils storeSucceedTaskId:[NSString stringWithFormat:@"%@",contentDic[@"taskid"]] withDate:date];
                        }
                    }
                }
            }
        }
    }
}

- (void)callComplete:(LoganUploadBlock)block succ:(BOOL)succ errorCode:(int)errorCode errorMsg:(NSString *)errorMsg {
    if (block) {
        dispatch_async(dispatch_get_main_queue(), ^{
            block(succ, errorCode, errorMsg);
        });
    }
}


#pragma mark  --------  task retry



#pragma mark  --------  helpers

- (dispatch_queue_t)uploadQueue{
    if (!_uploadQueue) {
        _uploadQueue = dispatch_queue_create("com.dianping.loganupload", DISPATCH_QUEUE_SERIAL);
    }
    return _uploadQueue;
}

- (BOOL)isAutoUpload:(BOOL)isWifi{
    NVNetworkReachability status = NVGetAccurateNetworkReachability();
    if (isWifi) {
        if (status == NVNetworkReachabilityWifi) {
            return YES;
        }
    }else{
        if (status != NVNetworkReachabilityNone) {
            return YES;
        }
    }
    return NO;
}

- (void)uploadFailedTasks{
    [self.taskManager forceUploadTasks];
}


@end
