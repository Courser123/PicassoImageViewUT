//
//  PicassoSaveCacheHelper.m
//  Pods
//
//  Created by Courser on 18/09/2017.
//
//

#import "PicassoSaveCacheHelper.h"
#import "PicassoMemoryCache.h"
#import "PicassoBaseImageLubanConfig.h"

NSCache *__pcsimageMemCache = nil;
NSCache *__pcsIconImageMemCache = nil;
static dispatch_once_t crInitCacheTag;
static dispatch_once_t crInitIconCacheTag;

@interface PicassoMemoryCacheManager : NSObject
@property (nonatomic, strong) PicassoMemoryCache *cache;
@property (nonatomic, strong) PicassoMemoryCache *iconCache;
@end

@implementation PicassoMemoryCacheManager

+ (PicassoMemoryCacheManager *)sharedInstance {
    static PicassoMemoryCacheManager *instance = nil;
    
    static dispatch_once_t crMemOnceToken;
    dispatch_once(&crMemOnceToken, ^{
        instance = [[PicassoMemoryCacheManager alloc] init];
    });
    
    return instance;
}

- (PicassoMemoryCache *)cache {
    if (_cache == nil) {
        _cache = [[PicassoMemoryCache alloc] init];
        PicassoImageCacheConfig *config = [[PicassoImageCacheConfig alloc] init];
        config.costLimit = 50 * 1024 * 1024;
        config.shouldRemoveAllObjectsWhenEnteringBackground = NO;
        _cache.config = config;
    }
    return _cache;
}

- (PicassoMemoryCache *)iconCache {
    if (_iconCache == nil) {
        _iconCache = [[PicassoMemoryCache alloc] init];
        PicassoImageCacheConfig *config = [[PicassoImageCacheConfig alloc] init];
        config.costLimit = 10 * 1024 * 1024;
        config.shouldRemoveAllObjectsWhenEnteringBackground = NO;
        _iconCache.config = config;
    }
    return _iconCache;
}

@end

@interface PicassoDiskCacheManager : NSObject
@property (nonatomic, strong) TMCache *cache;
@property (nonatomic, strong) TMCache *iconCache;
@end

@implementation PicassoDiskCacheManager

