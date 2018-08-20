//
//  PicassoUtility.h
//  Picasso
//
//  Created by xiebohui on 14/12/2016.
//  Copyright © 2016 huang.zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JSValue;

@interface PicassoUtility : NSObject

+ (nonnull NSDictionary *)getEnvironment;

+ (nonnull NSNumber *)appId;

+ (nonnull NSString *)unionId;

+ (BOOL)isDebug;

+ (nonnull NSString *)errorStringWithException:(nonnull JSValue *)exception;

@end
