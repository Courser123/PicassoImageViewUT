//
//  PicassoJSCoreBridge.m
//  Pods
//
//  Created by 纪鹏 on 2017/5/10.
//
//

#import "PicassoJSCoreBridge.h"
#import "PicassoUtility.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "PicassoLog.h"
#import "PicassoJSObject.h"
#import "PicassoDebugMode.h"
#import "NSString+JSON.h"
#import "PicassoUtility.h"
#import "NVCodeLogger.h"

@interface PicassoJSCoreBridge ()

@property (nonatomic, strong) JSContext *jscontext;

@end

@implementation PicassoJSCoreBridge

- (instancetype)init {
    if (self = [super init]) {
        _jscontext = [[JSContext alloc] init];
        __weak typeof(self) weakSelf = self;
        _jscontext[@"PCSEnvironment"] = [PicassoUtility getEnvironment];
        _jscontext[@"nativeSetTimeout"] = ^( JSValue *timeout, JSValue *handleId) {
            [weakSelf performSelector: @selector(triggerTimeout:) withObject:^() {
                [weakSelf callJSMethod:@"callTimerCallback" arguments:handleId?@[handleId]:@[] exceptionHandler:nil];
            } afterDelay:[timeout toDouble] / 1000];
        };
        _jscontext[@"picassoLog"] = ^(NSString *msg, NSInteger tag){
            [[PicassoDebugMode instance] logToPicassoServerWithType:tag content:msg];
            PLog(@"jsLog: %@",msg);
        };
    }
    return self;
}

- (void)logWithException:(JSValue *)exception {
    [[PicassoDebugMode instance] logToPicassoServerWithType:PicassoLogTagError content:[PicassoUtility errorStringWithException:exception]];
}

- (void)executeJS:(NSString *)js withSourceUrl:(NSURL *)url exceptionHandler:(PCSExceptionHandler)handler {
    [self.jscontext evaluateScript:js withSourceURL:url];
    if (handler && self.jscontext.exception) {
        handler(self.jscontext, self.jscontext.exception);
        [self logWithException:self.jscontext.exception];
        self.jscontext.exception = nil;
    }
}

- (void)registerNativeBridge:(PCSJSCallNative)callNative {
    JSValue *(^callNativeBlock)(JSValue *, JSValue *, JSValue *, JSValue *, JSValue *) = ^ JSValue*(JSValue *host, JSValue *moduleName ,JSValue *methodName, JSValue *args, JSValue *callbackId){
        NSString *hostId = [host toString];
        NSString *module = [moduleName toString];
        NSString *method = [methodName toString];
        NSDictionary *arguments = [args toDictionary];
        NSString *callback = [callbackId toString];
        return callNative(hostId, module, method, arguments, callback);
    };
    self.jscontext[@"nativeBridge"] = callNativeBlock;
}

- (void)registerNativeRequire:(PCSRequire)require {
    JSValue *(^requireBlock)(JSValue *) = ^JSValue*(JSValue *jsModule) {
        NSString *name = [jsModule toString];
        return require(name);
    };
    self.jscontext[@"nativeRequire"] = requireBlock;
}

- (void)registerNativeSizeToFit:(PCSSizeToFit)sizetofit {
    self.jscontext[@"nativeSizeToFit"] = ^JSValue*(JSValue *modelValue) {
        NSDictionary *modelDic = [modelValue toDictionary];
        return sizetofit(modelDic);
    };
}

- (JSValue *)callJSMethod:(NSString *)method arguments:(NSArray *)args exceptionHandler:(PCSExceptionHandler)handler
{
    JSValue *picassoCore = [self.jscontext objectForKeyedSubscript:@"Picasso"];
    JSValue *retValue = [picassoCore invokeMethod:method withArguments:args];
    if (handler && self.jscontext.exception) {
        handler(self.jscontext, self.jscontext.exception);
        [self logWithException:self.jscontext.exception];
        self.jscontext.exception = nil;
    }
    return retValue;
}

- (void)injectObject:(id)obj name:(NSString *)name {
    if (obj && name.length > 0) {
        self.jscontext[name] = obj;
    }
}

- (void)triggerTimeout:(void(^)(void))block
{
    block();
}

@end
