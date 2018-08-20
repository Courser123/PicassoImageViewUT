//
//  PicassoThreadManager.m
//  Picasso
//
//  Created by 纪鹏 on 2017/12/6.
//

#import "PicassoThreadManager.h"
#import "PicassoDefine.h"

#pragma mark - PicassoBridgeThread
@interface PicassoBridgeThread: NSObject
@property (nonatomic, assign) BOOL stopRunning;
+ (instancetype)instance;
- (void)bridgeRunLoop;
@end

@implementation PicassoBridgeThread

+ (instancetype)instance {
    static PicassoBridgeThread *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[PicassoBridgeThread alloc] init];
    });
    return _instance;
    
}

- (void)bridgeRunLoop {
    [[NSRunLoop currentRunLoop] addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
    
    while (!_stopRunning) {
        @autoreleasepool {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
    }
}
@end

#pragma mark - PicassoViewComputeThread
@interface PicassoViewComputeThread: NSObject
@property (nonatomic, assign) BOOL stopRunning;
+ (instancetype)instance;
- (void)computeRunLoop;
@end

@implementation PicassoViewComputeThread

+ (instancetype)instance {
    static PicassoViewComputeThread *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[PicassoViewComputeThread alloc] init];
    });
    return _instance;
    
}

- (void)computeRunLoop {
    [[NSRunLoop currentRunLoop] addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
    
    while (!_stopRunning) {
        @autoreleasepool {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
    }
}
@end


#pragma mark - PicassoThreadManager
static NSThread *PCSBridgeThread;
static NSThread *PCSViewComputeThread;

@implementation PicassoThreadManager

+ (instancetype)manager {
    static PicassoThreadManager *_manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[PicassoThreadManager alloc] init];
    });
    return _manager;
}

#pragma mark - bridgeThread
+ (NSThread *)_bridgeThread
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PCSBridgeThread = [[NSThread alloc] initWithTarget:[PicassoBridgeThread instance] selector:@selector(bridgeRunLoop) object:nil];
        [PCSBridgeThread setName:PCS_BRIDGE_THREAD_NAME];
        [PCSBridgeThread setQualityOfService:[[NSThread mainThread] qualityOfService]];
        [PCSBridgeThread start];
    });
    
    return PCSBridgeThread;
}


void PCSRunOnBridgeThread(void (^block)(void))
{
    [PicassoThreadManager _runOnBridgeThread:block];
}

+ (void)_runOnBridgeThread:(void (^)(void))block
{
    if ([NSThread currentThread] == [self _bridgeThread]) {
        block();
    } else {
        [self performSelector:@selector(_runOnBridgeThread:)
                     onThread:[self _bridgeThread]
                   withObject:[block copy]
                waitUntilDone:NO];
    }
}

#pragma mark - viewComputeThread
+ (NSThread *)_viewComputeThread
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PCSViewComputeThread = [[NSThread alloc] initWithTarget:[PicassoViewComputeThread instance] selector:@selector(computeRunLoop) object:nil];
        [PCSViewComputeThread setName:PCS_VIEW_COMPUTE_THREAD_NAME];
        [PCSViewComputeThread setQualityOfService:NSQualityOfServiceUserInitiated];
        [PCSViewComputeThread start];
    });
    
    return PCSViewComputeThread;
}


void PCSRunOnViewComputeThread(void (^block)(void))
{
    [PicassoThreadManager _runOnViewComputeThread:block];
}

+ (void)_runOnViewComputeThread:(void (^)(void))block
{
    if ([NSThread currentThread] == [self _viewComputeThread]) {
        block();
    } else {
        [self performSelector:@selector(_runOnViewComputeThread:)
                     onThread:[self _viewComputeThread]
                   withObject:[block copy]
                waitUntilDone:NO];
    }
}


void PCSRunOnMainThread(void (^ _Nonnull block)(void))
{
    if (!block) return;
    
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            block();
        });
    }
}

@end

