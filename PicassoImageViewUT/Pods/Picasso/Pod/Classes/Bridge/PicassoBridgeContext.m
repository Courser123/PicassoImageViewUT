//
//  PicassoBridgeContext.m
//  Pods
//
//  Created by 纪鹏 on 2017/5/10.
//
//

#import "PicassoBridgeContext.h"
#import "PicassoJSCoreBridge.h"
#import "PicassoModuleFactory.h"
#import "PicassoModuleMethod.h"
#import "NSObject+JSON.h"
#import "PicassoHostManager.h"
#import "PicassoView.h"
#import "PicassoBaseViewWrapper.h"
#import "PicassoVCHost.h"
#import "PicassoCallBack.h"
#import "PicassoJSModuleManager.h"
#import "PicassoJSObject.h"
#import "PicassoThreadManager.h"
#import "PicassoDefine.h"
#import "PicassoMonitorEntity.h"
#import "NVCodeLogger.h"
#import "PicassoCrashReporter.h"
#import "NSObject+pcs_JSON.h"
#import "PicassoDebugJSBridge.h"
#import "PicassoDebuggerSelectHelper.h"
#import "PicassoHost+Private.h"
#import "RACEXTScope.h"

@interface PicassoHost (Private)
@property (nonatomic, strong) PicassoMonitorEntity *monitorEntity;
@property (nonatomic, copy) NSString *jsContent;
@end

@interface PicassoBridgeContext ()

@property (nonatomic, strong) id<PicassoJSBridgeProtocol> jsbridge;
@property (nonatomic, strong) PicassoMonitorEntity *globalAnchorEntity;

@end

@implementation PicassoBridgeContext

+ (instancetype)sharedInstance {
    static PicassoBridgeContext *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[PicassoBridgeContext alloc] init];
    });
    return _instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _globalAnchorEntity = [PicassoMonitorEntity new];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDebugModelOpen) name:NSNotificationVSCodeDebuggerOpen object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDebugModelClose) name:NSNotificationVSCodeDebuggerClose object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupJSBridge {
    [_globalAnchorEntity start:PicassoMonitorEntity.INIT_ALL];
    _jsbridge = nil;
    _jsbridge = [PicassoDebuggerSelectHelper helper].isDebuggerOn ? [[PicassoDebugJSBridge alloc] init] : [[PicassoJSCoreBridge alloc] init];
    [self _loadFramework];
    [_globalAnchorEntity end:PicassoMonitorEntity.INIT_ALL];
}

- (void)onDebugModelOpen {
    [self setupJSBridge];
}

- (void)onDebugModelClose {
    PCSRunOnBridgeThread(^{
        [self setupJSBridge];
    });
}

- (PicassoJSCoreBridge *)jsbridge {
    if (![PicassoDebuggerSelectHelper helper].isDebuggerOn) {
        PCSAssertBridgeThread();
    }

    if (_jsbridge) {
        return _jsbridge;
    }
    
    [self setupJSBridge];
    return _jsbridge;
}

#pragma mark - Initialize JSCore
- (void)_loadFramework {
    [_globalAnchorEntity start:PicassoMonitorEntity.INIT_MATRIX_JS];
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"picasso-matrix" ofType:@"js"];
    NSString *mainjs = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [_jsbridge executeJS:mainjs ?: @"" withSourceUrl:[NSURL URLWithString:@"picasso-matrix"] exceptionHandler:^(JSContext *context, JSValue *exception) {
        [self _logJSErrorWithException:exception jsContent:nil jsname:@"picasso-matrix" status:@""];
    }];
    [_globalAnchorEntity end:PicassoMonitorEntity.INIT_MATRIX_JS];

    [_globalAnchorEntity start:PicassoMonitorEntity.INIT_MODULE_JS];
    NSString *picassoControllerJSPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"picasso-controller-bundle" ofType:@"js"];
    [PicassoJSModuleManager registerJSModuleWithName:@"@dp/picasso-controller" jsScript:[NSString stringWithContentsOfFile:picassoControllerJSPath encoding:NSUTF8StringEncoding error:nil]];
    
    NSString *picassoJSPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"picassojs-bundle" ofType:@"js"];
    [PicassoJSModuleManager registerJSModuleWithName:@"@dp/picasso" jsScript:[NSString stringWithContentsOfFile:picassoJSPath encoding:NSUTF8StringEncoding error:nil]];
    //debugJSCore 事先注入@dp/picasso
    if ([_jsbridge isKindOfClass:[PicassoDebugJSBridge class]]) {
        [_jsbridge executeJS:[self _wrapperScriptForModuleName:@"@dp/picasso"] withSourceUrl:[NSURL URLWithString:@"@dp/picasso"] exceptionHandler:nil];
    }
    [_globalAnchorEntity end:PicassoMonitorEntity.INIT_MODULE_JS];
    
    [_globalAnchorEntity start:PicassoMonitorEntity.INIT_INJECT];
    [self _registerGlobalFunctions];
    [_globalAnchorEntity start:PicassoMonitorEntity.INIT_INJECT];

    [_globalAnchorEntity start:PicassoMonitorEntity.INIT_MAPPING];
    [self _injectModules:[PicassoModuleFactory loadedModules]];
    [_globalAnchorEntity end:PicassoMonitorEntity.INIT_MAPPING];
}

