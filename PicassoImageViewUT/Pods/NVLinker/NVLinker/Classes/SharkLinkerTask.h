//
//  SharkLinkerTask.h
//  NVLinker
//
//  Created by JiangTeng on 2018/3/1.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,SharkFailOverType){
    SharkFailOverDefault         = 0,     //使用默认设置。Get\Head请求有failover效果,Post\Delete\Put等请求无failover效果.
    SharkFailOverTypeDisable     = 1,     //不使用failover
    SharkFailOverTypeEnable         = 2,  //一定使用failover，使用该参数要确保后台要支持幂等
};


@class SharkLinkerTask;
typedef void (^SharkLinkerTaskSuccessBlock)(SharkLinkerTask *task, id result);
typedef void (^SharkLinkerTaskFailBlock)(SharkLinkerTask *task, id error);


@interface SharkLinkerTask : NSObject
/**
 请求request,shark将不会对request做任何修改比如:beta环境的切换等工作,只支持Mock。
 */
@property (nonatomic, strong) NSURLRequest *request;
/**
 HTTP Method，一般为"GET"和"POST"
 必须为大写
 如果不指定则为"GET"
 */
@property (nonatomic, retain) NSString *method;

/**
 url为最基本的参数，必须指定
 */
@property (nonatomic, retain) NSString *url;

/**
  请求成功时回调
 */
@property (nonatomic, copy) SharkLinkerTaskSuccessBlock success;
/**
 请求失败时回调
 */
@property (nonatomic, copy) SharkLinkerTaskFailBlock fail;

/**
 请求完成时在那个queue中回调，如果为Null 则在main queue中回调
 */
@property (nonatomic, strong) dispatch_queue_t completionQueue;

/**
 设置参数
 */
@property (nonatomic, strong) NSDictionary *parameters;

/**
 *  禁止cat上报，YES不上报，NO 上报，默认NO
 */
@property (nonatomic, assign) BOOL disableCat;

/**
 * 指定CIP通道内部是否可以走failover逻辑
 * 默认是SharkFailOverDefault
 * 默认规则:Get\Head请求有failover效果,Post\Delete\Put等请求无failover效果.
 */
@property(nonatomic, assign) SharkFailOverType failOverType;

/**
 超时时间，默认走shark线上配置。2g 30s，其他25s
 */
@property (nonatomic, assign) int timeout;


/**
 HTTP Header，优先级最高，可以复写如User-Agent等默认值
 */
@property (nonatomic, retain) NSDictionary<NSString *, NSString *> *requestHeaders;

/**
 HTTP Body，一般用于multipart-form格式
 */
@property (nonatomic, retain) NSData *postData; // multipart-form


//get
/**
 返回的HTTP Status Code
 连接失败的情况下为0
 */
@property (nonatomic, assign, readonly) NSInteger statusCode;

/**
 返回的HTTP Header
 */
@property (strong, nonatomic, readonly) NSDictionary *responseHeaders;

/**
 开始异步任务
 一个任务只能开始一次
 异步请求
 */
- (void)start;

/**
 取消运行中的任务
 被取消的任务不可以被再执行
 */
- (void)cancel;
@end
