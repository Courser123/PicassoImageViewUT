//
//  PicassoHostManager.m
//  Pods
//
//  Created by 纪鹏 on 2017/5/26.
//
//

#import "PicassoHostManager.h"
#import "PicassoReadWriteLock.h"

@interface PicassoHostManager ()
@property (atomic, strong) NSDictionary *hostMapper;
@property (nonatomic, strong) PicassoLock *lock;
@end

@implementation PicassoHostManager

+ (PicassoHostManager *)_instance {
    static PicassoHostManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[PicassoHostManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _hostMapper = [NSDictionary new];
        _lock = [PicassoLock new];
    }
    return self;
}

+ (void)saveHost:(PicassoHost *)host forHostId:(NSString *)hId {
    if (host && hId.length > 0) {
        [[self _instance].lock lock];
        NSMutableDictionary *mutableDic = [[self _instance].hostMapper mutableCopy];
        [mutableDic setObject:host forKey:hId];
        [self _instance].hostMapper = [NSDictionary dictionaryWithDictionary:mutableDic];
        [[self _instance].lock unlock];
    }
}

+ (PicassoHost *)hostForId:(NSString *)hId {
    if (hId.length == 0) {
        return nil;
    }
    return [[self _instance].hostMapper objectForKey:hId];
}

+ (void)removeHostFotId:(NSString *)hId {
    if (hId.length > 0) {
        [[self _instance].lock lock];
        NSMutableDictionary *mutableDic = [[self _instance].hostMapper mutableCopy];
        [mutableDic removeObjectForKey:hId];
        [self _instance].hostMapper = [NSDictionary dictionaryWithDictionary:mutableDic];
        [[self _instance].lock unlock];
    }
}

@end
