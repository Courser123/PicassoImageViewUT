//
//  NVNetworkWIFIStatus.m
//  Pods
//
//  Created by yxn on 2016/11/25.
//
//

#import "NVNetworkWIFIStatus.h"
#import <ifaddrs.h>
#import <net/if.h>
#import <SystemConfiguration/CaptiveNetwork.h>



@implementation NVNetworkWIFIStatus

+ (BOOL) isWiFiEnabled {
    NSCountedSet * cset = [NSCountedSet new];
    struct ifaddrs *interfaces;
    if( ! getifaddrs(&interfaces) ) {
        for( struct ifaddrs *interface = interfaces; interface; interface = interface->ifa_next) {
            if ( (interface->ifa_flags & IFF_UP) == IFF_UP ) {
                [cset addObject:[NSString stringWithUTF8String:interface->ifa_name]];
            }
        }
    }
    freeifaddrs(interfaces);
    return [cset countForObject:@"awdl0"] > 1 ? YES : NO;
}

+ (NSDictionary *) wifiDetails {
    CFArrayRef interfaces = CNCopySupportedInterfaces();
    NSDictionary *result = nil;

    if (interfaces && CFArrayGetCount(interfaces)) {
        CFStringRef wifiString = CFArrayGetValueAtIndex(interfaces, 0);
        CFDictionaryRef wifiDictionary = CNCopyCurrentNetworkInfo(wifiString);
        if (wifiDictionary) {
            result = (__bridge_transfer id)wifiDictionary;
        }
    }
    
    if (interfaces) {
        CFRelease(interfaces);
    }
    
    if (result) {
        return result;
    }
    return nil;
}

//关闭网络权限也能正确判断
+ (BOOL) isWiFiConnected {
    return [NVNetworkWIFIStatus wifiDetails] == nil ? NO : YES;
}

+ (NSString *) BSSID {
    return [NVNetworkWIFIStatus wifiDetails][@"BSSID"];
}

+ (NSString *) SSID {
    return [NVNetworkWIFIStatus wifiDetails][@"SSID"];
}

+ (BOOL)isCellularOpen{
    struct ifaddrs* interfaces = NULL;
    struct ifaddrs* temp_addr = NULL;
    // retrieve the current interfaces - returns 0 on success
    NSInteger success = getifaddrs(&interfaces);
    if (success == 0)
    {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL)
        {
            NSString *name = [NSString stringWithUTF8String:temp_addr->ifa_name];
            if ([name isEqualToString:@"pdp_ip0"] && temp_addr->ifa_addr->sa_family ==2 ) {
                return YES;
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return NO;
}

//+ (BOOL) isCellEnabled {
//
//    NSCountedSet * cset = [NSCountedSet new];
//    
//    struct ifaddrs *interfaces;
//    
//    if( ! getifaddrs(&interfaces) ) {
//        for( struct ifaddrs *interface = interfaces; interface; interface = interface->ifa_next) {
//            if ( (interface->ifa_flags & IFF_UP) == IFF_UP ) {
//                [cset addObject:[NSString stringWithUTF8String:interface->ifa_name]];
//            }
//        }
//    }
//    freeifaddrs(interfaces);
//    
//    return [cset countForObject:@"awdl0"] > 1 ? YES : NO;
//}

@end
