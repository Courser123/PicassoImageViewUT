//
//  PicassoImageCacheConfig.m
//  PicassoBase
//
//  Created by Courser on 2018/4/16.
//

#import "PicassoImageCacheConfig.h"

@implementation PicassoImageCacheConfig

- (instancetype)init {
    if (self = [super init]) {
        _countLimit = NSUIntegerMax;
        _costLimit = NSUIntegerMax;
        _ageLimit = DBL_MAX;
        _autoTrimInterval = 5.0;
        _shouldRemoveAllObjectsOnMemoryWarning = YES;
        _shouldRemoveAllObjectsWhenEnteringBackground = YES;
        _releaseOnMainThread = NO;
        _releaseAsynchronously = YES;
    }
    return self;
}

@end
