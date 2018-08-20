//
//  PicassoLog.m
//  Pods
//
//  Created by 纪鹏 on 2016/12/20.
//
//

#import "PicassoLog.h"

@implementation PicassoLog

+(instancetype)sharedInstance {
    static PicassoLog *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[PicassoLog alloc] init];
    });
    return _sharedInstance;
}

@end
