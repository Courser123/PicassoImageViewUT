/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║  NetworkClock.m                                                                                  ║
  ║                                                                                                  ║
  ║  Created by Gavin Eadie on Oct17/10                                                              ║
  ║  Copyright 2010 Ramsay Consulting. All rights reserved.                                          ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

#import <netinet/in.h>
#import "NetworkClock.h"
#import "ios-ntp.h"
#import <arpa/inet.h>



@interface NetworkClock (PrivateMethods)
- (void)offsetAverage;
- (NSString *)hostAddress:(struct sockaddr_in *) sockAddr;

- (void)associationTrue:(NSNotification *) notification;
- (void)associationFake:(NSNotification *) notification;

- (void)applicationBack:(NSNotification *) notification;
- (void)applicationFore:(NSNotification *) notification;
@end

@implementation NetworkClock (PrivateMethods)

- (void)offsetAverage
{
    short assocsTotal = [_timeAssociations count];
    if (assocsTotal == 0) {
        return;
    }
    
    NSArray * sortedArray = [NSArray arrayWithArray:_timeAssociations];
    short usefulCount = 0;
    
    double tempOffset = 0;
    for (NetAssociation * timeAssociation in sortedArray)
    {
        if (timeAssociation.trusty) {
            usefulCount++;
            tempOffset += timeAssociation.offset;
        }
    }
    NTPLog(@"usefulCount:%d",usefulCount);
    
    if (usefulCount > 0) {
        self.timeIntervalSinceDeviceTime = tempOffset/usefulCount;
    } else {
        self.timeIntervalSinceDeviceTime = 0.0;
    }
    
    if(usefulCount==sortedArray.count){
        [self finishUpdate];
    }
}

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
 ┃ ... obtain IP address, "xx.xx.xx.xx", from the sockaddr structure ...                            ┃
 ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
- (NSString *)hostAddress:(struct sockaddr_in *) sockAddr
{
    char addrBuf[INET_ADDRSTRLEN];
    if (inet_ntop(AF_INET, &sockAddr->sin_addr, addrBuf, sizeof(addrBuf)) == NULL) {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Cannot convert address to string."];
    }
    return [NSString stringWithCString:addrBuf encoding:NSASCIIStringEncoding];
}

#pragma mark                        N o t i f i c a t i o n • T r a p s

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
 ┃ associationTrue -- notification from a 'truechimer' association of a trusty offset               ┃
 ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
- (void)associationTrue:(NSNotification *) notification
{
    [self offsetAverage];
}

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
 ┃ associationFake -- notification from an association that became a 'falseticker'                  ┃
 ┃ .. if we already have 8 associations in play, drop this one.                                     ┃
 ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
- (void)associationFake:(NSNotification *) notification
{
    
}

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
 ┃ applicationBack -- catch the notification when the application goes into the background          ┃
 ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
- (void)applicationBack:(NSNotification *)notification
{
    
}

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
 ┃ applicationFore -- catch the notification when the application comes out of the background       ┃
 ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
- (void)applicationFore:(NSNotification *)notification
{
    
}


@end


#pragma mark -
#pragma mark                        N E T W O R K • C L O C K

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ NetworkClock is a singleton class which will provide the best estimate of the difference in time ┃
  ┃ between the device's system clock and the time returned by a collection of time servers.         ┃
  ┃                                                                                                  ┃
  ┃ The method <networkTime> returns an NSDate with the network time.                                ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/

@interface NetworkClock() {
    dispatch_queue_t readWriteQueue;
}

@end

@implementation NetworkClock
@dynamic timeIntervalSinceDeviceTime;

+ (id)sharedNetworkClock
{
    static id sharedNetworkClockInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedNetworkClockInstance = [[self alloc] init];
    });
    return sharedNetworkClockInstance;
}

static void reachabilityCallback(SCNetworkReachabilityRef __unused target, SCNetworkReachabilityFlags flags, void *info)
{
    NetworkClock *networkClock = (__bridge NetworkClock *)info;
    BOOL isReachable = ((flags & kSCNetworkReachabilityFlagsReachable) != 0);
    if (isReachable && networkClock.timeIntervalSinceDeviceTime==0) {
        [networkClock didConnectInternet];
    } else if(!isReachable){
        [networkClock didDisconnectInternet];
    }
}

