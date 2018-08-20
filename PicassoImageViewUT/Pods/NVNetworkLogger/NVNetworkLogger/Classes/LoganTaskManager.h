//
//  LoganTaskManager.h
//  NVNetworkLogger
//
//  Created by yxn on 2017/10/11.
//

#import <Foundation/Foundation.h>
#import "LoganLogOutput.h"

typedef enum : NSUInteger {
    TaskUploading,
    TaskUploadSuccess,
    TaskUploadFail,
    TaskUploadFinish
} TaskUploadStatus;


@interface LoganTaskObject :NSObject

@property (nonatomic, assign) TaskUploadStatus taskStatus;

+ (LoganTaskObject *)taskObjectWithDate:(NSString *)date
                                 taskID:(NSString *)taskID
                                 isWifi:(BOOL)isWifi
                               fileSize:(long)fileSize
                             taskStatus:(TaskUploadStatus)taskStatus;
@end


@interface LoganTaskManager : NSObject

- (instancetype)initWithOutput:(LoganLogOutput *)output;

- (void)addTask:(LoganTaskObject *)taskObject;
- (LoganTaskObject *)taskObjectWithTaskID:(NSString *)taskID;
- (void)routeTaskResult:(LoganTaskObject *)object;
- (void)forceUploadTasks;
@end
