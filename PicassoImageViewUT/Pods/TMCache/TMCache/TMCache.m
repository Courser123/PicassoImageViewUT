#import "TMCache.h"

NSString * const TMCachePrefix = @"com.tumblr.TMCache";
NSString * const TMCacheSharedName = @"TMCacheShared";

@interface TMCache ()
#if OS_OBJECT_USE_OBJC
@property (strong, nonatomic) dispatch_queue_t queue;
#else
@property (assign, nonatomic) dispatch_queue_t queue;
#endif
@end

@implementation TMCache

#pragma mark - Initialization -

#if !OS_OBJECT_USE_OBJC
- (void)dealloc
{
    dispatch_release(_queue);
    _queue = nil;
}
#endif

- (instancetype)initWithName:(NSString *)name
{
    return [self initWithName:name rootPath:[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
}

- (instancetype)initWithName:(NSString *)name rootPath:(NSString *)rootPath
{
    if (!name)
        return nil;

    if (self = [super init]) {
        _name = [name copy];
        
        NSString *queueName = [[NSString alloc] initWithFormat:@"%@.%p", TMCachePrefix, self];
        _queue = dispatch_queue_create([queueName UTF8String], DISPATCH_QUEUE_CONCURRENT);

        _diskCache = [[TMDiskCache alloc] initWithName:_name rootPath:rootPath];
        _memoryCache = [[TMMemoryCache alloc] init];
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"%@.%@.%p", TMCachePrefix, _name, self];
}

+ (instancetype)sharedCache
{
    static id cache;
    static dispatch_once_t predicate;

    dispatch_once(&predicate, ^{
        cache = [[self alloc] initWithName:TMCacheSharedName];
    });

    return cache;
}

#pragma mark - Public Asynchronous Methods -

- (void)objectForKey:(NSString *)key block:(TMCacheObjectBlock)block
{
    if (!key || !block)
        return;

    __weak TMCache *weakSelf = self;

    dispatch_async(_queue, ^{
        TMCache *strongSelf = weakSelf;
        if (!strongSelf)
            return;
        
        id object = [strongSelf objectForKey:key];
        if (block) {
            block(strongSelf,key,object);
        }
    });
}

- (void)setObject:(id <NSCoding>)object forKey:(NSString *)key block:(TMCacheObjectBlock)block
{
    if (!key || !object)
        return;

        __weak TMCache *weakSelf = self;
        dispatch_async(_queue, ^{
            TMCache *strongSelf = weakSelf;
            if (!strongSelf)
                return;
            [strongSelf setObject:object forKey:key];
            
            if (block) {
                block(strongSelf, key, object);
            }
        });
}

- (void)removeObjectForKey:(NSString *)key block:(TMCacheObjectBlock)block
{
    if (!key)
        return;
    
    __weak TMCache *weakSelf = self;
    dispatch_async(_queue, ^{
        TMCache *strongSelf = weakSelf;
        if (!strongSelf)
            return;
        
        [strongSelf removeObjectForKey:key];
        if (block) {
            block(strongSelf, key, nil);
        }
    });
}

- (void)removeAllObjects:(TMCacheBlock)block
{
    __weak TMCache *weakSelf = self;
    
    dispatch_async(_queue, ^{
        TMCache *strongSelf = weakSelf;
        if (!strongSelf)
            return;
        
        [strongSelf removeAllObjects];
        if (block) {
            block(strongSelf);
        }
    });
}

- (void)trimToDate:(NSDate *)date block:(TMCacheBlock)block
{
    if (!date)
        return;

    __weak TMCache *weakSelf = self;
    
    dispatch_async(_queue, ^{
        TMCache *strongSelf = weakSelf;
        if (!strongSelf)
            return;
        
        [strongSelf trimToDate:date];
        if (block) {
            block(strongSelf);
        }
    });
}

#pragma mark - Public Synchronous Accessors -

- (NSUInteger)diskByteCount
{
    __block NSUInteger byteCount = 0;
    
    [_diskCache synchronouslyLockFileAccessWhileExecutingBlock:^(TMDiskCache *diskCache) {
        byteCount = diskCache.byteCount;
    }];
    return byteCount;
}

#pragma mark - Public Synchronous Methods -

- (id)objectForKey:(NSString *)key
{
    if (!key)
        return nil;
    
    id objectForKey = [_memoryCache objectForKey:key];

    if (objectForKey) {
        [_diskCache fileURLForKey:key];
    } else{
        objectForKey = [_diskCache objectForKey:key];
        [_memoryCache setObject:objectForKey forKey:key];
    }

    return objectForKey;
}

- (void)setObject:(id <NSCoding>)object forKey:(NSString *)key
{
    if (!object || !key)
        return;
    
    [_memoryCache setObject:object forKey:key];
    [_diskCache setObject:object forKey:key];
}

- (void)removeObjectForKey:(NSString *)key
{
    if (!key)
        return;
    
    [_memoryCache removeObjectForKey:key];
    [_diskCache removeObjectForKey:key];
}

- (void)trimToDate:(NSDate *)date
{
    if (!date)
        return;
    
    [_memoryCache trimToDate:date];
    [_diskCache trimToDate:date];
}

- (void)removeAllObjects
{
    [_memoryCache removeAllObjects];
    [_diskCache removeAllObjects];
}

@end

// HC SVNT DRACONES
