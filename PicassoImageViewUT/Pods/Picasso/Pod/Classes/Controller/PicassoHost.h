//
//  PicassoHost.h
//  Pods
//
//  Created by 纪鹏 on 2017/5/26.
//
//

#import <UIKit/UIKit.h>

@class JSValue;

@interface PicassoHost : NSObject

/**
 host所在页面的viewController
 */
@property (nonatomic, weak) UIViewController *pageController;

/**
 host执行的js script的名称，可用于调试区分不同的host
 */
@property (nonatomic, copy) NSString *alias;

/**
 host默认初始方法。 同一controller如需重新创建host，需先调用[host destroyHost]清理原host

 @param script controller对应的js代码
 @param options 创建js中controller实例的可选参数
 @param intentData 创建js中controller实例的数据，区分于Options
 @return 创建的host实例
 */
+ (instancetype)hostWithScript:(NSString *)script options:(NSDictionary *)options data:(NSDictionary *)intentData;

/**
 调用js中controller实例的方法

 @param method js中controller实例的方法名
 @param args 方法参数
 */
- (void)callControllerMethod:(NSString *)method argument:(NSDictionary *)args;

/**
 调用js中controller实例的方法
 同步调用，需在js线程中执行。使用PCSRunOnBridgeThread
 
 @param method js中controller实例的方法名
 @param args 方法参数
 @return js方法执行的返回值
 */
- (JSValue *)syncCallControllerMethod:(NSString *)method argument:(NSDictionary *)args;

/**
 controller销毁时调用该方法清理host
 */
- (void)destroyHost;

@end
