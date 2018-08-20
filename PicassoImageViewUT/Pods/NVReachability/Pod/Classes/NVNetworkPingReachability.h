//
//  NVNetworkPingReachability.h
//  Pods
//
//  Created by yxn on 2016/11/18.
//
//

#import <Foundation/Foundation.h>
#import "NVNetworkPingItem.h"

@interface NVNetworkPingReachability : NSObject

@property(nonatomic,assign) double      timeout;//ms
@property(nonatomic,assign) NSInteger  maxPingTimes;

+ (NVNetworkPingReachability *)startPingHost:(NSString *)hostName callback:(void(^)(NVNetworkPingItem *pingItem, NSArray *pingItems))handler;
- (void)startPing;
- (void)cancel;

@end
