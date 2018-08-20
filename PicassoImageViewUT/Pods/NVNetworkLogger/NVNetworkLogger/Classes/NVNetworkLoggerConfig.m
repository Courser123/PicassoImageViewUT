//
//  NVNetworkLogger.m
//  Pods
//
//  Created by yxn on 2016/9/29.
//
//

#import "NVNetworkLoggerConfig.h"
#import "ios-ntp.h"

@implementation NVNetworkLoggerConfig

+ (instancetype)sharedInstance{
    static NVNetworkLoggerConfig * instance = nil;
    static  dispatch_once_t pred;
    dispatch_once(&pred, ^{
        instance = [NVNetworkLoggerConfig new];
    });
    return instance;
}

- (void)setNetworkBlock:(nonnull NetworkBlock)block{
}

- (void)setIsOpenNetworkLog:(nonnull isOpenNetworkLogBlock)block{
}

- (void)setUnionIdBlock:(LogUnionIDBlock)block {
}

#pragma mark  -------- getter

NSString *NNLogCurrentTime(void){
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd,HH:mm:ss"];
    return [dateFormatter stringFromDate:[NSDate threadsafeNetworkDate]];
}

BOOL __isOpenNetworkLog(void){
    return NO;
}
//
//void __writeNetworkLog(NSString *log){
//}

- (void)uploadLogWithDate:(nonnull NSString *)date networkType:(nonnull NSString *)type key:(nonnull NSString *)key{
}


@end
