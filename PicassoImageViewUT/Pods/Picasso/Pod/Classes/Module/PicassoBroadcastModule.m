//
//  PicassoBaseModule.m
//  Pods
//
//  Created by 纪鹏 on 2017/5/17.
//
//

#import "PicassoBroadcastModule.h"
#import "PicassoThreadManager.h"

@interface PicassoCallBack (Private)
@property (nonatomic, copy) NSString *callbackId;
@end


@interface PicassoBroadcastObserver:NSObject
@property (nonatomic, strong) PicassoCallBack *callback;
- (void)onBroadcast:(NSNotification *)notification;
@end

@implementation PicassoBroadcastObserver

- (void)onBroadcast:(NSNotification *)notification {
    NSString *returnInfo = notification.userInfo[@"info"];
    NSDictionary *infoDic = nil;
    if ([returnInfo isKindOfClass:[NSString class]]) {
        infoDic = @{@"info":returnInfo};
    }
    [self.callback sendNext:infoDic];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

@interface PicassoBroadcastModule ()
@property (atomic, strong) NSMutableDictionary<NSString *, NSDictionary <NSString *, PicassoBroadcastObserver *> *> *eventCallBacks;
@end

@implementation PicassoBroadcastModule

PCS_EXPORT_METHOD(@selector(subscribe:callback:))
PCS_EXPORT_METHOD(@selector(unSubscribe:))
PCS_EXPORT_METHOD(@selector(publish:callback:))

- (instancetype)init {
    if (self = [super init]) {
        _eventCallBacks = [NSMutableDictionary new];
    }
    return self;
}

- (NSString *)subscribe:(NSDictionary *)params callback:(nullable PicassoCallBack *)callback {
    NSString *eventName = params[@"action"];
    if (eventName.length > 0 && callback && callback.callbackId.length > 0) {
        NSMutableDictionary *callbackDic = [self.eventCallBacks[eventName] mutableCopy];
        if (!callbackDic) {
            callbackDic = [NSMutableDictionary new];
        }
        PicassoBroadcastObserver *observer = [PicassoBroadcastObserver new];
        observer.callback = callback;
        [callbackDic setObject:observer forKey:callback.callbackId];
        [self.eventCallBacks setObject:[callbackDic copy] forKey:eventName];
        [[NSNotificationCenter defaultCenter] addObserver:observer selector:@selector(onBroadcast:) name:eventName object:nil];
        return callback.callbackId;
    }
    return @"";
}

- (void)unSubscribe:(NSDictionary *)params {
    NSString *eventName = params[@"action"];
    NSString *handleId = params[@"handleId"];
    if (eventName.length > 0 && handleId.length > 0) {
        NSMutableDictionary *callbackDic = [self.eventCallBacks[eventName] mutableCopy];
        [[NSNotificationCenter defaultCenter] removeObserver:callbackDic[handleId] name:eventName object:nil];
        [callbackDic removeObjectForKey:handleId];
        self.eventCallBacks[eventName] = [callbackDic copy];
    }
}

- (void)publish:(NSDictionary *)params callback:(nullable PicassoCallBack *)callback {
    NSString *eventName = params[@"action"];
    NSString *info = params[@"info"];
    if (eventName.length > 0) {
        PCSRunOnMainThread(^{
            [[NSNotificationCenter defaultCenter] postNotificationName:eventName object:nil userInfo:(info.length > 0 ? @{@"info":info} : nil)];
        });
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
