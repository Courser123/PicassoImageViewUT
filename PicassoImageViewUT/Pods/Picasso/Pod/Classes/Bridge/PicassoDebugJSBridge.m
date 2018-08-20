//
//  PicassoDebugJSBridge.m
//  Picasso
//
//  Created by 纪鹏 on 2018/4/16.
//

#import "PicassoDebugJSBridge.h"
#import "PicassoDebuggerSocketClient.h"
#import "PicassoUtility.h"
#import "PicassoDebugMode.h"
#import "PicassoLog.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "NSString+JSON.h"

@interface PicassoDebugJSBridge ()
@property (nonatomic, strong) PicassoDebuggerSocketClient *socketClient;
@end

@implementation PicassoDebugJSBridge

- (instancetype)init {
    if (self = [super init]) {
        _socketClient = [[PicassoDebuggerSocketClient alloc] init];
        sleep(4);
        [_socketClient injectJSConstWithDictionary:@{@"PCSEnvironment":[PicassoUtility getEnvironment]}];   
        [_socketClient injectJSFunction:@"picassoLog" withBlock:^(NSString *msg, NSInteger tag){
            [[PicassoDebugMode instance] logToPicassoServerWithType:tag content:msg];
            PLog(@"jsLog: %@",msg);
        }];
    }
    return self;
}

- (void)registerNativeBridge:(PCSJSCallNative)callNative {
    [self.socketClient injectJSFunction:@"nativeBridge" withBlock:(id)^(NSString *hostId, NSString *module ,NSString *method, NSDictionary *arguments, NSString *callbackId){
        return callNative(hostId, module, method, arguments, callbackId);
    }];
}

- (void)registerNativeRequire:(PCSRequire)require {
    [self.socketClient injectJSFunction:@"nativeRequire" withBlock:(id)^(NSString *jsModule){
        return require(jsModule);
    }];
}

- (void)registerNativeSizeToFit:(PCSSizeToFit)sizetofit {
    
}

- (void)executeJS:(NSString *)js withSourceUrl:(NSURL *)url exceptionHandler:(PCSExceptionHandler)handler {
    [self.socketClient executeScript:js name:url.absoluteString completeBlock:^(NSError * _Nonnull error) {
        NSLog(@"socketClient executeScript success");
    }];
}

- (JSValue *)callJSMethod:(NSString *)method arguments:(NSArray *)args exceptionHandler:(PCSExceptionHandler)handler {
    __block JSValue *retValue = nil;
    dispatch_semaphore_t scriptSem = dispatch_semaphore_create(0);
    [self.socketClient executeJSCall:method arguments:args callback:^(NSString *  _Nonnull result, NSError * _Nonnull error) {
        NSDictionary *resultDic = [result JSONValue];
        JSContext *jscontext = [[JSContext alloc] init];
        retValue = [JSValue valueWithObject:resultDic ?:result inContext:jscontext];
        dispatch_semaphore_signal(scriptSem);
    }];
    dispatch_semaphore_wait(scriptSem, DISPATCH_TIME_FOREVER);
    return retValue;
}

- (void)injectObject:(id)obj name:(NSString *)name {
    if (obj && name.length > 0) {
        [self.socketClient injectJSConstWithDictionary:@{name:obj}];
    }
}


@end
