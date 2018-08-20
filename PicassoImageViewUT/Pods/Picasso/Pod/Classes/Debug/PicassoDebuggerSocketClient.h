//
//  PicassoDebuggerSocketClient.h
//  Picasso playground
//
//  Created by Zhidi Xia on 2018/3/26.
//  Copyright © 2018年 纪鹏. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^PicassoJavaScriptCompleteBlock)(NSError *error);
typedef void (^PicassoJavaScriptCallbackBlock)(id result, NSError *error);

@interface PicassoDebuggerSocketClient : NSObject

- (instancetype)init;

- (void)executeScript:(NSString *)script
                 name:(NSString *)name
        completeBlock:(PicassoJavaScriptCompleteBlock)completeBlock;

- (void)executeJSCall:(NSString *)method arguments:(NSArray *)arguments callback:(PicassoJavaScriptCallbackBlock)callbackBlock;

- (void)injectJSFunction:(NSString *)function withBlock:(id)block;

/**
 映射JS常量集合

 @param dictionory key value格式的需要映射的常量集合
 */
- (void)injectJSConstWithDictionary:(NSDictionary *)dictionory;

@end

NS_ASSUME_NONNULL_END
