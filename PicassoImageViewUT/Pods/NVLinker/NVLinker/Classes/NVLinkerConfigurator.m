//
//  NVLinkerConfigurator.m
//  NVLinker
//
//  Created by JiangTeng on 2018/2/27.
//

#import "NVLinkerConfigurator.h"

@implementation NVLinkerConfigurator
+ (NVLinkerConfigurator *_Nonnull)configurator {
    
    static NVLinkerConfigurator * instance = nil;
    static  dispatch_once_t pred;
    dispatch_once(&pred, ^{
        instance = [[NVLinkerConfigurator alloc] init];
    });
    
    return instance;
}

- (NSInteger)appID {
    
    NSAssert(_appID > 0, @"请先设置appid");
    return _appID;
}

- (NSString *_Nullable)unionID {
    if (self.unionIDBlock) {
        return self.unionIDBlock();
    }
    NSAssert(self.unionIDBlock, @"请先设置unionId");
    return nil;
}
@end
