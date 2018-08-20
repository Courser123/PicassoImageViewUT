//
//  LoganLogInput.h
//  NVNetworkLogger
//
//  Created by yxn on 2017/4/13.
//  Copyright © 2017年 xiangnan.yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Logan.h"

typedef void (^LoganFlashBlock)();

@interface LoganLogInput : NSObject

@property(nonatomic, strong)dispatch_queue_t _Nullable    logQueue;

- (void)writeLog:(nonnull NSString *)log type:(LoganType)type time:(NSTimeInterval)time localTime:(NSTimeInterval)localTime threadName:(nullable NSString *)threadName threadNum:(NSInteger)threadNum threadIsMain:(BOOL)threadIsMain callStack:(nullable NSString *)callStack snapShot:(nullable NSString *)snapShot tag:(nullable NSString *)tag;

- (void)flash;
- (void)flashWithComplete:(nonnull LoganFlashBlock)complete;

- (void)clearAllLogs;

@end
