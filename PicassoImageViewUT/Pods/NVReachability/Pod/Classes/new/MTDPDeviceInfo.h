//
//  MTDPDeviceInfo.h
//  NVReachability
//
//  Created by xiangnan.yang on 2017/12/14.
//

#import <Foundation/Foundation.h>

@interface MTDPDeviceInfo : NSObject

/**
 return nil when wifi not connected
 */
@property (atomic, copy,readonly) NSString *wifiName;
@property (atomic, copy,readonly) NSString *wifiBSSID;

+(instancetype)shardInstance;
+ (NSString *)mno;
+ (NSString *)networkType;
+ (NSString *)getIPAddress;
@end

