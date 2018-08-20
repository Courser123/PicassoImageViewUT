//
//  PicassoAppConfiguration.m
//  CocoaAsyncSocket
//
//  Created by 纪鹏 on 2017/7/31.
//

#import "PicassoAppConfiguration.h"

@implementation PicassoAppConfiguration

+ (PicassoAppConfiguration *)instance {
    static PicassoAppConfiguration *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[PicassoAppConfiguration alloc] init];
    });
    return _instance;
}

@end
