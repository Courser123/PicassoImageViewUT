//
//  NVNetworkType.m
//  Core
//
//  Created by Yimin Tu on 12-7-1.
//  Copyright (c) 2012年 dianping.com. All rights reserved.
//
#import "NVNetworkReachability.h"
#import "CoreTelephony/CTTelephonyNetworkInfo.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>

#import <sys/socket.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>

#import <CoreFoundation/CoreFoundation.h>

#import "NVReachability.h"

NVNetworkReachability NVGetNetworkReachability() {
    NVNetworkReachability ret = [[NVReachability reachabilityForInternetConnection] currentAccurateReachabilityStatus];
    if (ret == NVNetworkReachabilityMobile2G
        || ret == NVNetworkReachabilityMobile3G
        || ret == NVNetworkReachabilityMobile4G) {
        ret = NVNetworkReachabilityMobile;
    }
    return ret;
}

NVNetworkReachability NVGetAccurateNetworkReachability()
{
    return [[NVReachability reachabilityForInternetConnection] currentAccurateReachabilityStatus];
}

static SCNetworkReachabilityRef __reachabilitySync = nil;
NVNetworkReachability NVSyncGetNetworkReachability() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        struct sockaddr_in zeroAddress;
        bzero(&zeroAddress, sizeof(zeroAddress));
        zeroAddress.sin_len = sizeof(zeroAddress);
        zeroAddress.sin_family = AF_INET;
        __reachabilitySync = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)&zeroAddress);
    });
    
    SCNetworkReachabilityFlags flags;
    if (__reachabilitySync && SCNetworkReachabilityGetFlags(__reachabilitySync, &flags)) {
        if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
        {
            // if target host is not reachable
            return NVNetworkReachabilityNone;
        }
        
        NVNetworkReachability retVal = NVNetworkReachabilityNone;
        
        if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
        {
            // if target host is reachable and no connection is required
            //  then we'll assume (for now) that your on Wi-Fi
            retVal = NVNetworkReachabilityWifi;
        }
        
        
        if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
             (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
        {
            // ... and the connection is on-demand (or on-traffic) if the
            //     calling application is using the CFSocketStream or higher APIs
            
            if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
            {
                // ... and no [user] intervention is needed
                retVal = NVNetworkReachabilityWifi;
            }
        }
        
        if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
        {
            // ... but WWAN connections are OK if the calling application
            //     is using the CFNetwork (CFSocketStream?) APIs.
            retVal = NVNetworkReachabilityMobile;
        }
        return retVal;
    }
    return NVNetworkReachabilityNone;
}
static CTTelephonyNetworkInfo * __telephonyNetworkInfoSync;
NVNetworkReachability NVSyncGetAccurateNetworkReachability()
{
    static  dispatch_once_t pred;
    dispatch_once(&pred, ^{
        __telephonyNetworkInfoSync = [CTTelephonyNetworkInfo new];
    });
    
    NVNetworkReachability reachability = NVSyncGetNetworkReachability();
    if (reachability == NVNetworkReachabilityMobile) {
        
        NSString * radioAccessTechnology = __telephonyNetworkInfoSync.currentRadioAccessTechnology;
        if ([radioAccessTechnology isEqualToString:CTRadioAccessTechnologyGPRS] ||
            [radioAccessTechnology isEqualToString:CTRadioAccessTechnologyEdge] ||
            [radioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMA1x])
            reachability = NVNetworkReachabilityMobile2G;
        else if ([radioAccessTechnology isEqualToString:CTRadioAccessTechnologyLTE])
            reachability = NVNetworkReachabilityMobile4G;
        else
            reachability = NVNetworkReachabilityMobile3G;
    }
    return reachability;
}



