//
//  NVSkyNetCat.m
//  NVMonitorCenter
//
//  Created by David on 2018/3/7.
//

#import "NVSkyNetCat.h"
#import "NVMetricsMonitor.h"

@implementation NVSkyNetCat

//记录一个key标识的事件发生次数
+ (void)logEventWithKey:(nonnull NSString *)key tag:(nonnull NSString *)tag {
    NVMetricsMonitor * monitor = [NVMetricsMonitor new];
    [monitor addTag:tag forKey:key];
    [monitor send];
}

@end
