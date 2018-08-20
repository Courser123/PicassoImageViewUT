//
//  LoganTaskManager.m
//  NVNetworkLogger
//
//  Created by yxn on 2017/10/11.
//

#import "LoganTaskManager.h"
#import "Logan.h"

static NSString * const LOGANTASKKEY = @"LOGANTASKKEY";
static NSString * const LOGANCACHEKEY = @"LOGANCACHEKEY";

@interface LoganTaskObject ()

@property (nonatomic, copy) NSString *date;
@property (nonatomic, copy) NSString *taskID;
@property (nonatomic, assign) BOOL isWifi;
@property (nonatomic, assign) long fileSize;
@property (nonatomic, assign) NSUInteger maxRetryCount;

@end

@implementation LoganTaskObject

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        _date = [aDecoder decodeObjectForKey:@"date"];
        _taskID = [aDecoder decodeObjectForKey:@"taskID"];
        _isWifi = [aDecoder decodeBoolForKey:@"isWifi"];
        _fileSize = [aDecoder decodeDoubleForKey:@"fileSize"];
        _taskStatus = [aDecoder decodeIntegerForKey:@"taskStatus"];
        _maxRetryCount = [aDecoder decodeIntegerForKey:@"maxRetryCount"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.date forKey:@"date"];
    [aCoder encodeObject:self.taskID forKey:@"taskID"];
    [aCoder encodeBool:self.isWifi forKey:@"isWifi"];
    [aCoder encodeDouble:self.fileSize forKey:@"fileSize"];
    [aCoder encodeInteger:self.taskStatus forKey:@"taskStatus"];
    [aCoder encodeInteger:self.maxRetryCount forKey:@"maxRetryCount"];
}

+(LoganTaskObject *)taskObjectWithDate:(NSString *)date
                              taskID:(NSString *)taskID
                              isWifi:(BOOL)isWifi
                            fileSize:(long)fileSize
                          taskStatus:(TaskUploadStatus)taskStatus{
    LoganTaskObject *taskObject = [LoganTaskObject new];
    taskObject.date = date;
    taskObject.taskID = taskID;
    taskObject.isWifi = isWifi;
    taskObject.fileSize = fileSize;
    taskObject.taskStatus = taskStatus;
    return taskObject;
}

@end

@interface LoganTaskManager ()

@property (nonatomic, strong) NSMutableDictionary *taskManager;
@property (nonatomic, strong) NSUserDefaults *defaults;
@property (nonatomic, weak) LoganLogOutput *output;

@end

@implementation LoganTaskManager

- (instancetype)initWithOutput:(LoganLogOutput *)output{
    if (self =[super init]) {
        _output = output;
        _defaults = [[NSUserDefaults alloc] initWithSuiteName:LOGANCACHEKEY];
        [self p_initial];
    }
    return self;
}

- (void)p_initial{
    NSData *taskManagerData = [self.defaults objectForKey:LOGANTASKKEY];
    NSMutableDictionary *dic = [NSKeyedUnarchiver unarchiveObjectWithData:taskManagerData];
    if (dic) {
        self.taskManager = dic.mutableCopy;
    }else{
        self.taskManager = [NSMutableDictionary new];
    }
    [self performSelector:@selector(uploadFailedTasks) withObject:nil afterDelay:3];
}

- (void)uploadFailedTasks{
    @synchronized(self.taskManager){
        if (self.taskManager.allKeys.count == 0) {
            return;
        }
        __weak typeof(self) weakSelf = self;
        NSArray *valuesArr = [NSArray arrayWithArray:self.taskManager.allValues];
        [valuesArr enumerateObjectsUsingBlock:^(LoganTaskObject *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (obj.taskStatus == TaskUploadSuccess) {
                return;
            }
            if (obj.maxRetryCount == 2) {
                obj.taskStatus = TaskUploadFinish;
                return;
            }
            obj.taskStatus = TaskUploading;
            obj.maxRetryCount ++;
            [strongSelf.output uploadLogWithDate:obj.date taskID:obj.taskID isWifi:obj.isWifi fileSize:obj.fileSize isForce:YES];
        }];
        [self updateCache];
    }
}

- (void)forceUploadTasks{
    @synchronized(self.taskManager){
        if (self.taskManager.allKeys.count == 0) {
            return;
        }
        __weak typeof(self) weakSelf = self;
        NSArray *valuesArr = [NSArray arrayWithArray:self.taskManager.allValues];
        [valuesArr enumerateObjectsUsingBlock:^(LoganTaskObject *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (obj.taskStatus == TaskUploadSuccess || obj.taskStatus == TaskUploading) {
                return;
            }
            if(obj.maxRetryCount == 2){
                obj.taskStatus = TaskUploadFinish;
                return;
            }
            obj.taskStatus = TaskUploading;
            obj.maxRetryCount ++;
            [strongSelf.output uploadLogWithDate:obj.date taskID:obj.taskID isWifi:obj.isWifi fileSize:obj.fileSize isForce:YES];
        }];
        [self updateCache];
    }
}

- (void)addTask:(LoganTaskObject *)taskObject{
    if (!taskObject || taskObject.taskID.length == 0) {
        return;
    }
    @synchronized (self.taskManager) {
        if ([self.taskManager.allKeys containsObject:taskObject.taskID]) {
            return;
        }
        [self.taskManager setObject:taskObject forKey:taskObject.taskID];
        taskObject.maxRetryCount = 0;
        [self updateCache];
    }
}

- (LoganTaskObject *)taskObjectWithTaskID:(NSString *)taskID{
    if (!taskID.length) {
        return nil;
    }
    return [self.taskManager objectForKey:taskID];
}

- (void)updateCache{
    @synchronized(self.defaults){
        if (self.taskManager.allKeys.count == 0) {
            [self.defaults removeObjectForKey:LOGANTASKKEY];
            return;
        }
        NSData *taskManagerData = [NSKeyedArchiver archivedDataWithRootObject:self.taskManager];
        [self.defaults setObject:taskManagerData forKey:LOGANTASKKEY];
    }
}

- (void)routeTaskResult:(LoganTaskObject *)object{
    if (object.taskStatus == TaskUploadSuccess || object.taskStatus == TaskUploadFinish) {
        @synchronized(self.taskManager){
            [self.taskManager removeObjectForKey:object.taskID];
            [self updateCache];
        }
    }
}

@end