- (void)_registerGlobalFunctions {
    __weak typeof(self) weakself = self;
    [_jsbridge registerNativeBridge:^JSValue *(NSString *hostId, NSString *moduleName, NSString *methodName, NSDictionary *args, NSString *callbackId) {
        return [weakself _invokeNativeHost:hostId module:moduleName method:methodName arguments:args callback:callbackId];
    }];
    [_jsbridge registerNativeRequire:^JSValue*(NSString *jsModuleName) {
        NSString *jsscript = [self _wrapperScriptForModuleName:jsModuleName];
        if (jsscript.length > 0) {
            [weakself.jsbridge executeJS:jsscript withSourceUrl:[NSURL URLWithString:jsModuleName] exceptionHandler:^(JSContext *context, JSValue *exception) {
                [weakself _logJSErrorWithException:exception jsContent:nil jsname:jsModuleName status:@""];
            }];
            return [JSValue valueWithBool:YES inContext:[JSContext currentContext]];
        } else {
            NVAssert(false, @"Native Require fail for moduleName:%@", jsModuleName);
            return [JSValue valueWithBool:NO inContext:[JSContext currentContext]];
        }
    }];
    [_jsbridge registerNativeSizeToFit:^JSValue *(NSDictionary *modelDic) {
        NSDictionary *sizeDic = [PicassoJSObject size_for_text:modelDic];
        return [JSValue valueWithObject:sizeDic inContext:[JSContext currentContext]];
    }];
}

- (void)_injectModules:(NSDictionary *)moduleDic {
    if (!moduleDic) {
        moduleDic = @{};
    }
    [_jsbridge injectObject:moduleDic name:@"__pcs_bridges"];
}

#pragma mark - Private JSBrige Methods
- (JSValue *)_invokeNativeHost:(NSString *)hostId module:(NSString *)moduleName method:(NSString *)methodName arguments:(NSDictionary *)args callback:(NSString *)callbackId {
    PicassoModuleMethod *method = [[PicassoModuleMethod alloc] initWithHost:hostId module:moduleName method:methodName arguments:args callback:callbackId];
    return [method invoke];
}

- (void)_executeCallbackWithHost:(NSString *)hostId callbackId:(NSString *)callbackId status:(PicassoBridgeStatus)status response:(NSDictionary *)responseData {
    PicassoHost *host = [PicassoHostManager hostForId:hostId];
    NSString *methodInfo = [host.monitorEntity wrapMethodInvokeAnchorForName:@"callback" arg1:callbackId arg2:@(status)];
    [host.monitorEntity start:methodInfo];

    NSMutableDictionary *responseStatusDic = [NSMutableDictionary new];
    NSString *bridgeStatus = @"";
    switch (status) {
        case PicassoBridgeStatusSuccess: {
            bridgeStatus = @"success";
            break;
        }
        case PicassoBridgeStatusFailure: {
            bridgeStatus = @"fail";
            break;
        }
        case PicassoBridgeStatusAction: {
            bridgeStatus = @"action";
            break;
        }
        default:
            break;
    }
    [responseStatusDic setObject:bridgeStatus forKey:@"status"];
    NSArray *arguments = @[hostId?:@"", callbackId?:@"", responseStatusDic?:@{}, responseData?:@{}];
    @weakify(self)
    [self.jsbridge callJSMethod:@"callback" arguments:arguments exceptionHandler:^(JSContext *context, JSValue *exception) {
        @strongify(self)
        [self _logJSErrorWithException:exception jsContent:host.jsContent jsname:host.alias status:[self crashStatusWithIntentData:host.intentData args:arguments]];
    }];
    [host.monitorEntity end:methodInfo];
}

