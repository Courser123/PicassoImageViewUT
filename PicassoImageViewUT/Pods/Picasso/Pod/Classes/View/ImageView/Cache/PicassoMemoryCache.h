//
//  PicassoMemoryCache.h
//  PicassoBase
//
//  Created by Courser on 2018/4/16.
//

#import <Foundation/Foundation.h>
#import "PicassoImageCacheConfig.h"

@interface PicassoMemoryCache : NSObject
NS_ASSUME_NONNULL_BEGIN
@property (readonly) NSUInteger totalCount;

@property (readonly) NSUInteger totalCost;

@property (nonatomic, strong) PicassoImageCacheConfig *config;

@property (nullable, copy) void(^didReceiveMemoryWarningBlock)(PicassoMemoryCache *cache);

@property (nullable, copy) void(^didEnterBackgroundBlock)(PicassoMemoryCache *cache);

#pragma mark - Access Methods

- (BOOL)containsObjectForKey:(id)key;

- (nullable id)objectForKey:(id)key;

- (void)setObject:(nullable id)object forKey:(id)key;

- (void)setObject:(nullable id)object forKey:(id)key withCost:(NSUInteger)cost;

- (void)removeObjectForKey:(id)key;

- (void)removeAllObjects;

#pragma mark - Trim

- (void)trimToCount:(NSUInteger)count;

- (void)trimToCost:(NSUInteger)cost;

- (void)trimToAge:(NSTimeInterval)age;

NS_ASSUME_NONNULL_END
@end
