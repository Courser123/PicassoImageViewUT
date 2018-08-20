//
//  PicassoJSBridgeProtocol.h
//  Picasso
//
//  Created by 纪鹏 on 2018/4/16.
//

#import <Foundation/Foundation.h>

@class JSValue;
@class JSContext;

typedef JSValue*(^PCSJSCallNative)(NSString *hostId, NSString *moduleName ,NSString *methodName, NSDictionary *args, NSString *callbackId);
typedef void(^PCSViewCommand)(NSString *hostId, NSString *viewId, NSString *action, id params);
typedef JSValue*(^PCSRequire)(NSString *jsModuleName);
typedef JSValue*(^PCSSizeToFit)(NSDictionary *modelDic);

typedef void(^PCSExceptionHandler)(JSContext *context, JSValue *exception);

@protocol PicassoJSBridgeProtocol <NSObject>

- (void)registerNativeBridge:(PCSJSCallNative)callNative;
- (void)registerNativeRequire:(PCSRequire)require;
- (void)registerNativeSizeToFit:(PCSSizeToFit)sizetofit;

- (void)executeJS:(NSString *)js withSourceUrl:(NSURL *)url exceptionHandler:(PCSExceptionHandler)handler;

- (JSValue *)callJSMethod:(NSString *)method arguments:(NSArray *)args exceptionHandler:(PCSExceptionHandler)handler;

- (void)injectObject:(id)obj name:(NSString *)name;


@end