- (id)init
{
    if (!(self = [super init])) return nil;
/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ Prepare a sort-descriptor to sort associations based on their dispersion, and then create an     │
  │ array of empty associations to use ...                                                           │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    readWriteQueue = dispatch_queue_create("NetworkClockReadWriteQueue", DISPATCH_QUEUE_CONCURRENT);
    _timeAssociations = [NSMutableArray arrayWithCapacity:16];
    _associationDelegateQueue = dispatch_queue_create("org.ios-ntp.delegates", 0);
    
/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ .. and fill that array with the time hosts obtained from "ntp.hosts" ..                          │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    [self createAssociations];                  
/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ prepare to catch our application entering and leaving the background ..                          │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(associationTrue:) name:@"assoc-good" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(associationFake:) name:@"assoc-fail" object:nil];
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationBack:)
												 name:UIApplicationDidEnterBackgroundNotification
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationFore:)
												 name:UIApplicationWillEnterForegroundNotification
											   object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(systemTimeDidChanged:)
                                                 name:UIApplicationSignificantTimeChangeNotification
                                               object:nil];
    
    
    _networkReachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, [@"https://www.meituan.com" UTF8String]);
    SCNetworkReachabilityContext context = {0, (__bridge void *)self, NULL, NULL, NULL};
    SCNetworkReachabilitySetCallback(_networkReachability, reachabilityCallback, &context);
    SCNetworkReachabilityScheduleWithRunLoop(_networkReachability, CFRunLoopGetMain(), (CFStringRef)NSRunLoopCommonModes);
    [self enableAssociations];
    return self;
}

- (void)dealloc
{
    if (_networkReachability != NULL) {
        SCNetworkReachabilityUnscheduleFromRunLoop(_networkReachability, CFRunLoopGetMain(), (CFStringRef)NSRunLoopCommonModes);
        CFRelease(_networkReachability);
        _networkReachability = NULL;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(finishUpdate) object:nil];
    [self finishAssociations];
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000 // 6.0sdk之前
    dispatch_release(_associationDelegateQueue);
#endif
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSTimeInterval)timeIntervalSinceDeviceTime
{
    return _timeIntervalSinceDeviceTime;
}

- (void)setTimeIntervalSinceDeviceTime:(NSTimeInterval)newTime;
{
    _timeIntervalSinceDeviceTime = newTime;
    NTPLog(@"timeIntervalChanged:%f",_timeIntervalSinceDeviceTime);
}

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ be called very frequently, we recompute the average offset every 30 seconds.                     ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/


- (void)finishUpdate
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:_cmd object:nil];
    [self finishAssociations];
    [[NSNotificationCenter defaultCenter] postNotificationName:networkDateDidChanged object:self];

}

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ Return the device clock time adjusted for the offset to network-derived UTC.  Since this could   ┃
  ┃ be called very frequently, we recompute the average offset every 30 seconds.                     ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
- (NSDate *)networkTime
{
#ifndef IOS_NTP_TEST
    if(fabs(self.timeIntervalSinceDeviceTime) < 2.0){//误差小于两秒,使用系统时间
        return [NSDate date];
    }
#endif
    return [[NSDate date] dateByAddingTimeInterval:-self.timeIntervalSinceDeviceTime];
}

#pragma mark                        I n t e r n a l  •  M e t h o d s

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ Read the "ntp.hosts" file from the resources and derive all the IP addresses they refer to,      ┃
  ┃ remove any duplicates and create an 'association' for each one (individual host clients).        ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
- (void)createAssociations
{
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"ntp" ofType:@"hosts"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return;
    }
    NSString * fileData = [[NSString alloc] initWithData:[[NSFileManager defaultManager]
                                                           contentsAtPath:filePath]
                                                 encoding:NSUTF8StringEncoding];
    NSArray *  ntpDomains = [fileData componentsSeparatedByCharactersInSet:
                                                                [NSCharacterSet newlineCharacterSet]];

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │  for each NTP service domain name in the 'ntp.hosts' file : "0.pool.ntp.org" etc ...             │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    for (NSString * ntpDomainName in ntpDomains)
    {
        if ([ntpDomainName length] == 0 ||
            [ntpDomainName characterAtIndex:0] == ' ' || [ntpDomainName characterAtIndex:0] == '#') {
            continue;
        }
/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │  ... start an 'association' (network clock object) for each address.                             │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
        NetAssociation* timeAssociation = [[NetAssociation alloc] initWithServerName:ntpDomainName queue:_associationDelegateQueue];
        [_timeAssociations addObject:timeAssociation];
    }
    // Enable associations.
}

- (void)enableAssociations
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(finishUpdate) object:nil];
    dispatch_sync(readWriteQueue, ^{
        [_timeAssociations makeObjectsPerformSelector:@selector(enable)];
    });
    [self performSelector:@selector(finishUpdate) withObject:nil afterDelay:10.0];//10秒失败了立即结束
}


/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ Stop all the individual ntp clients ..                                                           ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
- (void)finishAssociations
{
    dispatch_sync(readWriteQueue, ^{
        [_timeAssociations makeObjectsPerformSelector:@selector(finish)];
    });
}

- (void)didConnectInternet
{
    if(self.timeIntervalSinceDeviceTime==0){
        [self enableAssociations];
    }
}

- (void)didDisconnectInternet
{
    [self finishAssociations];
}

- (void)systemTimeDidChanged:(NSNotification *)sender
{
    [self finishAssociations];
    dispatch_barrier_sync(readWriteQueue, ^{
        [_timeAssociations removeAllObjects];
        [self createAssociations];
    });
    self.timeIntervalSinceDeviceTime = 0;
    [self enableAssociations];
}

@end
