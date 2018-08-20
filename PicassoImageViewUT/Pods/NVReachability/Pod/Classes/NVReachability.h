//
//  NVReachability.h
//  NVReachability
//
//  Created by ZhouHui on 16/1/8.
//  Copyright © 2016年 dianping. All rights reserved.
//
#import <SystemConfiguration/SystemConfiguration.h>
#import "NVNetworkReachability.h"

@class NVReachability;

typedef enum {
    NotReachable = 0,
    ReachableViaWiFi,
    ReachableViaWWAN
} NetworkStatus;

// 网络状态变化的通知，object为NVReachability
#define NVReachabilityChanged @"networkReachabilityChanged"

// 移动接入点变化的通知，object为NVReachability
#define NVReachabilityMobileNetworStatusDidChange @"NVReachabilityMobileNetworStatusDidChange"

@interface NVReachability: NSObject
{
    BOOL localWiFiRef;
    SCNetworkReachabilityRef reachabilityRef;
}

//reachabilityWithHostName- Use to check the reachability of a particular host name.
+ (NVReachability*) reachabilityWithHostName: (NSString*) hostName;

//reachabilityWithAddress- Use to check the reachability of a particular IP address.
+ (NVReachability*) reachabilityWithAddress: (const struct sockaddr_in*) hostAddress;

//reachabilityForInternetConnection- checks whether the default route is available.
//  Should be used by applications that do not connect to a particular host
+ (NVReachability*) reachabilityForInternetConnection;

//reachabilityForLocalWiFi- checks whether a local wifi connection is available.
+ (NVReachability*) reachabilityForLocalWiFi;

//Start listening for reachability notifications on the current run loop
- (BOOL) startNotifer;
- (void) stopNotifer;

// 获取当前网络状态
- (NetworkStatus)currentReachabilityStatus;

// 新的API，获取当前详细网络状态，包含3G 4G等
- (NVNetworkReachability)currentAccurateReachabilityStatus;

//WWAN may be available, but not active until a connection has been established.
//WiFi may require a connection for VPN on Demand.
- (BOOL) connectionRequired;


@end
