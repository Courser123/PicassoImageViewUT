//
//  PicassoAnchorEntity.h
//  picasso
//
//  Created by 纪鹏 on 2018/1/18.
//

#import <Foundation/Foundation.h>

@interface PicassoMonitorEntity : NSObject


/**
 上报的标识名，需要在end:report:之前赋值
 */
@property (nonatomic, copy) NSString * _Nullable name;

- (void)prepare:(nonnull NSString *)anchor;

- (void)start:(nonnull NSString *)anchor;

- (void)end:(nonnull NSString *)anchor;

- (void)end:(nonnull NSString *)anchor reportCode:(int)code;
- (void)end:(nonnull NSString *)anchor reportSuccess:(BOOL)success;

- (nonnull NSString *)wrapUniqued:(nonnull NSString *)name;

- (nonnull NSString *)wrapMethodInvokeAnchorForName:(nonnull NSString *)methodName arg1:(nullable id)arg1 arg2:(nullable id)arg2;
/**
 * 整体初始化的时间
 */
+ (nonnull NSString *)INIT_ALL;
/**
 * 注入原生方法的时间
 */
+ (nonnull NSString *)INIT_INJECT;
/**
 * 初始化Mapping的时间
 */
+ (nonnull NSString *)INIT_MAPPING;
/**
 * 初始化ModuleJS的时间
 */
+ (nonnull NSString *)INIT_MODULE_JS;
/**
 * 加载matrix文件的时间
 */
+ (nonnull NSString *)INIT_MATRIX_JS;
/**
 * 创建JS Controller的时间
 */
+ (nonnull NSString *)CONTROLLER_CREATE;
/**
 * 执行Controller方法的时间，格式为"controller_invoke:%methodName%,args:%arg1,arg2...%@%uniqueId%"
 * methodName为本次执行的方法名称，arg1,arg2表示参数，uniqueId标记本次执行的唯一标识
 */
+ (nonnull NSString *)CONTROLLER_INVOKE_PREFIX;
/**
 * 销毁JS Controller的时间
 */
+ (nonnull NSString *)CONTROLLER_DESTROY;

+ (nonnull NSString *)PRECOMPUTE;
/**
 * VC页面整体渲染的时间，从加载JS代码到View渲染结束
 */
+ (nonnull NSString *)VC_LOAD;
/**
 * VC页面执行一次layout的时间，从call layout到最终渲染结束
 */
+ (nonnull NSString *)VC_LAYOUT;
/**
 * VC页面生成PModel的时间
 */
+ (nonnull NSString *)VC_PMODEL;

/// child VC页面执行一次 layout 的时间，从 call layout 到最终渲染结束
+ (nonnull NSString *)VC_LAYOUT_CHILD;

@end
