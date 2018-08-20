//
//  NVSkyNetCat.h
//  NVMonitorCenter
//
//  Created by David on 2018/3/7.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SkyNetLogStatus){
    SkyNetLogStatusSuccess = 1,
    SkyNetLogStatusFail = 2,
};

@interface NVSkyNetCat : NSObject
//记录一个指标key的事件发生次数 包含业务tag
+ (void)logEventWithKey:(nonnull NSString *)key tag:(nonnull NSString *)tag;
@end
