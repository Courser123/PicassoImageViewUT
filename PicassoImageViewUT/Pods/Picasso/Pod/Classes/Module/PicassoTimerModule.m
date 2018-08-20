//
//  PicassoTimerModule.m
//  Pods
//
//  Created by 纪鹏 on 2017/6/26.
//

#import "PicassoTimerModule.h"
#import "PicassoDefine.h"
#import "PicassoHostManager.h"

@interface PicassoTimerTarget : NSObject
- (instancetype)initWithCallback:(PicassoCallBack *)callback repeat:(BOOL)repeat;
@end

@implementation PicassoTimerTarget
{
    PicassoCallBack *_callback;
    BOOL _repeat;
}

- (instancetype)initWithCallback:(PicassoCallBack *)callback repeat:(BOOL)repeat {
    if (self = [super init]) {
        _callback = callback;
        _repeat = repeat;
    }
    return self;
}

- (void)fire {
    if (_repeat) {
        [_callback sendNext:nil];
    } else {
        [_callback sendSuccess:nil];
    }
}

@end

@interface PicassoCallBack (Private)
@property (nonatomic, copy) NSString *callbackId;
@end

@interface PicassoTimerModule ()
@property (atomic, strong) NSMutableDictionary *timerDic;
@end

@implementation PicassoTimerModule

PCS_EXPORT_METHOD(@selector(setTimeout:callback:))
PCS_EXPORT_METHOD(@selector(setInterval:callback:))
PCS_EXPORT_METHOD(@selector(clearTimer:))

- (instancetype)init {
    if (self = [super init]) {
        _timerDic = [NSMutableDictionary new];
    }
    return self;
}

- (NSString *)setTimeout:(NSDictionary *)params callback:(PicassoCallBack *)callback {
    NSTimeInterval time = [[params objectForKey:@"time"] doubleValue];
    [self createTimerWithInterval:time repeat:NO callback:callback];
    return callback.callbackId;
}

- (NSString *)setInterval:(NSDictionary *)params callback:(PicassoCallBack *)callback {
    NSTimeInterval time = [[params objectForKey:@"time"] doubleValue];
    [self createTimerWithInterval:time repeat:YES callback:callback];
    return callback.callbackId;
}

- (void)clearTimer:(NSDictionary *)params {
    NSString *callbackId = params[@"handleId"];
    if (callbackId.length > 0) {
        NSTimer *timer = self.timerDic[callbackId];
        if (!timer) {
            return;
        }
        [timer invalidate];
        [self.timerDic removeObjectForKey:callbackId];
    }
}

- (void)createTimerWithInterval:(NSTimeInterval)milliseconds repeat:(BOOL)repeat callback:(PicassoCallBack *)callback {
    if (!callback) {
        NSLog(@"error:callbackid is empty");
        return;
    }
    PicassoTimerTarget *target = [[PicassoTimerTarget alloc] initWithCallback:callback repeat:repeat];
    [self createTimerWithTarget:target selector:@selector(fire) interval:milliseconds repeat:repeat callback:callback];
}

- (void)createTimerWithTarget:(PicassoTimerTarget *)target selector:(SEL)sel interval:(NSTimeInterval)milliseconds repeat:(BOOL)repeat callback:(PicassoCallBack *)callback {
    if (!callback) {
        return;
    }
    NSTimer *timer = [NSTimer timerWithTimeInterval:milliseconds/1000.0f target:target selector:sel userInfo:nil repeats:repeat];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    if (!_timerDic[callback.callbackId] && callback.callbackId.length > 0) {
        [_timerDic setObject:timer forKey:callback.callbackId];
    }
}

- (void)dealloc {
    for (NSTimer *timer in _timerDic.allValues) {
        [timer invalidate];
    }
    [_timerDic removeAllObjects];
    _timerDic = nil;
}

@end
