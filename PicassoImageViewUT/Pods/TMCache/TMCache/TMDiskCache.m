#import "TMDiskCache.h"

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_4_0
#import <UIKit/UIKit.h>
#endif

#define TMDiskCacheError(error) if (error) { NSLog(@"%@ (%d) ERROR: %@", \
                                    [[NSString stringWithUTF8String:__FILE__] lastPathComponent], \
                                    __LINE__, [error localizedDescription]); }

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_4_0 && defined(__clang) && defined(__has_feature) && !__has_feature(attribute_availability_app_extension)
    #define TMCacheStartBackgroundTask() UIBackgroundTaskIdentifier taskID = UIBackgroundTaskInvalid; \
            taskID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{ \
            [[UIApplication sharedApplication] endBackgroundTask:taskID]; }];
    #define TMCacheEndBackgroundTask() [[UIApplication sharedApplication] endBackgroundTask:taskID];
#else
    #define TMCacheStartBackgroundTask()
    #define TMCacheEndBackgroundTask()
#endif

NSString * const TMDiskCachePrefix = @"com.tumblr.TMDiskCache";
NSString * const TMDiskCacheSharedName = @"TMDiskCacheShared";

@interface TMDiskCache ()
@property (assign) NSUInteger byteCount;
@property (strong, nonatomic) NSURL *cacheURL;
#if OS_OBJECT_USE_OBJC
@property (strong, nonatomic) dispatch_queue_t queue;
@property (strong, nonatomic) dispatch_semaphore_t lockSemaphore;
#else
@property (assign, nonatomic) dispatch_queue_t queue;
@property (assign, nonatomic) dispatch_semaphore_t lockSemaphore;
#endif
@property (strong, nonatomic) NSMutableDictionary *dates;
@property (strong, nonatomic) NSMutableDictionary *sizes;
@end

@implementation TMDiskCache

@synthesize willAddObjectBlock = _willAddObjectBlock;
@synthesize willRemoveObjectBlock = _willRemoveObjectBlock;
@synthesize willRemoveAllObjectsBlock = _willRemoveAllObjectsBlock;
@synthesize didAddObjectBlock = _didAddObjectBlock;
@synthesize didRemoveObjectBlock = _didRemoveObjectBlock;
@synthesize didRemoveAllObjectsBlock = _didRemoveAllObjectsBlock;
@synthesize byteLimit = _byteLimit;
@synthesize ageLimit = _ageLimit;

- (void)dealloc
{
#if !OS_OBJECT_USE_OBJC
    dispatch_release(_lockSemaphore);
    dispatch_release(_queue);
    _queue = nil;
#endif
}

#pragma mark - Initialization -

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
        _queue = dispatch_queue_create([TMDiskCachePrefix UTF8String], DISPATCH_QUEUE_CONCURRENT);;
        _lockSemaphore = dispatch_semaphore_create(1);

        _willAddObjectBlock = nil;
        _willRemoveObjectBlock = nil;
        _willRemoveAllObjectsBlock = nil;
        _didAddObjectBlock = nil;
        _didRemoveObjectBlock = nil;
        _didRemoveAllObjectsBlock = nil;
        
        _byteCount = 0;
        _byteLimit = 0;
        _ageLimit = 0.0;

        _dates = [[NSMutableDictionary alloc] init];
        _sizes = [[NSMutableDictionary alloc] init];

        NSString *pathComponent = [[NSString alloc] initWithFormat:@"%@.%@", TMDiskCachePrefix, _name];
        _cacheURL = [NSURL fileURLWithPathComponents:@[ rootPath, pathComponent ]];

        [self lock];
        dispatch_async(_queue, ^{
            [self createCacheDirectory];
            [self initializeDiskProperties];
            [self unlock];
        });
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"%@.%@.%p", TMDiskCachePrefix, _name, self];
}

