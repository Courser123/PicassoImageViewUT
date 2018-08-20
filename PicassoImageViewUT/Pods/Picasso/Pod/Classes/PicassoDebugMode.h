//
//  PicassoDebugMode.h
//  Pods
//
//  Created by Stephen Zhang on 16/6/27.
//
//
#import "PicassoLog.h"

@class PicassoDebugMode;
//文件变化通知
#define PicassoDebugFileChangeNotification @"PicassoDebugFileChangeNotification"

@interface PicassoDebugMode : NSObject

@property (nonatomic, assign, readonly) BOOL debugModel;
@property (nonatomic, assign, readonly) BOOL onLiveLoad;

+(PicassoDebugMode *)instance;

- (void)startMonitorWithIp:(NSString *)serverIp;

- (void)startMonitorWithToken:(NSString *)token;

- (void)loadFile;

- (void)closeFile;

- (void)logToPicassoServerWithType:(PicassoLogTag)type content:(NSString *)msg;

@end
