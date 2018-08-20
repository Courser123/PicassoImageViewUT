//
//  PicassoViewFactory.m
//  Pods
//
//  Created by 纪鹏 on 2017/6/5.
//
//

#import "PicassoViewWrapperFactory.h"
#import "PicassoMapperModel.h"
#import "PicassoModel.h"
#import "PicassoBaseViewWrapper.h"
#import "PicassoBridgeMethodConfig.h"
#import "PicassoUtility.h"

@interface PicassoViewWrapperFactory ()
@property (atomic, strong) NSDictionary *viewWrapperMappers;
@end

@implementation PicassoViewWrapperFactory

+ (PicassoViewWrapperFactory *)_sharedInstance {
    static dispatch_once_t onceToken;
    static PicassoViewWrapperFactory *_instance;
    dispatch_once(&onceToken, ^{
        _instance = [[PicassoViewWrapperFactory alloc] init];
    });
    return _instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _viewWrapperMappers = [self _loadMapper];
    }
    return self;
}

- (NSDictionary *)innerViewMapping {
    return @{
             @(0)   : @"PicassoGroupViewWrapper",
             @(1)   : @"PicassoLabelWrapper",
             @(2)   : @"PicassoImageViewWrapper",
             @(3)   : @"PicassoButtonWrapper",
             @(8)   : @"PicassoListItemWrapper",
             @(9)   : @"PicassoListViewWrapper",
             @(10)  : @"PicassoPullRefreshWrapper",
             @(11)  : @"PicassoScrollViewWrapper",
             @(14)  : @"PicassoInputViewWrapper",
             @(15)  : @"PicassoActivityIndicatorWrapper",
             @(16)  : @"PicassoAnimationViewWrapper" ,
             @(17)  : @"PicassoSwitchWrapper"
             };
}

- (NSDictionary *)_loadMapper {
    NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
    NSString *fileName = [NSString stringWithFormat:@"PicassoViewMapping_%@", [PicassoUtility appId]];

    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSMutableDictionary *typeWrapperDic = [NSMutableDictionary new];
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
                    NSInteger viewType = [mappers[0] integerValue];
                    NSString *wrapperClz = mappers[1];
                    [typeWrapperDic setObject:wrapperClz forKey:@(viewType)];
                }
            }
        }
    }
    [typeWrapperDic addEntriesFromDictionary:[self innerViewMapping]];
    [typeWrapperDic enumerateKeysAndObjectsUsingBlock:^(NSNumber *  _Nonnull viewType, NSString *  _Nonnull wrapperClz, BOOL * _Nonnull stop) {
        Class wrapperClass = NSClassFromString(wrapperClz);
        PicassoMapperModel *model = [PicassoMapperModel new];
        model.viewType = [viewType integerValue];
        model.viewWrapperClz = wrapperClz;
        if ([wrapperClass respondsToSelector:@selector(viewClass)]) {
            Class viewCls = [wrapperClass viewClass];
            model.viewClz = NSStringFromClass(viewCls);
            if (viewCls) {
                PicassoBridgeMethodConfig *config = [[PicassoBridgeMethodConfig alloc] initWithBridgeClazz:NSStringFromClass(viewCls)];
                model.methodsConfig = config;
            }
        }
        if ([wrapperClass respondsToSelector:@selector(modelClass)]) {
            Class modelCls = [wrapperClass modelClass];
            model.modelClz = NSStringFromClass(modelCls);
        }
        [tempDic setObject:model forKey:viewType];
    }];
    return [tempDic copy];
}

+ (Class)viewWrapperByType:(NSInteger)viewType {
    return NSClassFromString(((PicassoMapperModel *)[[self _sharedInstance].viewWrapperMappers objectForKey:@(viewType)]).viewWrapperClz);
}

+ (Class)viewModelByType:(NSInteger)viewType {
    return NSClassFromString(((PicassoMapperModel *)[[self _sharedInstance].viewWrapperMappers objectForKey:@(viewType)]).modelClz);
}

+ (Class)viewClassByType:(NSInteger)viewType {
    return NSClassFromString(((PicassoMapperModel *)[[self _sharedInstance].viewWrapperMappers objectForKey:@(viewType)]).viewClz);
}

+ (SEL)selectorWithViewClass:(Class)cls method:(NSString *)method {
    for (NSString *key in [self _sharedInstance].viewWrapperMappers.allKeys) {
        PicassoMapperModel *mapperModel = [[self _sharedInstance].viewWrapperMappers objectForKey:key];
        if (NSClassFromString(mapperModel.viewClz) == cls) {
            PicassoBridgeMethodConfig *config = mapperModel.methodsConfig;
            return [config selectorWithMethodName:method];
        }
    }
    NSLog(@"selectorWithViewClass method not found");
    return nil;
}

@end