+ (instancetype)sharedCache
{
    static id cache;
    static dispatch_once_t predicate;

    dispatch_once(&predicate, ^{
        cache = [[self alloc] initWithName:TMDiskCacheSharedName];
    });

    return cache;
}

+ (dispatch_queue_t)sharedQueue
{
    static dispatch_queue_t queue;
    static dispatch_once_t predicate;

    dispatch_once(&predicate, ^{
        queue = dispatch_queue_create([TMDiskCachePrefix UTF8String], DISPATCH_QUEUE_CONCURRENT);
    });

    return queue;
}

#pragma mark - Private Methods -

- (NSURL *)encodedFileURLForKey:(NSString *)key
{
    if (![key length])
        return nil;

    return [_cacheURL URLByAppendingPathComponent:[self encodedString:key]];
}

- (NSString *)keyForEncodedFileURL:(NSURL *)url
{
    NSString *fileName = [url lastPathComponent];
    if (!fileName)
        return nil;

    return [self decodedString:fileName];
}

- (NSString *)encodedString:(NSString *)string
{
    if (![string length]) {
        return @"";
    }
    
    if ([string respondsToSelector:@selector(stringByAddingPercentEncodingWithAllowedCharacters:)]) {
        return [string stringByAddingPercentEncodingWithAllowedCharacters:[[NSCharacterSet characterSetWithCharactersInString:@".:/%"] invertedSet]];
    }
    else {
        CFStringRef static const charsToEscape = CFSTR(".:/%");
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        CFStringRef escapedString = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                            (__bridge CFStringRef)string,
                                                                            NULL,
                                                                            charsToEscape,
                                                                            kCFStringEncodingUTF8);
#pragma clang diagnostic pop
        return (__bridge_transfer NSString *)escapedString;
    }
}

- (NSString *)decodedString:(NSString *)string
{
    if (![string length]) {
        return @"";
    }
    
    if ([string respondsToSelector:@selector(stringByRemovingPercentEncoding)]) {
        return [string stringByRemovingPercentEncoding];
    }
    else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        CFStringRef unescapedString = CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                                              (__bridge CFStringRef)string,
                                                                                              CFSTR(""),
                                                                                              kCFStringEncodingUTF8);
#pragma clang diagnostic pop
        return (__bridge_transfer NSString *)unescapedString;
    }
}

#pragma mark - Private Trash Methods -

+ (dispatch_queue_t)sharedTrashQueue
{
    static dispatch_queue_t trashQueue;
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        NSString *queueName = [[NSString alloc] initWithFormat:@"%@.trash", TMDiskCachePrefix];
        trashQueue = dispatch_queue_create([queueName UTF8String], DISPATCH_QUEUE_SERIAL);
        dispatch_set_target_queue(trashQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0));
    });
    
    return trashQueue;
}

+ (NSURL *)sharedTrashURL
{
    static NSURL *sharedTrashURL;
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        sharedTrashURL = [[[NSURL alloc] initFileURLWithPath:NSTemporaryDirectory()] URLByAppendingPathComponent:TMDiskCachePrefix isDirectory:YES];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:[sharedTrashURL path]]) {
            NSError *error = nil;
            [[NSFileManager defaultManager] createDirectoryAtURL:sharedTrashURL
                                     withIntermediateDirectories:YES
                                                      attributes:nil
                                                           error:&error];
            TMDiskCacheError(error);
        }
    });
    
    return sharedTrashURL;
}

+(BOOL)moveItemAtURLToTrash:(NSURL *)itemURL
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[itemURL path]])
        return NO;

    NSError *error = nil;
    NSString *uniqueString = [[NSProcessInfo processInfo] globallyUniqueString];
    NSURL *uniqueTrashURL = [[TMDiskCache sharedTrashURL] URLByAppendingPathComponent:uniqueString];
    BOOL moved = [[NSFileManager defaultManager] moveItemAtURL:itemURL toURL:uniqueTrashURL error:&error];
    TMDiskCacheError(error);
    return moved;
}

