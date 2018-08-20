//
//  PicassoBaseImageLubanConfig.m
//  Picasso
//
//  Created by Courser on 2018/6/5.
//

#import "PicassoBaseImageLubanConfig.h"

@implementation PicassoBaseImageLubanConfig

+ (PicassoBaseImageLubanConfig *)sharedInstance {
    static dispatch_once_t onceToken;
    static PicassoBaseImageLubanConfig *config;
    dispatch_once(&onceToken, ^{
        config = [PicassoBaseImageLubanConfig new];
    });
    return config;
}

- (instancetype)init {
    if (self = [super init]) {
        _diskCacheSize = 10;
        _timeoutIntervalForRequest = 15;
    }
    return self;
}

@end
