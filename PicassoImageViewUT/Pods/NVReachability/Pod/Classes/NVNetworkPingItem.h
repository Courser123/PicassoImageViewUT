//
//  NVNetworkPingItem.h
//  Pods
//
//  Created by yxn on 2016/11/20.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger ,NVNetworkPingStatus) {
    NVNetworkPingStatusDidStart,
    NVNetworkPingStatusDidFailToSendPacket,
    NVNetworkPingStatusDidReceivePacket,
    NVNetworkPingStatusDidReceiveUnexpectedPacket,
    NVNetworkPingStatusDidTimeout,
    NVNetworkPingStatusError,
    NVNetworkPingStatusFinished
};


@interface NVNetworkPingItem : NSObject

@property(nonatomic, copy) NSString *originalAddress;
@property(nonatomic, copy) NSString *IPAddress;

@property(nonatomic,assign) NSUInteger dateBytesLength;
@property(nonatomic,assign) double     timeMilliseconds;
@property(nonatomic,assign) NSInteger  timeToLive;
@property(nonatomic,assign) NSInteger  ICMPSequence;
@property(nonatomic) NVNetworkPingStatus status;

+ (NSString *)statisticsWithPingItems:(NSArray *)pingItems;
+ (BOOL)isNetworkReachableWithPingItems:(NSArray *)pingItems;
@end