+ (void)emptyTrash
{
    TMCacheStartBackgroundTask();
    
    dispatch_async([self sharedTrashQueue], ^{        
        NSError *error = nil;
        NSArray *trashedItems = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[self sharedTrashURL]
                                                              includingPropertiesForKeys:nil
                                                                                 options:0
                                                                                   error:&error];
        TMDiskCacheError(error);

        for (NSURL *trashedItemURL in trashedItems) {
            NSError *error = nil;
            [[NSFileManager defaultManager] removeItemAtURL:trashedItemURL error:&error];
            TMDiskCacheError(error);
        }
            
        TMCacheEndBackgroundTask();
    });
}

#pragma mark - Private Queue Methods -

- (BOOL)createCacheDirectory
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:[_cacheURL path]])
        return NO;

    NSError *error = nil;
    BOOL success = [[NSFileManager defaultManager] createDirectoryAtURL:_cacheURL
                                            withIntermediateDirectories:YES
                                                             attributes:nil
                                                                  error:&error];
    TMDiskCacheError(error);

    return success;
}

- (void)initializeDiskProperties
{
    NSUInteger byteCount = 0;
    NSArray *keys = @[ NSURLContentModificationDateKey, NSURLTotalFileAllocatedSizeKey ];

    NSError *error = nil;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:_cacheURL
                                                   includingPropertiesForKeys:keys
                                                                      options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                        error:&error];
    TMDiskCacheError(error);

    for (NSURL *fileURL in files) {
        NSString *key = [self keyForEncodedFileURL:fileURL];

        error = nil;
        NSDictionary *dictionary = [fileURL resourceValuesForKeys:keys error:&error];
        TMDiskCacheError(error);

        NSDate *date = [dictionary objectForKey:NSURLContentModificationDateKey];
        if (date && key)
            [_dates setObject:date forKey:key];

        NSNumber *fileSize = [dictionary objectForKey:NSURLTotalFileAllocatedSizeKey];
        if (fileSize) {
            [_sizes setObject:fileSize forKey:key];
            byteCount += [fileSize unsignedIntegerValue];
        }
    }

    if (byteCount > 0)
        self.byteCount = byteCount; // atomic
}

- (BOOL)setFileModificationDate:(NSDate *)date forURL:(NSURL *)fileURL
{
    if (!date || !fileURL) {
        return NO;
    }
    
    NSError *error = nil;
    BOOL success = [[NSFileManager defaultManager] setAttributes:@{ NSFileModificationDate: date }
                                                    ofItemAtPath:[fileURL path]
                                                           error:&error];
    TMDiskCacheError(error);

    if (success) {
        NSString *key = [self keyForEncodedFileURL:fileURL];
        if (key) {
            [_dates setObject:date forKey:key];
        }
    }

    return success;
}

- (BOOL)removeFileAndExecuteBlocksForKey:(NSString *)key
{
    NSURL *fileURL = [self encodedFileURLForKey:key];
    if (!fileURL || ![[NSFileManager defaultManager] fileExistsAtPath:[fileURL path]])
        return NO;

    if (_willRemoveObjectBlock)
        _willRemoveObjectBlock(self, key, nil, fileURL);

    BOOL trashed = [TMDiskCache moveItemAtURLToTrash:fileURL];
    if (!trashed)
        return NO;
    
    [TMDiskCache emptyTrash];

    NSNumber *byteSize = [_sizes objectForKey:key];
    if (byteSize)
        self.byteCount = _byteCount - [byteSize unsignedIntegerValue]; // atomic

    [_sizes removeObjectForKey:key];
    [_dates removeObjectForKey:key];

    if (_didRemoveObjectBlock)
        _didRemoveObjectBlock(self, key, nil, fileURL);

    return YES;
}

