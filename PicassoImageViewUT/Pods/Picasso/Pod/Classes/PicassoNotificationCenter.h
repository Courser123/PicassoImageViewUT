//
//  PicassoNotificationCenter.h
//  Picasso
//
//  Created by xiebohui on 07/12/2016.
//  Copyright © 2016 xiebohui. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PicassoNotificationUserInfo;

typedef NS_ENUM(NSInteger, PicassoControlEvents) {
    PicassoControlEventClick = 1,
    PicassoControlEventUpdate = 2
};
typedef void(^PicassoNotificationBlock)(PicassoNotificationUserInfo *userinfo);

@interface PicassoNotificationUserInfo : NSObject

@property (nonatomic, copy) NSString *viewTag;
@property (nonatomic, strong) NSDictionary *userInfo;

- (instancetype)initWithViewTag:(NSString *)viewTag userInfo:(NSDictionary *)userInfo;

@end

@interface PicassoNotificationCenter : NSObject

- (void)postNotificationName:(PicassoControlEvents)aName userInfo:(PicassoNotificationUserInfo *)aUserInfo;
- (void)addObserverForName:(PicassoControlEvents)name usingBlock:(PicassoNotificationBlock)block;
- (void)addObserverForName:(PicassoControlEvents)name viewTag:(NSString *)viewTag usingBlock:(PicassoNotificationBlock)block;

@end
