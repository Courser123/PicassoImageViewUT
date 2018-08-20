//
//  PicassoBaseFetchSignal.m
//  Pods
//
//  Created by Courser on 11/09/2017.
//
//

#import "PicassoBaseFetchSignal.h"

@implementation PicassoBaseFetchSignal

- (instancetype)init {
    if  (self = [super init]) {
        
    }
    return self;
}

- (void)dealloc {
    
}

- (void)cancel {
    self.isCanceled = YES;
}

- (NSString *)convertDateToString:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy:MM:dd HH:mm:ss"];
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    if (date) {
        return [formatter stringFromDate:date];
    }
    return nil;
}

@end