- (NSString *)_wrapperScriptForModuleName:(NSString *)name {
    if (name.length == 0) {
        NSLog(@"invalid name");
        return @"";
    }
    NSString *oriScript = [PicassoJSModuleManager jsScriptForModuleName:name];
    if (oriScript.length == 0) {
        NVAssert(false, @"Picasso Require Module Empty: %@", name);
        return @"";
    }
    return [NSString stringWithFormat:@"Picasso.registerModule('%@',\
                                            (function(__module){    \
                                                return (function(module, exports, require){ \n\
                                                    %@; \
                                                    return module.exports;\
                                                })(__module, __module.exports, Picasso.require) \
                                            })({exports:{}}))", name, oriScript];
}

- (void)_logJSErrorWithException:(JSValue *)exception jsContent:(NSString *)jsContent jsname:(NSString *)jsname status:(NSString *)status {
    [[PicassoCrashReporter instance] reportCrashWithException:exception jsContent:jsContent jsname:jsname status:status];
}

- (NSString *)crashStatusWithIntentData:(id)data args:(NSArray *)args {
    NSMutableDictionary *statusDic = [NSMutableDictionary new];
    if ([data isKindOfClass:[NSString class]] || [data isKindOfClass:[NSDictionary class]]) {
        [statusDic setObject:data forKey:@"intentdata"];
    } else {
        [statusDic setObject:@{} forKey:@"intentdata"];
    }
    [statusDic setObject:(args?:@[]) forKey:@"args"];
    return [statusDic pcs_JSONRepresentation];
}

- (void)createPCWithHost:(PicassoHost *)host jsScript:(NSString *)script paramString:(NSString *)paramsStr {
    PCSRunOnBridgeThread(^{
        [host.monitorEntity start:PicassoMonitorEntity.CONTROLLER_CREATE];
        NSArray *strArr = @[
                            [NSString stringWithFormat:@"(function(context, Picasso, require){"],
                            [NSString stringWithFormat:@"       %@", script?:@""],
                            [NSString stringWithFormat:@"   }).call("],
                            [NSString stringWithFormat:@"        Picasso.prepareContext(%@),",paramsStr],
                            [NSString stringWithFormat:@"        Picasso.prepareContext(%@),",paramsStr],
                            [NSString stringWithFormat:@"        Picasso.prepareContext(%@).Picasso,", paramsStr],
                            [NSString stringWithFormat:@"        Picasso.require"],
                            [NSString stringWithFormat:@"        )"]
                            ];
        NSString *evaString = @"";
        for (NSString *str in strArr) {
            evaString = [evaString stringByAppendingString:str];
        }
        NSString *alias = host.alias ?:@"controller";
        @weakify(self);
        [self.jsbridge executeJS:evaString withSourceUrl:[NSURL URLWithString:alias] exceptionHandler:^(JSContext *context, JSValue *exception) {
            @strongify(self);
            [self _logJSErrorWithException:exception jsContent:host.jsContent jsname:host.alias status:[self crashStatusWithIntentData:host.intentData args:nil]];
        }];
        [host.monitorEntity end:PicassoMonitorEntity.CONTROLLER_CREATE];
    });
}

#pragma mark - public apis
#pragma mark - vc related methods

- (void)createPCWithHostId:(NSString *)hostId jsScript:(NSString *)script options:(NSDictionary *)options stringData:(NSString *)strData {
    PicassoHost *host = [PicassoHostManager hostForId:hostId];
    [host.monitorEntity prepare:PicassoMonitorEntity.CONTROLLER_CREATE];
    NSString *paramsStr = [NSString stringWithFormat:@"'%@', %@, %@",hostId?:@"",[self stringFromDic:options],strData];
    [self createPCWithHost:host jsScript:script paramString:paramsStr];
}

