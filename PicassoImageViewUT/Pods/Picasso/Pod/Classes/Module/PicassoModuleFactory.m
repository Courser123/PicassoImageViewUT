//
//  PicassoModuleFactory.m
//  Pods
//
//  Created by 纪鹏 on 2017/5/11.
//
//

#import "PicassoModuleFactory.h"
#import "PicassoBridgeMethodConfig.h"
#import "PicassoUtility.h"

@interface PicassoModuleFactory ()
@property (atomic, strong) NSDictionary<NSString *, PicassoBridgeMethodConfig *> *moduleMapper;
@property (atomic, strong) NSDictionary<NSString *, NSArray <NSString *> *> *modules;
@end

@implementation PicassoModuleFactory

+ (PicassoModuleFactory *)_sharedInstance {
    static PicassoModuleFactory *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[PicassoModuleFactory alloc] init];
    });
    return _instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _moduleMapper = [self _loadMapper];
    }
    return self;
}

- (NSDictionary *)innerModuleMapping {
    return @{
             @"network"     :@"PicassoNetworkModule",
             @"navigator"   :@"PicassoNavigatorModule",
             @"storage"     :@"PicassoStorageModule",
             @"modal"       :@"PicassoModalModule",
             @"broadcast"   :@"PicassoBroadcastModule",
             @"timer"       :@"PicassoTimerModule",
             @"vc"          :@"PicassoVCModule",
             @"statusBar"   :@"PicassoStatusBarModule",
             @"picker"      :@"PicassoPickerModule"
             };
}

- (NSDictionary *)_loadMapper {
    NSMutableDictionary *tempDic = [NSMutableDictionary new];
    NSMutableDictionary *moduleInject = [NSMutableDictionary new];
    NSDictionary *mappingDic = [NSDictionary new];

    NSString *fileName = [NSString stringWithFormat:@"PicassoModuleMapping_%@", [PicassoUtility appId]];
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    if (content.length > 0) {
        NSMutableDictionary *mappingFileDic = [NSMutableDictionary new];
        NSArray *components = [content componentsSeparatedByString:@"\n"];
        for (NSString *component in components) {
            if (component.length == 0) {
                continue;
            }
            NSString *lineString = [[component stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"\t" withString:@""];
            if (lineString.length == 0) {
                continue;
            }
            NSRange commentRange = [lineString rangeOfString:@"#"];
            if (commentRange.location == 0) {
                continue;
            }
            if (commentRange.location != NSNotFound) {
                lineString = [lineString substringToIndex:commentRange.location];
            }
            if ([lineString rangeOfString:@":"].location != NSNotFound) {
                NSArray *mappers = [lineString componentsSeparatedByString:@":"];
                if (mappers.count >= 2) {
                    NSString *name = mappers[0];
                    NSString *clz = mappers[1];
                    if (name.length > 0 && clz.length > 0) {
                        [mappingFileDic setObject:clz forKey:name];
                    }
                }
            }
        }
        mappingDic = [mappingFileDic copy];
    } else {
        mappingDic = [self innerModuleMapping];
    }
    
    for (NSString *name in mappingDic.allKeys) {
        NSString *clz = mappingDic[name];
        Class cls = NSClassFromString(clz);
        if (name.length > 0 && cls) {
            PicassoBridgeMethodConfig *moduleConfig = [[PicassoBridgeMethodConfig alloc] initWithBridgeClazz:clz];
            [tempDic setObject:moduleConfig forKey:name];
            NSArray *methods = [moduleConfig moduleMethods];
            if (methods.count > 0) {
                [moduleInject setObject:methods forKey:name];
            }
        }
    }

    _modules = [moduleInject copy];
    return [tempDic copy];
}

#pragma mark - Public Apis

+ (NSDictionary *)loadedModules {
    return [self _sharedInstance].modules;
}

+ (SEL)selectorWithModule:(NSString *)module method:(NSString *)method {
    if (module.length == 0 || method.length == 0) {
        return nil;
    }
    PicassoBridgeMethodConfig *moduleConfig = [[self _sharedInstance].moduleMapper objectForKey:module];
    return [moduleConfig selectorWithMethodName:method];
}

+ (Class)classForModuleName:(NSString *)name {
    if (name.length == 0) {
        return nil;
    }
    PicassoBridgeMethodConfig *moduleConfig = [[self _sharedInstance].moduleMapper objectForKey:name];
    return [moduleConfig getClass];
}
@end
