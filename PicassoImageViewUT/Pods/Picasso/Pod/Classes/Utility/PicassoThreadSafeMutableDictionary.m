//
//  PicassoThreadSafeMutableDictionary.m
//  clogan
//
//  Created by 纪鹏 on 2017/9/18.
//

#import "PicassoThreadSafeMutableDictionary.h"
#import "PicassoReadWriteLock.h"

@interface PicassoThreadSafeMutableDictionary ()

@property (nonatomic, strong) PicassoLock *lock;
@property (nonatomic, strong) NSMutableDictionary* dict;

@end


@implementation PicassoThreadSafeMutableDictionary

- (instancetype)initCommon
{
    self = [super init];
    if (self) {
        _lock = [PicassoLock new];
    }
    return self;
}

- (instancetype)init
{
    self = [self initCommon];
    if (self) {
        _dict = [NSMutableDictionary dictionary];
    }
    return self;
}

- (instancetype)initWithCapacity:(NSUInteger)numItems
{
    self = [self initCommon];
    if (self) {
        _dict = [NSMutableDictionary dictionaryWithCapacity:numItems];
    }
    return self;
}

- (NSDictionary *)initWithContentsOfFile:(NSString *)path
{
    self = [self initCommon];
    if (self) {
        _dict = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [self initCommon];
    if (self) {
        _dict = [[NSMutableDictionary alloc] initWithCoder:aDecoder];
    }
    return self;
}

- (instancetype)initWithObjects:(const id [])objects forKeys:(const id<NSCopying> [])keys count:(NSUInteger)cnt
{
    self = [self initCommon];
    if (self) {
        _dict = [NSMutableDictionary dictionary];
        for (NSUInteger i = 0; i < cnt; ++i) {
            _dict[keys[i]] = objects[i];
        }
        
    }
    return self;
}

- (NSUInteger)count
{
    [self.lock lock];
     NSUInteger count = _dict.count;
    [self.lock unlock];
    return count;
}

- (id)objectForKey:(id)aKey
{
    [self.lock lock];
    id obj = _dict[aKey];
    [self.lock unlock];
    return obj;
}

- (NSArray *)allKeys {
    [self.lock lock];
    NSArray *arr = [_dict allKeys];
    [self.lock unlock];
    return arr;
}

- (NSEnumerator *)keyEnumerator
{
    [self.lock lock];
    NSEnumerator *enu = [_dict keyEnumerator];
    [self.lock unlock];
    return enu;
}

- (void)setObject:(id)anObject forKey:(id<NSCopying>)aKey
{
    aKey = [aKey copyWithZone:NULL];
    [self.lock lock];
    _dict[aKey] = anObject;
    [self.lock unlock];
}

- (void)removeObjectForKey:(id)aKey
{
    [self.lock lock];
    [_dict removeObjectForKey:aKey];
    [self.lock unlock];
}

- (void)removeAllObjects{
    [self.lock lock];
    [_dict removeAllObjects];
    [self.lock unlock];
}

- (id)copy{
    [self.lock lock];
    id copyInstance = [_dict copy];
    [self.lock unlock];
    return copyInstance;
}

@end
