//
//  NVNetworkLogger.h
//  Pods
//
//  Created by yxn on 2016/9/29.
//
//

#import <Foundation/Foundation.h>
#import "Logan.h"

typedef  NSString* _Nonnull  (^NetworkBlock)();
typedef  BOOL (^isOpenNetworkLogBlock)();
typedef NSString *_Nonnull (^LogUnionIDBlock)();


@interface NVNetworkLoggerConfig : NSObject

+ (nonnull instancetype)sharedInstance;

- (nonnull instancetype)init NS_UNAVAILABLE;

/**
 current network status
 
 @param block return
 */
- (void)setNetworkBlock:(nonnull NetworkBlock)block;

/**
 open log or not
 
 @param block return
 */
- (void)setIsOpenNetworkLog:(nonnull isOpenNetworkLogBlock)block;

/**
 设置用户ID
 
 @param block read new unionid
 */
- (void)setUnionIdBlock:(nonnull LogUnionIDBlock)block;


- (void)uploadLogWithDate:(nonnull NSString *)date networkType:(nonnull NSString *)type key:(nonnull NSString *)key;

@end
