//
//  PicassoModuleMethod.m
//  Pods
//
//  Created by 纪鹏 on 2017/5/11.
//
//

#import "PicassoModuleMethod.h"
#import "PicassoModuleFactory.h"
#import "PicassoBridgeModule.h"
#import "PicassoHostManager.h"
#import "PicassoCallBack.h"
#import "PicassoHost+Bridge.h"
#import "PicassoUtility.h"
#import "NVCodeLogger.h"

@interface PicassoModuleMethod ()
@property (nonatomic, copy) NSString *hostId;
@property (nonatomic, copy) NSString * moduleName;
@property (nonatomic, copy) NSString * methodName;
@property (nonatomic, strong) NSDictionary *args;
@property (nonatomic, copy) NSString *callbackId;
@end

@implementation PicassoModuleMethod

- (instancetype)initWithHost:(NSString *)hostId module:(NSString *)moduleName method:(NSString *)methodName arguments:(NSDictionary *)args callback:(NSString *)callbackId {
    if (self = [super init]) {
        _hostId = hostId;
        _moduleName = moduleName;
        _methodName = methodName;
        _args = args;
        _callbackId = callbackId;
    }
    return self;
}

- (JSValue *)invoke {
    
    Class moduleClass = [PicassoModuleFactory classForModuleName:self.moduleName];
    PicassoHost *host = [PicassoHostManager hostForId:self.hostId];
    PicassoBridgeModule *moduleInstance = [host moduleInstanceForClass:moduleClass];
    
    SEL selector = [PicassoModuleFactory selectorWithModule:self.moduleName method:self.methodName];
    NSMethodSignature *methodSignature = [moduleInstance methodSignatureForSelector:selector];
    if (!methodSignature) {
        return nil;
    }
    
    NSUInteger argsNumber = methodSignature.numberOfArguments - 2;
    if (argsNumber > 2) {
        return nil;
    }
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    invocation.selector = selector;
    invocation.target = moduleInstance;
    if (argsNumber >= 1) {
        NSDictionary *arguments = self.args?:@{};
        [invocation setArgument:&arguments atIndex:2];
    }
    PicassoCallBack *callback = nil;
    if (argsNumber >= 2) {
        if (self.callbackId.length > 0) {
            callback = [PicassoCallBack callbackWithHost:host callbackId:self.callbackId];
        }
        [invocation setArgument:&callback atIndex:3];
    }
    [invocation retainArguments];
    @try {
        [invocation invoke];
    } @catch (NSException *exception) {
        NVAssert(false, @"Picasso BridgeMethod Exception: module:%@, method:%@, args:%@, name:%@, reason:%@, userinfo:%@",
                        self.moduleName, self.methodName, self.args,
                        exception.name,
                        exception.reason,
                        exception.userInfo);
        if ([PicassoUtility isDebug]) {
            @throw exception;
        }
    }
    
    const char *retType = methodSignature.methodReturnType;
    if (!strcmp(retType, @encode(void))) {
        return nil;
    } else if (!strcmp(retType, @encode(id))) {
        void *retValue;
        [invocation getReturnValue:&retValue];
        id returnValue = (__bridge id)retValue;
        return [JSValue valueWithObject:[returnValue copy] inContext:[JSContext currentContext]];
    } else  {
        NSAssert(false, @"return value only support object, use NSString,NSNumber,NSDictionary etc");
        return nil;
    }
}

@end
