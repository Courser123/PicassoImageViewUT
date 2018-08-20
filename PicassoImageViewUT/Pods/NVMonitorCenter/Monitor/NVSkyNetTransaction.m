//
//  NVSkyNetTransaction.m
//  NVMonitorCenter
//
//  Created by David on 2018/3/7.
//

#import "NVSkyNetTransaction.h"
#import "NVMetricsMonitor.h"

@interface NVSkyNetTransaction()
@property (nonatomic, assign) NVTransactionType transactionType;
@property (nonatomic, assign) NSTimeInterval startTime;
@property (nonatomic, strong) NSException * exception;
@property (nonatomic, copy) NSString * key;
@end

@implementation NVSkyNetTransaction

- (instancetype _Nonnull)initTransactionWithKey:(nonnull NSString *)key {
    if (self = [super init]) {
        _key = key;
    }
    return self;
}

- (void)start {
    self.startTime = [[NSDate date] timeIntervalSince1970];
}

- (void)end {
    NSTimeInterval duration = self.startTime - [[NSDate date] timeIntervalSince1970];
    NVMetricsMonitor * metricsMonitor = [NVMetricsMonitor new];
    [metricsMonitor addValue:@(duration) forKey:self.key];
    [metricsMonitor send];
}

@end