- (void)trimDiskToSize:(NSUInteger)trimByteCount
{
    if (_byteCount <= trimByteCount)
        return;

    NSArray *keysSortedBySize = [_sizes keysSortedByValueUsingSelector:@selector(compare:)];

    for (NSString *key in [keysSortedBySize reverseObjectEnumerator]) { // largest objects first
        [self removeFileAndExecuteBlocksForKey:key];

        if (_byteCount <= trimByteCount)
            break;
    }
}

- (void)trimDiskToSizeByDate:(NSUInteger)trimByteCount
{
    if (_byteCount <= trimByteCount)
        return;

    NSArray *keysSortedByDate = [_dates keysSortedByValueUsingSelector:@selector(compare:)];

    for (NSString *key in keysSortedByDate) { // oldest objects first
        [self removeFileAndExecuteBlocksForKey:key];

        if (_byteCount <= trimByteCount)
            break;
    }
}

- (void)trimDiskToDate:(NSDate *)trimDate
{
    NSArray *keysSortedByDate = [_dates keysSortedByValueUsingSelector:@selector(compare:)];
    
    for (NSString *key in keysSortedByDate) { // oldest files first
        NSDate *accessDate = [_dates objectForKey:key];
        if (!accessDate)
            continue;
        
        if ([accessDate compare:trimDate] == NSOrderedAscending) { // older than trim date
            [self removeFileAndExecuteBlocksForKey:key];
        } else {
            break;
        }
    }
}

- (void)trimToAgeLimitRecursively
{
    [self lock];
    NSTimeInterval ageLimit = _ageLimit;
    [self unlock];
    if (ageLimit == 0.0)
        return;
    
    [self lock];
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSinceNow:-_ageLimit];
    [self trimDiskToDate:date];
    [self unlock];
    
    __weak TMDiskCache *weakSelf = self;
    
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_ageLimit * NSEC_PER_SEC));
    dispatch_after(time, _queue, ^(void) {
        TMDiskCache *strongSelf = weakSelf;
        [strongSelf trimToAgeLimitRecursively];
    });
}

#pragma mark - Public Asynchronous Methods -

- (void)objectForKey:(NSString *)key block:(TMDiskCacheObjectBlock)block
{
    __weak TMDiskCache *weakSelf = self;

    dispatch_async(_queue, ^{
        TMDiskCache *strongSelf = weakSelf;
        if (!strongSelf)
            return;
        
        id <NSCoding> object = [strongSelf objectForKey:key];
        
        if (block) {
            block(strongSelf, key, object, [strongSelf encodedFileURLForKey:key]);
        }
    });
}

- (void)fileURLForKey:(NSString *)key block:(TMDiskCacheObjectBlock)block
{
    __weak TMDiskCache *weakSelf = self;

    dispatch_async(_queue, ^{
        TMDiskCache *strongSelf = weakSelf;
        if (!strongSelf)
            return;

        NSURL *fileURL = [strongSelf fileURLForKey:key];
        if (block) {
            block(strongSelf, key, nil, fileURL);
        }
    });
}

- (void)setObject:(id <NSCoding>)object forKey:(NSString *)key block:(TMDiskCacheObjectBlock)block
{
    __weak TMDiskCache *weakSelf = self;

    dispatch_async(_queue, ^{
        TMDiskCache *strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        
        [strongSelf setObject:object forKey:key];

        if (block){
            block(strongSelf, key, object, [strongSelf encodedFileURLForKey:key]);
        }
    });
}

- (void)removeObjectForKey:(NSString *)key block:(TMDiskCacheObjectBlock)block
{
    __weak TMDiskCache *weakSelf = self;

    dispatch_async(_queue, ^{
        TMDiskCache *strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }

        [strongSelf removeObjectForKey:key];
        
        if (block){
            block(strongSelf, key, nil, [strongSelf encodedFileURLForKey:key]);
        }
    });
}

- (void)trimToSize:(NSUInteger)trimByteCount block:(TMDiskCacheBlock)block
{
    __weak TMDiskCache *weakSelf = self;
    
    dispatch_async(_queue, ^{
        TMDiskCache *strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }

        [strongSelf trimToSize:trimByteCount];

        if (block){
            block(strongSelf);
        }
    });
}

