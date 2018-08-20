//
//  PicassoVCHost.h
//  CocoaAsyncSocket
//
//  Created by 纪鹏 on 2017/7/14.
//

#import "PicassoHost.h"

@class PicassoModel;
@class PicassoView;

typedef NS_ENUM(NSInteger, PicassoVCState) {
    PicassoVCStateLoad,
    PicassoVCStateAppear,
    PicassoVCStateDisappear,
    PicassoVCStateDistroy
};

/// childVC dismiss时的回调
typedef void(^PicassoChildVCDismissBlock)(PicassoView *view);


@interface PicassoVCHost : PicassoHost

@property (nonatomic, weak) PicassoView *pcsView;
@property (atomic, strong) PicassoModel *model;

- (void)updateVCState:(PicassoVCState)state;
- (void)notifyViewFrameChanged:(NSDictionary *)options;
- (void)notifyLayoutFinished;

/// 键盘高度变化，callControllerMethod
- (void)keybordWillChangeToHeight:(CGFloat)height;

/**
 调用js layout方法，获取pmodel后渲染view
 */
- (void)layout;
- (void)dispatchViewEventWithViewId:(NSString *)viewId action:(NSString *)action params:(NSDictionary *)params;
- (JSValue *)syncDispatchViewEventWithViewId:(NSString *)viewId action:(NSString *)action params:(NSDictionary *)params;

/**
 *  计算并渲染 ChildVC
 *  @params
 *      view    PicassoView
 *  @params
 *      vcId    childVC ID
 *  @params
 *      block   渲染结束后的回调
 */
- (void)layoutChildPicassoView:(PicassoView *)view withId:(NSInteger)vcId didPaintBlock:(dispatch_block_t)block;

/**
 *  直接call childVC中的方法
 *  @params
 *      vcId    需调用的childVC的Id
 *  @params
 *      method  方法名
 *  @params
 *      params  参数
 */
- (void)callChildVCWithId:(NSInteger)vcId method:(NSString *)method params:(NSDictionary *)params;

/**
 *  为对应的childVC添加dismiss回调
 *  @params
 *      block   回调block
 *  @params
 *      vcId    childVC的id
 */
- (void)addDismissBlock:(PicassoChildVCDismissBlock)block withChildVC:(NSInteger)vcId;

/**
 *  dismiss 对应的 childVC
 *  @params
 *      vcId    childVC的id
 */
- (void)dismissChildVC:(NSInteger)vcId;

@end
