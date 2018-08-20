//
//  PicassoJSContext.m
//  Pods
//
//  Created by Stephen Zhang on 16/7/7.
//
//
#import "PicassoJSContext.h"
#import "PicassoJSObject.h"
#import "NVCodeLogger.h"
#import "PicassoUtility.h"
#import "PicassoLog.h"
#import <dlfcn.h>
#import "PicassoDebugMode.h"
#import "PicassoCoreResourceManager.h"
#import "PicassoJSModuleManager.h"
#import "PicassoDefine.h"

@interface PicassoJSContext ()

@property (nonatomic, strong) NSMutableDictionary * evaluatedJsDic;
@property (nonatomic, strong) NSMutableArray *loadedJS;

@end

@implementation PicassoJSContext

+ (instancetype)defaultJSContext {
    PCSAssertViewComputeThread();
    static PicassoJSContext * instance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        instance = [PicassoJSContext new];
        instance.evaluatedJsDic = [NSMutableDictionary new];
        instance.loadedJS = [NSMutableArray new];
        [instance preload];
    });
    return instance;
}

- (void)initEnvironment {
    self[@"PCSEnvironment"] = [PicassoUtility getEnvironment];
}

- (void)preload {
    // 初始化环境变量
    [self initEnvironment];
    //添加log
    self[@"picassoLog"] = ^(NSString *msg, NSInteger tag){
        [[PicassoDebugMode instance] logToPicassoServerWithType:tag content:msg];
        PLog(@"jsLog: %@",msg);
    };
    //绑定JSObject
    PicassoJSObject *JSObject = [PicassoJSObject new];
    self[@"Picasso"] = JSObject;
    
    __weak typeof(self) weakself = self;
    self[@"nativeRequire"] = ^JSValue *(NSString *name) {
        NSString *jsscript = [weakself _wrapperScriptForModuleName:name];
        if (jsscript.length > 0) {
            [weakself evaluateScript:jsscript withSourceURL:[NSURL URLWithString:name]];
            return [JSValue valueWithBool:YES inContext:[JSContext currentContext]];
        } else {
            return [JSValue valueWithBool:NO inContext:[JSContext currentContext]];
        }
    };
    //预加载基础定义JS
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource: @"main" ofType: @"js"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:[PicassoCoreResourceManager pathForCoreJS]]) {
        path = [PicassoCoreResourceManager pathForCoreJS];
    }
    NSString *mainjs = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    NSAssert(mainjs.length > 0, @"Picasso: view.js is missing");
    self.exceptionHandler = ^(JSContext *context, JSValue *exception) {
        context.exception = exception;
        NSString *logStr = [PicassoUtility errorStringWithException:exception];
        NVAssert(false, @"PicassoJSContext error: %@", logStr);
        [[PicassoDebugMode instance] logToPicassoServerWithType:PicassoLogTagError content:logStr];
    };
    [self evaluateScript:mainjs withSourceURL:[NSURL URLWithString:@"main.js"]];
}

- (NSString *)_wrapperScriptForModuleName:(NSString *)name {
    if (name.length == 0) {
        NSLog(@"invalid name");
        return @"";
    }
    NSString *oriScript = [PicassoJSModuleManager jsScriptForModuleName:name];
    return [NSString stringWithFormat:@"registerModule('%@',\
                                            (function(__module){    \
                                                return (function(module, exports, require){ \n\
                                                            %@; \
                                                            return module.exports;\
                                                        })(__module, __module.exports, Picasso.require) \
                                            })({exports:{}}))", name, oriScript];
}

@end
