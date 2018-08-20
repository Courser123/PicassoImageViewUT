//
//  NVNetworkWIFIStatus.h
//  Pods
//
//  Created by yxn on 2016/11/25.
//
//

#import <Foundation/Foundation.h>

@interface NVNetworkWIFIStatus : NSObject

+ (BOOL)isWiFiEnabled;
+ (BOOL)isWiFiConnected;
+ (NSString *)BSSID;
+ (NSString *)SSID;
+ (BOOL)isCellularOpen;
@end
