

#import "NSDate+NetworkClock.h"
#import "NetworkClock.h"

#import "ios-ntp.h"

NSString *const networkDateDidChanged = @"networkDateDidChanged";

@implementation NSDate (NetworkClock)

- (NSTimeInterval)timeIntervalSinceNetworkDate
{
    return [self timeIntervalSinceDate:[NSDate networkDate]];
}

+ (NSTimeInterval)timeIntervalSinceNetworkDate
{
    return [[self date] timeIntervalSinceNetworkDate];
}

+ (NSDate *)networkDate
{
    return [[NetworkClock sharedNetworkClock] networkTime];
}

+ (NSDate *)threadsafeNetworkDate
{
    NetworkClock *sharedClock = [NetworkClock sharedNetworkClock];
    @synchronized(sharedClock) {
        return [sharedClock networkTime];
    }
}


@end