- (void)trimToDate:(NSDate *)trimDate block:(TMDiskCacheBlock)block
{
    __weak TMDiskCache *weakSelf = self;

    dispatch_async(_queue, ^{
        TMDiskCache *strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }

        [strongSelf trimToDate:trimDate];

        if (block){
            block(strongSelf);
        }
    });
}

- (void)trimToSizeByDate:(NSUInteger)trimByteCount block:(TMDiskCacheBlock)block
{
    __weak TMDiskCache *weakSelf = self;

    dispatch_async(_queue, ^{
        TMDiskCache *strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }

        [strongSelf trimToSizeByDate:trimByteCount];

        if (block){
            block(strongSelf);
        }
    });
}

- (void)removeAllObjects:(TMDiskCacheBlock)block
{
    __weak TMDiskCache *weakSelf = self;

    dispatch_async(_queue, ^{
        TMDiskCache *strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }

        [strongSelf removeAllObjects];

        if (block){
            block(strongSelf);
        }
    });
}

- (void)enumerateObjectsWithBlock:(TMDiskCacheObjectBlock)block completionBlock:(TMDiskCacheBlock)completionBlock
{
    __weak TMDiskCache *weakSelf = self;

    dispatch_async(_queue, ^{
        TMDiskCache *strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }

        [strongSelf enumerateObjectsWithBlock:block];

        if (completionBlock){
            completionBlock(strongSelf);
        }
    });
}

#pragma mark - Public Synchronous Methods -
- (void)synchronouslyLockFileAccessWhileExecutingBlock:(void(^)(TMDiskCache *diskCache))block
{
    if (block) {
        [self lock];
        block(self);
        [self unlock];
    }
}

- (id <NSCoding>)objectForKey:(NSString *)key
{
    NSDate *now = [[NSDate alloc] init];
    
    if (!key)
        return nil;
    
    id <NSCoding> object = nil;
    
    [self lock];
    NSURL *fileURL = [self encodedFileURLForKey:key];
    if ([[NSFileManager defaultManager] fileExistsAtPath:[fileURL path]]) {
        @try {
            object = [NSKeyedUnarchiver unarchiveObjectWithFile:[fileURL path]];
        }
        @catch (NSException *exception) {
            NSError *error = nil;
            [[NSFileManager defaultManager] removeItemAtPath:[fileURL path] error:&error];
            TMDiskCacheError(error);
        }
        
        [self setFileModificationDate:now forURL:fileURL];
    }
    [self unlock];
    
    return object;
}

- (NSURL *)fileURLForKey:(NSString *)key
{
    NSDate *now = [[NSDate alloc] init];
    
    if (!key)
        return nil;
    
    NSURL *fileURLForKey = nil;
    
    [self lock];
    fileURLForKey = [self encodedFileURLForKey:key];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[fileURLForKey path]]) {
        [self setFileModificationDate:now forURL:fileURLForKey];
    } else {
        fileURLForKey = nil;
    }
    [self unlock];
    
    return fileURLForKey;
}

