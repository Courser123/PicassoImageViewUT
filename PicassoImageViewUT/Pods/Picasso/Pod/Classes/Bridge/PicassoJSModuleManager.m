//
//  PicassoJSModuleManager.m
//  CocoaAsyncSocket
//
//  Created by 纪鹏 on 2017/8/21.
//

#import "PicassoJSModuleManager.h"
#import "PicassoThreadSafeMutableDictionary.h"

@interface PicassoJSModuleManager ()

@property (atomic, strong) PicassoThreadSafeMutableDictionary *jsModuleDic;

@end


@implementation PicassoJSModuleManager

+ (PicassoJSModuleManager *)_instance {
    static dispatch_once_t onceToken;
    static PicassoJSModuleManager *instance;
    dispatch_once(&onceToken, ^{
        instance = [[PicassoJSModuleManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _jsModuleDic = [[PicassoThreadSafeMutableDictionary alloc] init];
    }
    return self;
}

+ (void)registerJSModuleWithName:(NSString *)name jsScript:(NSString *)script {
    if (name.length == 0 || script.length == 0) {
        NSLog(@"error: empty moduleName or script");
        return;
    }
    [[self _instance].jsModuleDic setObject:script forKey:name];
}

+ (NSString *)jsScriptForModuleName:(NSString *)name {
    if (name.length == 0) {
        NSLog(@"invalid name");
        return @"";
    }
    return [self _instance].jsModuleDic[name];
}

@end
