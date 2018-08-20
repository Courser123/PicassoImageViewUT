//
//  NVNetworkType.h
//  Core
//
//  Created by Yimin Tu on 12-7-1.
//  Copyright (c) 2012年 dianping.com. All rights reserved.
//



typedef enum {
    NVNetworkReachabilityNone = 0,
    NVNetworkReachabilityWifi = 1,
    NVNetworkReachabilityMobile = 2,
    NVNetworkReachabilityMobile2G = 3,
    NVNetworkReachabilityMobile3G = 4,
    NVNetworkReachabilityMobile4G = 5,
} NVNetworkReachability;

extern NVNetworkReachability NVGetNetworkReachability();

extern NVNetworkReachability NVGetAccurateNetworkReachability();




/**
 同步获取网络状态，可能比较耗时，如果对实时性要求不高可以使用NVGetNetworkReachability()方法。
 
 @return NVNetworkReachability
 */
extern NVNetworkReachability NVSyncGetNetworkReachability();

extern NVNetworkReachability NVSyncGetAccurateNetworkReachability();



