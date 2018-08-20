//
//  PicassoSaveCacheHelper.h
//  Pods
//
//  Created by Courser on 18/09/2017.
//
//

#import <Foundation/Foundation.h>
#import "PicassoFetchImageSignal.h"
#import "TMCache.h"

typedef void(^CRDiskCacheBlock)(void);
typedef void (^CRDiskCacheObjectBlock)(NSString *key, id <NSCoding> object, NSURL *fileURL);
typedef void(^CRCalculateSizeBlock)(NSUInteger byteCount, NSUInteger totalSize);
typedef void(^CRCheckCacheCompletionBlock)(BOOL isInCache);

@interface PicassoSaveCacheHelper : NSObject

@property (nonatomic, strong) NSCache *cache;
@property (nonatomic, strong) TMCache *myCache;
@property (nonatomic, assign) CRPicassoImageCache cacheType;  // 缓存类型

+ (instancetype)sharedCacheHelper;

// save cache
- (void)saveToMemoryCacheWithImage:(UIImage *)image WithIdentifier:(NSString *)identifier;

- (void)saveToMemoryCacheWithImage:(UIImage *)image WithIdentifier:(NSString *)identifier cacheType:(CRPicassoImageCache)cacheType;

- (void)saveToDiskWithImageData:(NSData *)data WithIdentifier:(NSString *)identifier;

- (void)saveToDiskWithImageData:(NSData *)data WithIdentifier:(NSString *)identifier cacheType:(CRPicassoImageCache)cacheType;

// sync
- (UIImage *)imageFromMemoryCacheForKey:(NSString *)key;

- (UIImage *)imageFromMemoryCacheForKey:(NSString *)key cacheType:(CRPicassoImageCache)cacheType;

- (NSData *)imageDataFromDiskCacheForKey:(NSString *)key;

- (NSData *)imageDataFromDiskCacheForKey:(NSString *)key cacheType:(CRPicassoImageCache)cacheType;

// async
- (void)imageDataFromDiskCacheForKey:(NSString *)key block:(CRDiskCacheObjectBlock)block;

- (void)imageDataFromDiskCacheForKey:(NSString *)key cacheType:(CRPicassoImageCache)cacheType block:(CRDiskCacheObjectBlock)block;

// query
- (BOOL)memoryImageExistsWithKey:(NSString *)key;

- (BOOL)diskDataExistsWithKey:(NSString *)key;

- (void)diskDataExistsWithKey:(NSString *)key completion:(CRCheckCacheCompletionBlock)block;

// remove cache
- (void)removeImageFromMemoryCacheForKey:(NSString *)key;

- (void)removeImageFromMemoryCacheForKey:(NSString *)key cacheType:(CRPicassoImageCache)cacheType;

- (void)removeImageDataFromDiskCacheForKey:(NSString *)key;

- (void)removeImageDataFromDiskCacheForKey:(NSString *)key cacheType:(CRPicassoImageCache)cacheType;

- (void)removeImageDataFromDiskCacheForKey:(NSString *)key block:(CRDiskCacheObjectBlock)block;

- (void)removeImageDataFromDiskCacheForKey:(NSString *)key cacheType:(CRPicassoImageCache)cacheType block:(CRDiskCacheObjectBlock)block;

// clear cache
- (void)clearMemory;

- (void)clearMemoryCacheType:(CRPicassoImageCache)cacheType;

- (void)clearDisk;

- (void)clearDiskCacheType:(CRPicassoImageCache)cacheType;

- (void)clearDiskBlock:(CRDiskCacheBlock)block;

- (void)clearDiskCacheType:(CRPicassoImageCache)cacheType block:(CRDiskCacheBlock)block;

// calculate Size
- (void)calculateDiskSizeWithCompletionBlock:(CRCalculateSizeBlock)block;

- (void)calculateDiskSizeWithCacheType:(CRPicassoImageCache)cacheType completion:(CRCalculateSizeBlock)block;

@end
