//
//  PicassoViewMethod.m
//  clogan
//
//  Created by 纪鹏 on 2017/10/23.
//

#import "PicassoViewMethod.h"
#import "PicassoHostManager.h"
#import "PicassoVCHost.h"
#import "PicassoVCHost+Private.h"
#import "UIView+Picasso.h"
#import "PicassoViewWrapperFactory.h"
#import "PicassoModel.h"
#import "PicassoUtility.h"

@interface PicassoViewMethod ()
@property (nonatomic, copy) NSString *hostId;
@property (nonatomic, copy) NSString *viewId;
@property (nonatomic, copy) NSString *methodName;
@property (nonatomic, strong) NSDictionary *args;
@end

@implementation PicassoViewMethod

- (instancetype)initWithHostId:(NSString *)hostId viewId:(NSString *)viewId method:(NSString *)methodName arguments:(NSDictionary *)args {
    if (self = [super init]) {
        _hostId = hostId;
        _viewId = viewId;
        _methodName = methodName;
        _args = args;
    }
    return self;
}

- (void)invoke {
    PicassoHost *host = [PicassoHostManager hostForId:self.hostId];
    if (![host isKindOfClass:[PicassoVCHost class]]) {
        return;
    }
    PicassoVCHost *vcHost = (PicassoVCHost *)host;
    UIView *commandView = [vcHost viewForId:self.viewId];
    if ([commandView class] != [PicassoViewWrapperFactory viewClassByType:commandView.pModel.type]) {
        return;
    }
    SEL selector = [PicassoViewWrapperFactory selectorWithViewClass:[commandView class] method:self.methodName];
    NSMethodSignature *methodSignature = [commandView methodSignatureForSelector:selector];
    if (!methodSignature) {
        return;
    }
    
    NSUInteger argsNumber = methodSignature.numberOfArguments - 2;
    if (argsNumber > 1) {
        return;
    }
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    invocation.selector = selector;
    invocation.target = commandView;
    if (argsNumber >= 1) {
        NSDictionary *arguments = self.args?:@{};
        [invocation setArgument:&arguments atIndex:2];
    }
//    PicassoCallBack *callback = nil;
//    if (argsNumber >= 2) {
//        if (self.callbackId.length > 0) {
//            callback = [PicassoCallBack callbackWithHost:host callbackId:self.callbackId];
//        }
//        [invocation setArgument:&callback atIndex:3];
//    }
    [invocation retainArguments];
    @try {
        [invocation invoke];
    } @catch (NSException *exception) {
        if ([PicassoUtility isDebug]) {
            @throw exception;
        }
    }
}

@end