- (void)setObject:(id <NSCoding>)object forKey:(NSString *)key
{
    NSDate *now = [[NSDate alloc] init];
    
    if (!object || !key)
        return;
    
    TMCacheStartBackgroundTask();
    
    [self lock];
    NSURL *fileURL = [self encodedFileURLForKey:key];
    
    if (self->_willAddObjectBlock)
        self->_willAddObjectBlock(self, key, object, fileURL);
    
    BOOL written = [NSKeyedArchiver archiveRootObject:object toFile:[fileURL path]];
    
    if (written) {
        [self setFileModificationDate:now forURL:fileURL];
        
        NSError *error = nil;
        NSDictionary *values = [fileURL resourceValuesForKeys:@[ NSURLTotalFileAllocatedSizeKey ] error:&error];
        TMDiskCacheError(error);
        
        NSNumber *diskFileSize = [values objectForKey:NSURLTotalFileAllocatedSizeKey];
        if (diskFileSize) {
            NSNumber *oldEntry = [self->_sizes objectForKey:key];
            
            if ([oldEntry isKindOfClass:[NSNumber class]]){
                self.byteCount = self->_byteCount - [oldEntry unsignedIntegerValue];
            }
            
            [self->_sizes setObject:diskFileSize forKey:key];
            self.byteCount = self->_byteCount + [diskFileSize unsignedIntegerValue]; // atomic
        }
        
        if (self->_byteLimit > 0 && self->_byteCount > self->_byteLimit)
            [self trimToSizeByDate:self->_byteLimit block:nil];
    } else {
        fileURL = nil;
    }
    
    if (self->_didAddObjectBlock)
        self->_didAddObjectBlock(self, key, object, written ? fileURL : nil);
    [self unlock];
    
    TMCacheEndBackgroundTask();
}

- (void)removeObjectForKey:(NSString *)key
{
    if (!key)
        return;
    
    TMCacheStartBackgroundTask();
    
    [self lock];
    [self removeFileAndExecuteBlocksForKey:key];
    [self unlock];
    
    TMCacheEndBackgroundTask();
}

- (void)trimToSize:(NSUInteger)byteCount
{
    if (byteCount == 0) {
        [self removeAllObjects];
        return;
    }
    
    TMCacheStartBackgroundTask();
    
    [self lock];
    [self trimDiskToSize:byteCount];
    [self unlock];
    
    TMCacheEndBackgroundTask();
}

- (void)trimToDate:(NSDate *)date
{
    if (!date)
        return;

    if ([date isEqualToDate:[NSDate distantPast]]) {
        [self removeAllObjects];
        return;
    }

    TMCacheStartBackgroundTask();
    
    [self lock];
    [self trimDiskToDate:date];
    [self unlock];
    
    TMCacheEndBackgroundTask();
}

- (void)trimToSizeByDate:(NSUInteger)byteCount
{
    if (byteCount == 0) {
        [self removeAllObjects];
        return;
    }
    
    TMCacheStartBackgroundTask();
    
    [self lock];
    [self trimDiskToSizeByDate:byteCount];
    [self unlock];
    
    TMCacheEndBackgroundTask();
}

- (void)removeAllObjects
{
    TMCacheStartBackgroundTask();
    
    [self lock];
    if (self->_willRemoveAllObjectsBlock)
        self->_willRemoveAllObjectsBlock(self);
    
    [TMDiskCache moveItemAtURLToTrash:self->_cacheURL];
    [TMDiskCache emptyTrash];
    
    [self createCacheDirectory];
    
    [self->_dates removeAllObjects];
    [self->_sizes removeAllObjects];
    self.byteCount = 0; // atomic
    
    if (self->_didRemoveAllObjectsBlock)
        self->_didRemoveAllObjectsBlock(self);
    [self unlock];
    
    TMCacheEndBackgroundTask();
}

- (void)enumerateObjectsWithBlock:(TMDiskCacheObjectBlock)block
{
    if (!block)
        return;
    
    TMCacheStartBackgroundTask();
    
    [self lock];
    NSArray *keysSortedByDate = [self->_dates keysSortedByValueUsingSelector:@selector(compare:)];
    
    for (NSString *key in keysSortedByDate) {
        NSURL *fileURL = [self encodedFileURLForKey:key];
        block(self, key, nil, fileURL);
    }
    [self unlock];
    
    TMCacheEndBackgroundTask();
}

#pragma mark - Public Thread Safe Accessors -

- (TMDiskCacheObjectBlock)willAddObjectBlock
{
    TMDiskCacheObjectBlock block = nil;

    [self lock];
    block = _willAddObjectBlock;
    [self unlock];

    return block;
}