+ (PicassoDiskCacheManager *)sharedInstance {
    static PicassoDiskCacheManager *instance  = nil;
    
    static dispatch_once_t crDiskOnceToken;
    dispatch_once(&crDiskOnceToken, ^{
        instance = [[PicassoDiskCacheManager alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:instance selector:@selector(didEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    });
    
    return instance;
}

- (TMCache *)cache {
    if (_cache == nil) {
        _cache = [[TMCache alloc] initWithName:@"com.picasso.image-cache"];
    }
    return _cache;
}

- (TMCache *)iconCache {
    if (!_iconCache) {
        _iconCache = [[TMCache alloc] initWithName:@"com.picasso.image-iconcache"];
    }
    return _iconCache;
}

- (NSTimeInterval)cacheDuration {
    return 3600 * 24 * 15;
}

- (NSInteger)maxImageCacheSize {
    return 1024 * 1024 * [PicassoBaseImageLubanConfig sharedInstance].diskCacheSize;
}

- (void)didEnterBackground:(NSNotification *)n {
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
    [self.cache trimToDate:[NSDate dateWithTimeIntervalSince1970:(interval - [self cacheDuration])]];
    [self.cache.diskCache trimToSizeByDate:[self maxImageCacheSize]];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

@interface PicassoSaveCacheHelper ()

//@property (nonatomic, strong) PicassoMemoryCache *memCache;

@end

@implementation PicassoSaveCacheHelper

+ (instancetype)sharedCacheHelper {
    static dispatch_once_t crOnce;
    static id instance;
    dispatch_once(&crOnce, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (NSCache *)cache {
    if (self.cacheType == CRPicassoImageCachePermanentIcons) {
        dispatch_once(&crInitIconCacheTag, ^{
            __pcsIconImageMemCache = [[NSCache alloc] init];
            __pcsIconImageMemCache.totalCostLimit = 10 * 1024 * 1024;
        });
        return __pcsIconImageMemCache;
    }
    dispatch_once(&crInitCacheTag, ^{
        __pcsimageMemCache = [[NSCache alloc] init];
        __pcsimageMemCache.totalCostLimit = 50 * 1024 * 1024;
    });
    return __pcsimageMemCache;
}

- (TMCache *)myCache {
    if (self.cacheType == CRPicassoImageCachePermanentIcons) {
        return [[PicassoDiskCacheManager sharedInstance] iconCache];
    }
    return [[PicassoDiskCacheManager sharedInstance] cache];
}

//- (instancetype)init {
//    if (self = [super init]) {
//        // init the memory cache
//        _memCache = [[PicassoMemoryCache alloc] init];
//        PicassoImageCacheConfig *config = [[PicassoImageCacheConfig alloc] init];
//        config.costLimit = 50 * 1024 * 1024;
//        _memCache.config = config;
//    }
//    return self;
//}

#pragma mark 缓存到内存
- (void)saveToMemoryCacheWithImage:(UIImage *)image WithIdentifier:(NSString *)identifier {
    [self saveToMemoryCacheWithImage:image WithIdentifier:identifier cacheType:CRPicassoImageCacheDefault];
}

- (void)saveToMemoryCacheWithImage:(UIImage *)image WithIdentifier:(NSString *)identifier cacheType:(CRPicassoImageCache)cacheType {
    if (!image) return;
    if (identifier.length == 0) return;
    if (cacheType == CRPicassoImageCacheDefault) {
        [[PicassoMemoryCacheManager sharedInstance].cache setObject:image forKey:identifier withCost:image.size.width * image.size.height * image.scale * image.scale * 4];
    }else {
        [[PicassoMemoryCacheManager sharedInstance].iconCache setObject:image forKey:identifier withCost:image.size.width * image.size.height * image.scale * image.scale * 4];
    }
}

#pragma mark 缓存到磁盘
- (void)saveToDiskWithImageData:(NSData *)data WithIdentifier:(NSString *)identifier {
    [self saveToDiskWithImageData:data WithIdentifier:identifier cacheType:CRPicassoImageCacheDefault];
}

- (void)saveToDiskWithImageData:(NSData *)data WithIdentifier:(NSString *)identifier cacheType:(CRPicassoImageCache)cacheType {
    if (!data) return;
    if (cacheType == CRPicassoImageCacheDefault) {
        [[[PicassoDiskCacheManager sharedInstance] cache].diskCache setObject:data forKey:identifier];
    }else {
        [[[PicassoDiskCacheManager sharedInstance] iconCache].diskCache setObject:data forKey:identifier];
    }
}

#pragma mark 查询数据
- (UIImage *)imageFromMemoryCacheForKey:(NSString *)key {
    return [self imageFromMemoryCacheForKey:key cacheType:CRPicassoImageCacheDefault];
}

- (UIImage *)imageFromMemoryCacheForKey:(NSString *)key cacheType:(CRPicassoImageCache)cacheType {
    if (key.length == 0) return nil;
    if (cacheType == CRPicassoImageCacheDefault) {
        return [[PicassoMemoryCacheManager sharedInstance].cache objectForKey:key];
    }else {
        return [[PicassoMemoryCacheManager sharedInstance].iconCache objectForKey:key];
    }
}

- (NSData *)imageDataFromDiskCacheForKey:(NSString *)key {
    return [self imageDataFromDiskCacheForKey:key cacheType:CRPicassoImageCacheDefault];
}

- (NSData *)imageDataFromDiskCacheForKey:(NSString *)key cacheType:(CRPicassoImageCache)cacheType {
    if (cacheType == CRPicassoImageCacheDefault) {
        return (NSData *)[[[PicassoDiskCacheManager sharedInstance] cache].diskCache objectForKey:key];
    }else {
        return (NSData *)[[[PicassoDiskCacheManager sharedInstance] iconCache].diskCache objectForKey:key];
    }
}

- (void)imageDataFromDiskCacheForKey:(NSString *)key block:(CRDiskCacheObjectBlock)block{
    [self imageDataFromDiskCacheForKey:key cacheType:CRPicassoImageCacheDefault block:block];
}

- (void)imageDataFromDiskCacheForKey:(NSString *)key cacheType:(CRPicassoImageCache)cacheType block:(CRDiskCacheObjectBlock)block{
    if (cacheType == CRPicassoImageCacheDefault) {
        [[[PicassoDiskCacheManager sharedInstance] cache].diskCache objectForKey:key block:^(TMDiskCache *cache, NSString *key, id<NSCoding> object, NSURL *fileURL) {
            if (block) block(key,object,fileURL);
        }];
    }else {
        [[[PicassoDiskCacheManager sharedInstance] iconCache].diskCache objectForKey:key block:^(TMDiskCache *cache, NSString *key, id<NSCoding> object, NSURL *fileURL) {
            if (block) block(key,object,fileURL);
        }];
    }
}

#pragma mark 查询数据是否存在
- (BOOL)memoryImageExistsWithKey:(NSString *)key {
    if (key.length == 0) return NO;
    return [[PicassoMemoryCacheManager sharedInstance].cache containsObjectForKey:key] || [[PicassoMemoryCacheManager sharedInstance].iconCache containsObjectForKey:key];
}

- (BOOL)diskDataExistsWithKey:(NSString *)key {
    return ([[[PicassoDiskCacheManager sharedInstance] cache].diskCache objectForKey:key] != nil) || ([[[PicassoDiskCacheManager sharedInstance] iconCache].diskCache objectForKey:key] != nil);
}

- (void)diskDataExistsWithKey:(NSString *)key completion:(CRCheckCacheCompletionBlock)block {
    RACSubject *subjectCache = [RACSubject subject];
    RACSubject *subjectIconCache = [RACSubject subject];
    RACSignal *signalCombineLatest = [subjectCache combineLatestWith:subjectIconCache];
    [signalCombineLatest subscribeNext:^(RACTuple *result) {
        if ([result.first boolValue] || [result.second boolValue]) {
            if (block) {
                block(YES);
            }
        }else {
            if (block) {
                block(NO);
            }
        }
    }];
    [[[PicassoDiskCacheManager sharedInstance] cache].diskCache objectForKey:key block:^(TMDiskCache *cache, NSString *key, id<NSCoding> object, NSURL *fileURL) {
        [subjectCache sendNext:@(object != nil)];
    }];
    [[[PicassoDiskCacheManager sharedInstance] iconCache].diskCache objectForKey:key block:^(TMDiskCache *cache, NSString *key, id<NSCoding> object, NSURL *fileURL) {
        [subjectIconCache sendNext:@(object != nil)];
    }];
}

#pragma mark 清空缓存
- (void)removeImageFromMemoryCacheForKey:(NSString *)key {
    [self removeImageFromMemoryCacheForKey:key cacheType:CRPicassoImageCacheDefault];
}

- (void)removeImageFromMemoryCacheForKey:(NSString *)key cacheType:(CRPicassoImageCache)cacheType {
    if (key.length == 0) return;
    if (cacheType == CRPicassoImageCacheDefault) {
        [[PicassoMemoryCacheManager sharedInstance].cache removeObjectForKey:key];
    }else {
        [[PicassoMemoryCacheManager sharedInstance].iconCache removeObjectForKey:key];
    }
}

- (void)removeImageDataFromDiskCacheForKey:(NSString *)key {
    [self removeImageDataFromDiskCacheForKey:key cacheType:CRPicassoImageCacheDefault];
}

- (void)removeImageDataFromDiskCacheForKey:(NSString *)key cacheType:(CRPicassoImageCache)cacheType {
    if (cacheType == CRPicassoImageCacheDefault) {
        [[[PicassoDiskCacheManager sharedInstance] cache].diskCache removeObjectForKey:key];
    }else {
        [[[PicassoDiskCacheManager sharedInstance] iconCache].diskCache removeObjectForKey:key];
    }
}

- (void)removeImageDataFromDiskCacheForKey:(NSString *)key block:(CRDiskCacheObjectBlock)block {
    [self removeImageDataFromDiskCacheForKey:key cacheType:CRPicassoImageCacheDefault block:block];
}

- (void)removeImageDataFromDiskCacheForKey:(NSString *)key cacheType:(CRPicassoImageCache)cacheType block:(CRDiskCacheObjectBlock)block {
    if (cacheType == CRPicassoImageCacheDefault) {
        [[[PicassoDiskCacheManager sharedInstance] cache].diskCache removeObjectForKey:key block:^(TMDiskCache *cache, NSString *key, id<NSCoding> object, NSURL *fileURL) {
            if (block) block(key,object,fileURL);
        }];
    }else {
        [[[PicassoDiskCacheManager sharedInstance] iconCache].diskCache removeObjectForKey:key block:^(TMDiskCache *cache, NSString *key, id<NSCoding> object, NSURL *fileURL) {
            if (block) block(key,object,fileURL);
        }];
    }
}

- (void)clearMemory {
    [self clearMemoryCacheType:CRPicassoImageCacheDefault];
    [self clearMemoryCacheType:CRPicassoImageCachePermanentIcons];
}

- (void)clearMemoryCacheType:(CRPicassoImageCache)cacheType {
    if (cacheType == CRPicassoImageCacheDefault) {
        [[PicassoMemoryCacheManager sharedInstance].cache removeAllObjects];
    }else {
        [[PicassoMemoryCacheManager sharedInstance].iconCache removeAllObjects];
    }
}

- (void)clearDisk {
    [self clearDiskCacheType:CRPicassoImageCacheDefault];
    [self clearDiskCacheType:CRPicassoImageCachePermanentIcons];
}

-(void)clearDiskCacheType:(CRPicassoImageCache)cacheType {
    if (cacheType == CRPicassoImageCacheDefault) {
        [[[PicassoDiskCacheManager sharedInstance] cache].diskCache removeAllObjects];
    }else {
        [[[PicassoDiskCacheManager sharedInstance] iconCache].diskCache removeAllObjects];
    }
}

- (void)clearDiskBlock:(CRDiskCacheBlock)block {
    RACSubject *subjectCache = [RACSubject subject];
    RACSubject *subjectIconCache = [RACSubject subject];
    RACSignal *signalCombineLatest = [subjectCache combineLatestWith:subjectIconCache];
    [signalCombineLatest subscribeNext:^(id x) {
        if (block) {
            block();
        }
    }];
    [[[PicassoDiskCacheManager sharedInstance] cache].diskCache removeAllObjects:^(TMDiskCache *cache) {
        [subjectCache sendNext:nil];
    }];
    [[[PicassoDiskCacheManager sharedInstance] iconCache].diskCache removeAllObjects:^(TMDiskCache *cache) {
        [subjectIconCache sendNext:nil];
    }];
}

- (void)clearDiskCacheType:(CRPicassoImageCache)cacheType block:(CRDiskCacheBlock)block {
    if (cacheType == CRPicassoImageCacheDefault) {
        [[[PicassoDiskCacheManager sharedInstance] cache].diskCache removeAllObjects:^(TMDiskCache *cache) {
            if (block) block();
        }];
    }else {
        [[[PicassoDiskCacheManager sharedInstance] iconCache].diskCache removeAllObjects:^(TMDiskCache *cache) {
            if (block) block();
        }];
    }
}

- (void)calculateDiskSizeWithCompletionBlock:(CRCalculateSizeBlock)block {
    if (block) {
        block([[PicassoDiskCacheManager sharedInstance] cache].diskCache.byteCount + [[PicassoDiskCacheManager sharedInstance] iconCache].diskCache.byteCount, [[PicassoDiskCacheManager sharedInstance] cache].diskCache.byteLimit + [[PicassoDiskCacheManager sharedInstance] iconCache].diskCache.byteLimit);
    }
}

- (void)calculateDiskSizeWithCacheType:(CRPicassoImageCache)cacheType completion:(CRCalculateSizeBlock)block {
    if (cacheType == CRPicassoImageCacheDefault) {
        if (block) {
            block([[PicassoDiskCacheManager sharedInstance] cache].diskCache.byteCount,[[PicassoDiskCacheManager sharedInstance] cache].diskCache.byteLimit);
        }
    }else {
        if (block) {
            block([[PicassoDiskCacheManager sharedInstance] iconCache].diskCache.byteCount,[[PicassoDiskCacheManager sharedInstance] iconCache].diskCache.byteLimit);
        }
    }
}

@end
