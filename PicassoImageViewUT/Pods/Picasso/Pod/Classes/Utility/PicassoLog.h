//
//  PicassoLog.h
//  Pods
//
//  Created by 纪鹏 on 2016/12/20.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSUInteger, PicassoLogTag) {
    PicassoLogTagError = 0,
    PicassoLogTagWarning,
    PicassoLogTagInfo
};


@interface PicassoLog : NSObject


@end
#define PLog(format, ...) NSLog(format, ## __VA_ARGS__);
