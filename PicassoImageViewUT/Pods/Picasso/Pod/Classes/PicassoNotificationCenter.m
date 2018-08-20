//
//  PicassoNotificationCenter.m
//  Picasso
//
//  Created by xiebohui on 07/12/2016.
//  Copyright © 2016 xiebohui. All rights reserved.
//

#import "PicassoNotificationCenter.h"

static NSMutableDictionary *PicassoDefaultObservers = nil;
static NSString *kPicassoDefaultObserverSchemeKey = @"PicassoDefaultObserverSchemeKey";
static NSString *kPicassoDefaultObserverGAClickKey = @"PicassoDefaultObserverGAClickKey";
static NSString *kPicassoDefaultObserverGAUpdateKey = @"PicassoDefaultObserverGAUpdateKey";

@implementation PicassoNotificationUserInfo

- (instancetype)initWithViewTag:(NSString *)viewTag userInfo:(NSDictionary *)userInfo {
    self = [self init];
    if (self) {
        _viewTag = viewTag;
        _userInfo = userInfo;
    }
    return self;
}

@end

@interface PicassoNotificationCenter()

@property (nonatomic, strong) NSDictionary *observers;
@property (nonatomic, strong) NSMutableDictionary *observersForTag;
@property (nonatomic, strong) NSMutableDictionary *customObservers;

@end

@implementation PicassoNotificationCenter

+ (void)initialize {
    PicassoDefaultObservers = [NSMutableDictionary dictionary];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _observersForTag = [NSMutableDictionary dictionary];
        _customObservers = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSDictionary *)observers {
    if (!_observers) {
        PicassoNotificationBlock schemeBlock = PicassoDefaultObservers[kPicassoDefaultObserverSchemeKey];
        PicassoNotificationBlock gaClickBlock = PicassoDefaultObservers[kPicassoDefaultObserverGAClickKey];
        PicassoNotificationBlock gaUpdateBlock = PicassoDefaultObservers[kPicassoDefaultObserverGAUpdateKey];
        NSMutableDictionary *observers = [NSMutableDictionary dictionary];
        NSMutableArray *clickBlockArray = [NSMutableArray array];
        NSMutableArray *updateBlockArray = [NSMutableArray array];
        if (schemeBlock) {
            [clickBlockArray addObject:schemeBlock];
        }
        if (gaClickBlock) {
            [clickBlockArray addObject:gaClickBlock];
        }
        if (gaUpdateBlock) {
            [updateBlockArray addObject:gaUpdateBlock];
        }
        observers[@(PicassoControlEventClick)] = [clickBlockArray copy];
        observers[@(PicassoControlEventUpdate)] = [updateBlockArray copy];
        _observers = [observers copy];
    }
    return _observers;
}

- (void)postNotificationName:(PicassoControlEvents)aName userInfo:(PicassoNotificationUserInfo *)aUserInfo {
    NSArray *defaultBlocks = [self.observers objectForKey:@(aName)];
    if (defaultBlocks) {
        for (PicassoNotificationBlock block in defaultBlocks) {
            block(aUserInfo);
        }
    }
    if (aUserInfo.viewTag.length > 0) {
        PicassoNotificationBlock block = [self.observersForTag objectForKey:[NSString stringWithFormat:@"%@:%@", @(aName), aUserInfo.viewTag]];
        if (block) {
            block(aUserInfo);
        }
    }
    PicassoNotificationBlock customBlock = [self.customObservers objectForKey:@(aName)];
    if (customBlock) {
        customBlock(aUserInfo);
    }
}

- (void)addObserverForName:(PicassoControlEvents)name usingBlock:(void (^)(PicassoNotificationUserInfo *))block {
    [_customObservers setObject:[block copy] forKey:@(name)];
}

- (void)addObserverForName:(PicassoControlEvents)name viewTag:(NSString *)viewTag usingBlock:(PicassoNotificationBlock)block {
    [_observersForTag setObject:[block copy] forKey:[NSString stringWithFormat:@"%@:%@", @(name), viewTag]];
}

+ (void)registerSchemeCallback:(PicassoNotificationBlock)notificationBlock {
    if (!notificationBlock) {
        notificationBlock = ^(PicassoNotificationUserInfo *userinfo){};
    }
    [PicassoDefaultObservers setObject:[notificationBlock copy] forKey:kPicassoDefaultObserverSchemeKey];
}

+ (void)registerGAClickCallback:(PicassoNotificationBlock)notificationBlock {
    if (!notificationBlock) {
        notificationBlock = ^(PicassoNotificationUserInfo *userinfo){};
    }
    [PicassoDefaultObservers setObject:[notificationBlock copy] forKey:kPicassoDefaultObserverGAClickKey];
}

+ (void)registerGAUpdateCallback:(PicassoNotificationBlock)notificationBlock
{
    if (!notificationBlock) {
        notificationBlock = ^(PicassoNotificationUserInfo *userinfo){};
    }
    [PicassoDefaultObservers setObject:[notificationBlock copy] forKey:kPicassoDefaultObserverGAUpdateKey];
}

@end
