//
//  PicassoReadWriteLock.m
//  clogan
//
//  Created by 纪鹏 on 2017/9/26.
//

#import "PicassoReadWriteLock.h"

@interface PicassoLock()
@property (nonatomic, strong) dispatch_semaphore_t semaphore;
@end

@implementation PicassoLock

- (instancetype)init {
    if (self = [super init]) {
        _semaphore = dispatch_semaphore_create(1);
    }
    return self;
}

- (void)lock {
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
}

- (void)unlock {
    dispatch_semaphore_signal(self.semaphore);
}

@end

@interface PicassoReadWriteLock ()
@property (nonatomic, strong) PicassoLock *readLock;
@property (nonatomic, strong) PicassoLock *writeLock;
@property (nonatomic, assign) NSUInteger readCount;
@end



@implementation PicassoReadWriteLock

- (instancetype)init {
    if (self = [super init]) {
        _readLock = [PicassoLock new];
        _writeLock = [PicassoLock new];
        _readCount = 0;
    }
    return self;
}

- (void)lockRead {
    [self.readLock lock];
    self.readCount++;
    if (self.readCount >= 1) {
        [self.writeLock lock];
    }
}

- (void)unLockRead {
    self.readCount--;
    if (self.readCount == 0) {
        [self.writeLock unlock];
    }
    [self.readLock unlock];
}

- (void)lockWrite {
    [self.writeLock lock];
}

- (void)unLockWrite {
    [self.writeLock unlock];
}


@end
