//
//  PicassoImplementsFactory.m
//  clogan
//
//  Created by 纪鹏 on 2017/11/23.
//

#import "PicassoImplementsFactory.h"
#import "PicassoUtility.h"
#import "PicassoDefaultNavigatorImp.h"

@interface PicassoImplementsFactory ()

@property (atomic, strong) NSDictionary *implDic;

@end

@implementation PicassoImplementsFactory

+ (instancetype)_sharedInstance {
    static PicassoImplementsFactory *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[PicassoImplementsFactory alloc] init];
    });
    return _instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _implDic = [self _loadMapper];
    }
    return self;
}

- (NSDictionary *)innerImplDic {
    return @{
             @"PicassoNavigatorProtocol":[PicassoDefaultNavigatorImp class]
             };
}

- (NSDictionary *)_loadMapper {
    NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithDictionary:[self innerImplDic]];
    
    NSString *fileName = [NSString stringWithFormat:@"PicassoProtocolMapping_%@", [PicassoUtility appId]];
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    if (content.length > 0) {
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
                    NSString *protocolName = mappers[0];
                    NSString *implClz = mappers[1];
                    Class implCls = NSClassFromString(implClz);
                    if (protocolName.length > 0 && implCls) {
                        [tempDic setObject:implCls forKey:protocolName];
                    }
                }
            }
        }
    }
    return [tempDic copy];
}

+ (Class)implementForProtocol:(Protocol *)protocol {
    if (!protocol) {
        return nil;
    }
    Class impl = [[PicassoImplementsFactory _sharedInstance].implDic objectForKey:NSStringFromProtocol(protocol)];
    return impl;
}

@end
