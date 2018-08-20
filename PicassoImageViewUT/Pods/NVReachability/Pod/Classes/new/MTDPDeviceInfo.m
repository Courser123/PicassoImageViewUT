//
//  MTDPDeviceInfo.m
//  NVReachability
//
//  Created by xiangnan.yang on 2017/12/14.
//

#import "MTDPDeviceInfo.h"
#include <sys/sysctl.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import "NVNetworkReachability.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import "NVReachability.h"

@interface MTDPDeviceInfo ()

@property (copy,atomic) NSString *wifiName;
@property (copy,atomic) NSString *wifiBSSID;

@end

@implementation MTDPDeviceInfo

//1、运营商信息

+(instancetype)shardInstance{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init{
    if(self = [super init]){
        [self updateWifiName];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateWifiName) name:NVReachabilityChanged object:nil];
    }
    return self;
}

- (void)updateWifiName{
    NSString *wifiSSID = nil;
    NSString *wifiBSSID = nil;
    CFArrayRef array = CNCopySupportedInterfaces();
    if (array != nil && CFArrayGetCount(array)) {
        CFDictionaryRef cfdict = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(array, 0));
        if (cfdict && CFDictionaryContainsKey(cfdict, kCNNetworkInfoKeySSID)) {
            wifiSSID =(__bridge NSString *)CFDictionaryGetValue(cfdict, kCNNetworkInfoKeySSID);
            wifiBSSID= [[self class] fixedMacAddress:(__bridge NSString *)CFDictionaryGetValue(cfdict, kCNNetworkInfoKeyBSSID)];
        }
    }
    self.wifiName = wifiSSID;
    self.wifiBSSID = wifiBSSID;
}

+ (NSString *)fixedMacAddress:(NSString *)originalString
{
    NSArray *stringComponents = [originalString componentsSeparatedByString:@":"];
    NSMutableArray *mutableComponents = [stringComponents mutableCopy];
    NSInteger index = 0;
    for (NSString *component in stringComponents) {
        if ([component length] == 1) {
            mutableComponents[index] = [@"0" stringByAppendingString:component];
        }
        index++;
    }
    return [mutableComponents componentsJoinedByString:@":"];
}

+ (NSString *)mno{
    CTTelephonyNetworkInfo *info = [self telephonyNetworkInfo];
    CTCarrier *carrier = [info subscriberCellularProvider];
    //当前手机所属运营商名称
    NSString *mobile;
    //先判断有没有SIM卡，如果没有则不获取本机运营商
    if (!carrier.isoCountryCode) {
        mobile = @"no sim card";
    }else{
        mobile = [carrier carrierName] ? :@"";
    }
    return mobile;
}

//2、网络环境
+(NSString *)networkType{
    NVNetworkReachability type = NVGetAccurateNetworkReachability();
    switch (type) {
        case NVNetworkReachabilityNone:
            return @"无网络";
        case NVNetworkReachabilityWifi:
            return @"WIFI";
        case NVNetworkReachabilityMobile2G:
            return @"2G";
        case NVNetworkReachabilityMobile3G:
            return @"3G";
        case NVNetworkReachabilityMobile4G:
            return @"4G";
        default:
            return @"";
    }
}

//3、本机ip
+ (NSString *)getIPAddress
{
    NSString *address = @"unknown";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            // Check if interface is en0 which is the wifi connection on the iPhone
            if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"] || [[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"pdp_ip0"])
            {
                // IPv4
                if (temp_addr->ifa_addr->sa_family == AF_INET) {
                    address = [self formatIPV4Address:((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr];
                }
                
                // IPv6
                else if (temp_addr->ifa_addr->sa_family == AF_INET6) {
                    address = [self formatIPV6Address:((struct sockaddr_in6 *)temp_addr->ifa_addr)->sin6_addr];
                    if (address && ![address isEqualToString:@""] && ![address.uppercaseString hasPrefix:@"FE80"]) break;
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    // 以FE80开始的地址是单播地址
    if (address && ![address isEqualToString:@""] && ![address.uppercaseString hasPrefix:@"FE80"]) {
        return address;
    } else {
        return @"";
    }
}


+ (NSString *)formatIPV6Address:(struct in6_addr)ipv6Addr
{
    NSString *address = nil;
    
    char dstStr[INET6_ADDRSTRLEN];
    char srcStr[INET6_ADDRSTRLEN];
    memcpy(srcStr, &ipv6Addr, sizeof(struct in6_addr));
    if(inet_ntop(AF_INET6, srcStr, dstStr, INET6_ADDRSTRLEN) != NULL){
        address = [NSString stringWithUTF8String:dstStr];
    }
    return address;
}


+ (NSString *)formatIPV4Address:(struct in_addr)ipv4Addr
{
    NSString *address = nil;
    char dstStr[INET_ADDRSTRLEN];
    char srcStr[INET_ADDRSTRLEN];
    memcpy(srcStr, &ipv4Addr, sizeof(struct in_addr));
    if(inet_ntop(AF_INET, srcStr, dstStr, INET_ADDRSTRLEN) != NULL){
        address = [NSString stringWithUTF8String:dstStr];
    }
    return address;
}

+ (CTTelephonyNetworkInfo *)telephonyNetworkInfo{
    static CTTelephonyNetworkInfo *telephonyInfo = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        telephonyInfo = [[CTTelephonyNetworkInfo alloc] init];
    });
    return telephonyInfo;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
