//
//  PicassoWeakProxy.m
//  ImageViewBase
//
//  Created by welson on 2018/3/6.
//

#import "PicassoWeakProxy.h"

@interface PicassoWeakProxy ()

@property (nonatomic, weak) id target;

@end

@implementation PicassoWeakProxy

#pragma mark Life Cycle

+ (instancetype)weakProxyForObject:(id)targetObject {
    PicassoWeakProxy *weakProxy = [PicassoWeakProxy alloc];
    weakProxy.target = targetObject;
    return weakProxy;
}


#pragma mark Forwarding Messages

- (id)forwardingTargetForSelector:(SEL)selector {
    return _target;
}


#pragma mark - NSWeakProxy Method Overrides
#pragma mark Handling Unimplemented Methods

- (void)forwardInvocation:(NSInvocation *)invocation {
    void *nullPointer = NULL;
    [invocation setReturnValue:&nullPointer];
}


- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    return [NSObject instanceMethodSignatureForSelector:@selector(init)];
}

@end