- (void)createPCWithHostId:(NSString *)hostId jsScript:(NSString *)script options:(NSDictionary *)options data:(NSDictionary *)data{
    PicassoHost *host = [PicassoHostManager hostForId:hostId];
    [host.monitorEntity prepare:PicassoMonitorEntity.CONTROLLER_CREATE];
    NSString *paramsStr = [NSString stringWithFormat:@"'%@', %@, %@",hostId?:@"",[self stringFromDic:options],[self stringFromDic:data]];
    [self createPCWithHost:host jsScript:script paramString:paramsStr];
}

- (NSString *)stringFromDic:(NSDictionary *)dic {
    return dic?[dic pcs_JSONRepresentation]:@"{}";
}

- (void)destroyPCWithHostId:(NSString *)hostId {
    PicassoHost *host = [PicassoHostManager hostForId:hostId];
    PCSRunOnBridgeThread(^{
        [host.monitorEntity start:PicassoMonitorEntity.CONTROLLER_DESTROY];
        NSArray *arguments = @[hostId?:@""];
        @weakify(self)
        [self.jsbridge callJSMethod:@"destroyPC" arguments:arguments exceptionHandler:^(JSContext *context, JSValue *exception) {
            @strongify(self)
            [self _logJSErrorWithException:exception jsContent:host.jsContent jsname:host.alias status:[self crashStatusWithIntentData:host.intentData args:arguments]];
        }];
        [host.monitorEntity end:PicassoMonitorEntity.CONTROLLER_DESTROY];
    });
}

- (void)updatePCWithHostId:(NSString *)hostId method:(NSString *)method argument:(NSDictionary *)args {
    PCSRunOnBridgeThread(^{
        [self syncCallPCWithHostId:hostId method:method argument:args];
    });
}

- (JSValue *)syncCallPCWithHostId:(NSString *)hostId method:(NSString *)method argument:(NSDictionary *)args {
    PCSAssertBridgeThread();
    PicassoHost *host = [PicassoHostManager hostForId:hostId];
    NSString *methodInfo = [host.monitorEntity wrapMethodInvokeAnchorForName:@"callPCMethod" arg1:hostId arg2:method];
    [host.monitorEntity start:methodInfo];
    NSArray *arguments = @[hostId?:@"",method?:@"",args?:@{}];
    @weakify(self);
    JSValue *value = [self.jsbridge callJSMethod:@"callPCMethod" arguments:arguments exceptionHandler:^(JSContext *context, JSValue *exception) {
        @strongify(self);
        [self _logJSErrorWithException:exception jsContent:host.jsContent jsname:host.alias status:[self crashStatusWithIntentData:host.intentData args:arguments]];
    }];
    [host.monitorEntity end:methodInfo];
    return value;
}

#pragma mark - callback

- (void)callbackSuccessWithHost:(NSString *)hostId callbackId:(NSString *)callbackId responseData:(NSDictionary *)responseData {
    PCSRunOnBridgeThread(^{
        [self _executeCallbackWithHost:hostId callbackId:callbackId status:PicassoBridgeStatusSuccess response:responseData];
    });
}

- (void)callbackFailWithHost:(NSString *)hostId callbackId:(NSString *)callbackId error:(PicassoError *)error {
    PCSRunOnBridgeThread(^{
        NSDictionary *resDic = @{
                                 @"errCode":@(error.errorCode),
                                 @"errMsg":error.errorMsg?:@"",
                                 @"info":error.customInfo?:@{}
                                 };
        [self _executeCallbackWithHost:hostId callbackId:callbackId status:PicassoBridgeStatusFailure response:resDic];
    });
}

- (void)callbackHandleWithHost:(NSString *)hostId callbackId:(NSString *)callbackId responseData:(NSDictionary *)responseData {
    PCSRunOnBridgeThread(^{
        [self _executeCallbackWithHost:hostId callbackId:callbackId status:PicassoBridgeStatusAction response:responseData];
    });
}

@end