- (void)setWillAddObjectBlock:(TMDiskCacheObjectBlock)block
{
    [self lock];
    _willAddObjectBlock = [block copy];
    [self unlock];
}

- (TMDiskCacheObjectBlock)willRemoveObjectBlock
{
    TMDiskCacheObjectBlock block = nil;
    
    [self lock];
    block = _willRemoveObjectBlock;
    [self unlock];

    return block;
}

- (void)setWillRemoveObjectBlock:(TMDiskCacheObjectBlock)block
{
    [self lock];
    _willRemoveObjectBlock = [block copy];
    [self unlock];
}

- (TMDiskCacheBlock)willRemoveAllObjectsBlock
{
    TMDiskCacheBlock block = nil;

    [self lock];
    block = _willRemoveAllObjectsBlock;
    [self unlock];

    return block;
}

- (void)setWillRemoveAllObjectsBlock:(TMDiskCacheBlock)block
{
    [self lock];
    _willRemoveAllObjectsBlock = [block copy];
    [self unlock];
}

- (TMDiskCacheObjectBlock)didAddObjectBlock
{
    TMDiskCacheObjectBlock block = nil;

    [self lock];
    block = _didAddObjectBlock;
    [self unlock];

    return block;
}

- (void)setDidAddObjectBlock:(TMDiskCacheObjectBlock)block
{
    [self lock];
    _didAddObjectBlock = [block copy];
    [self unlock];
}

- (TMDiskCacheObjectBlock)didRemoveObjectBlock
{
    TMDiskCacheObjectBlock block = nil;

    [self lock];
    block = _didRemoveObjectBlock;
    [self unlock];

    return block;
}

- (void)setDidRemoveObjectBlock:(TMDiskCacheObjectBlock)block
{
    [self lock];
    _didRemoveObjectBlock = [block copy];
    [self unlock];
}

- (TMDiskCacheBlock)didRemoveAllObjectsBlock
{
    TMDiskCacheBlock block = nil;

    [self lock];
    block = _didRemoveAllObjectsBlock;
    [self unlock];
    
    return block;
}

- (void)setDidRemoveAllObjectsBlock:(TMDiskCacheBlock)block
{
    [self lock];
    _didRemoveAllObjectsBlock = [block copy];
    [self unlock];
}

- (NSUInteger)byteLimit
{
    NSUInteger byteLimit = 0;
    
    [self lock];
    byteLimit = _byteLimit;
    [self unlock];
    
    return byteLimit;
}

- (void)setByteLimit:(NSUInteger)byteLimit
{
    __weak TMDiskCache *weakSelf = self;
    
    dispatch_async(_queue, ^{
        TMDiskCache *strongSelf = weakSelf;
        if (!strongSelf)
            return;
        
        [strongSelf lock];
        strongSelf->_byteLimit = byteLimit;

        if (byteLimit > 0)
            [strongSelf trimDiskToSizeByDate:byteLimit];
        [strongSelf unlock];
    });
}

- (NSTimeInterval)ageLimit
{
    NSTimeInterval ageLimit = 0.0;
    
    [self lock];
    ageLimit = _ageLimit;
    [self unlock];
    
    return ageLimit;
}

- (void)setAgeLimit:(NSTimeInterval)ageLimit
{
    __weak TMDiskCache *weakSelf = self;
    
    dispatch_async(_queue, ^{
        TMDiskCache *strongSelf = weakSelf;
        if (!strongSelf)
            return;
        
        [strongSelf lock];
        strongSelf->_ageLimit = ageLimit;
        [strongSelf unlock];
        
        [self trimToAgeLimitRecursively];
    });
}

#pragma mark - Lock&Unlock
- (void)lock
{
    dispatch_semaphore_wait(_lockSemaphore, DISPATCH_TIME_FOREVER);
}

- (void)unlock
{
    dispatch_semaphore_signal(_lockSemaphore);
}

@end
