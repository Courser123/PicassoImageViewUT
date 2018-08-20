//
//  SwitcherTask.h
//  Pods
//
//  Created by lmc on 2017/1/10.
//
//

#import <Foundation/Foundation.h>

@class SwitcherTask;
typedef void (^SwitcherTaskSuccessBlock)(SwitcherTask *task, id result);
typedef void (^SwitcherTaskFailBlock)(SwitcherTask *task, id error);

@interface SwitcherTask : NSObject

/**
 * 请求的URL
 */
@property (nonatomic, strong) NSString *url;

/**
 * 请求的参数
 */
@property (nonatomic, strong) NSDictionary *parameters;

/**
 * 请求成功回调
 */
@property (nonatomic, copy) SwitcherTaskSuccessBlock success;

/**
 * 请求失败回调
 */
@property (nonatomic, copy) SwitcherTaskFailBlock fail;

/**
 * 创建一个新的Task
 */
+ (id)task;

/**
 * 开始任务
 */
- (void)startRequest;

@end
