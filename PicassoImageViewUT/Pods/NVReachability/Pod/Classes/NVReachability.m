//
//  NVReachability.m
//  NVReachability
//
//  Created by ZhouHui on 16/1/8.
//  Copyright © 2016年 dianping. All rights reserved.
//
#import "NVReachability.h"

#import <sys/socket.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>

#import <CoreFoundation/CoreFoundation.h>
#import "NVReachability.h"

#import "CoreTelephony/CTTelephonyNetworkInfo.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import "NVLinker.h"

#define kShouldPrintReachabilityFlags 0

#ifndef kSCNetworkReachabilityFlagsConnectionOnDemand
#define kSCNetworkReachabilityFlagsConnectionOnDemand (1<<5)
#endif

#ifndef kSCNetworkReachabilityFlagsConnectionOnTraffic
#define kSCNetworkReachabilityFlagsConnectionOnTraffic (1<<3)
#endif

static void PrintReachabilityFlags(SCNetworkReachabilityFlags    flags, const char* comment)
{
#if kShouldPrintReachabilityFlags
    
    NSLog(@"Reachability Flag Status: %c%c %c%c%c%c%c%c%c %s\n",
          (flags & kSCNetworkReachabilityFlagsIsWWAN)				  ? 'W' : '-',
          (flags & kSCNetworkReachabilityFlagsReachable)            ? 'R' : '-',
          
          (flags & kSCNetworkReachabilityFlagsTransientConnection)  ? 't' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionRequired)   ? 'c' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic)  ? 'C' : '-',
          (flags & kSCNetworkReachabilityFlagsInterventionRequired) ? 'i' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionOnDemand)   ? 'D' : '-',
          (flags & kSCNetworkReachabilityFlagsIsLocalAddress)       ? 'l' : '-',
          (flags & kSCNetworkReachabilityFlagsIsDirect)             ? 'd' : '-',
          comment
          );
#endif
}
@interface NVReachability ()

@property (nonatomic, strong) NSObject *mobileNetworkObserver;
@property (nonatomic, assign) BOOL useOld;
@end

@implementation NVReachability {
    NVNetworkReachability _accNetworkStatus;
    NetworkStatus _networkStatus;
}
static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info)
{
#pragma unused (target, flags)
    NSCAssert(info != NULL, @"info was NULL in ReachabilityCallback");
    NSCAssert([(__bridge id) info  isKindOfClass: [NVReachability class]], @"info was wrong class in ReachabilityCallback");
    
    //We're on the main RunLoop, so an NSAutoreleasePool is not necessary, but is added defensively
    // in case someon uses the Reachablity object in a different thread.
    @autoreleasepool {
        NVReachability* noteObject = (__bridge id) info;
        [noteObject updateNetworkStatus];
        // Post a notification to notify the client that the network reachability changed.
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName: NVReachabilityChanged object: noteObject];
        });
    }
}

- (BOOL) startNotifer
{
    if (!self.mobileNetworkObserver) {
        [self startMobileNetworkStatusNotifer];
        BOOL retVal = NO;
        SCNetworkReachabilityContext    context = {0, (__bridge void *)(self), NULL, NULL, NULL};
        if(SCNetworkReachabilitySetCallback(reachabilityRef, ReachabilityCallback, &context))
        {
            if(SCNetworkReachabilityScheduleWithRunLoop(reachabilityRef, CFRunLoopGetMain(), kCFRunLoopCommonModes))
            {
                retVal = YES;
            }
        }
        return retVal;
    }
    return YES;
}

- (void) stopNotifer
{
    [self stopMobileNetworkStatusNotifer];
    if(reachabilityRef!= NULL)
    {
        SCNetworkReachabilityUnscheduleFromRunLoop(reachabilityRef, CFRunLoopGetMain(), kCFRunLoopCommonModes);
    }
}


- (void) startMobileNetworkStatusNotifer
{
    [self stopMobileNetworkStatusNotifer];
    __weak NVReachability *weakSelf = self;
    self.mobileNetworkObserver = [[NSNotificationCenter defaultCenter] addObserverForName:CTRadioAccessTechnologyDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        NVReachability *strongSelf = weakSelf;
        if (strongSelf && [strongSelf isKindOfClass:[NVReachability class]]) {
            [strongSelf updateNetworkStatus];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:NVReachabilityMobileNetworStatusDidChange object:strongSelf];
            });
        }
    }];
}

- (void) stopMobileNetworkStatusNotifer
{
    if (self.mobileNetworkObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:self.mobileNetworkObserver];
        self.mobileNetworkObserver = nil;
    }
}

- (id)init {
    if (self = [super init]) {
        [self registerNotification];
        [self updateUseOld];
    }
    return self;
}

- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUseOld) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)updateUseOld {
    id<LubanLinkerProtocol> luban = lubanLinker();
    if (luban) {
        NSDictionary *dic = [luban jsonDicDataForCache:@"simpleconfig" parameters:nil];
        NSNumber *useOldReachability = [dic valueForKey:@"useOldReachability"];
        if ([useOldReachability isKindOfClass:[NSNumber class]] || [useOldReachability isKindOfClass:[NSString class]]) {
            _useOld = [useOldReachability boolValue];
        }
    }
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self stopNotifer];
    if(reachabilityRef!= NULL)
    {
        CFRelease(reachabilityRef);
    }
}

+ (NVReachability*) reachabilityWithHostName: (NSString*) hostName;
{
    NVReachability* retVal = NULL;
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, [hostName UTF8String]);
    if(reachability!= NULL)
    {
        retVal= [[self alloc] init];
        if(retVal!= NULL)
        {
            retVal->reachabilityRef = reachability;
            retVal->localWiFiRef = NO;
        }
    }
    return retVal;
}

+ (NVReachability*) reachabilityWithAddress: (const struct sockaddr_in*) hostAddress
{
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)hostAddress);
    NVReachability* retVal = NULL;
    if(reachability!= NULL)
    {
        retVal= [[self alloc] init];
        if(retVal!= NULL)
        {
            retVal->reachabilityRef = reachability;
            retVal->localWiFiRef = NO;
        }
    }
    return retVal;
}

+ (NVReachability*) reachabilityForInternetConnection
{
    static NVReachability *theOne = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        struct sockaddr_in zeroAddress;
        bzero(&zeroAddress, sizeof(zeroAddress));
        zeroAddress.sin_len = sizeof(zeroAddress);
        zeroAddress.sin_family = AF_INET;
        theOne = [self reachabilityWithAddress: &zeroAddress];
        [theOne updateNetworkStatus];
        
        [theOne startNotifer];
    });
    return theOne;
}

+ (NVReachability*) reachabilityForLocalWiFi
{
    struct sockaddr_in localWifiAddress;
    bzero(&localWifiAddress, sizeof(localWifiAddress));
    localWifiAddress.sin_len = sizeof(localWifiAddress);
    localWifiAddress.sin_family = AF_INET;
    // IN_LINKLOCALNETNUM is defined in <netinet/in.h> as 169.254.0.0
    localWifiAddress.sin_addr.s_addr = htonl(IN_LINKLOCALNETNUM);
    NVReachability* retVal = [self reachabilityWithAddress: &localWifiAddress];
    if(retVal!= NULL)
    {
        retVal->localWiFiRef = YES;
    }
    return retVal;
}

#pragma mark Network Flag Handling

- (NetworkStatus) localWiFiStatusForFlags: (SCNetworkReachabilityFlags) flags
{
    PrintReachabilityFlags(flags, "localWiFiStatusForFlags");
    
    BOOL retVal = NotReachable;
    if((flags & kSCNetworkReachabilityFlagsReachable) && (flags & kSCNetworkReachabilityFlagsIsDirect))
    {
        retVal = ReachableViaWiFi;
    }
    return retVal;
}

- (NetworkStatus) networkStatusForFlags: (SCNetworkReachabilityFlags) flags
{
    PrintReachabilityFlags(flags, "networkStatusForFlags");
    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
    {
        // if target host is not reachable
        return NotReachable;
    }
    
    NetworkStatus retVal = NotReachable;
    
    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
    {
        // if target host is reachable and no connection is required
        //  then we'll assume (for now) that your on Wi-Fi
        retVal = ReachableViaWiFi;
    }
    
    
    if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
         (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
    {
        // ... and the connection is on-demand (or on-traffic) if the
        //     calling application is using the CFSocketStream or higher APIs
        
        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
        {
            // ... and no [user] intervention is needed
            retVal = ReachableViaWiFi;
        }
    }
    
    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
    {
        // ... but WWAN connections are OK if the calling application
        //     is using the CFNetwork (CFSocketStream?) APIs.
        retVal = ReachableViaWWAN;
    }
    return retVal;
}

- (BOOL) connectionRequired
{
    NSAssert(reachabilityRef != NULL, @"connectionRequired called with NULL reachabilityRef");
    SCNetworkReachabilityFlags flags;
    if (SCNetworkReachabilityGetFlags(reachabilityRef, &flags))
    {
        return (flags & kSCNetworkReachabilityFlagsConnectionRequired);
    }
    return NO;
}


- (void)updateNetworkStatus {
    // CTTelephonyNetworkInfo不能多次创建
    static CTTelephonyNetworkInfo *gTelephonyNetworkInfo;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gTelephonyNetworkInfo = [CTTelephonyNetworkInfo new];
    });
    
    NSAssert(reachabilityRef != NULL, @"currentNetworkStatus called with NULL reachabilityRef");
    if (reachabilityRef == NULL) {
        return;
    }
    NetworkStatus retVal = NotReachable;
    SCNetworkReachabilityFlags flags;
    
#if TARGET_IPHONE_SIMULATOR
    if (SCNetworkReachabilityGetFlags(__simulatorReachability, &flags))
#else
    if (SCNetworkReachabilityGetFlags(reachabilityRef, &flags))
#endif
    {
        if(localWiFiRef)
        {
            retVal = [self localWiFiStatusForFlags: flags];
        }
        else
        {
            retVal = [self networkStatusForFlags: flags];
        }
    }
    
    _networkStatus = retVal;
    
    
    NVNetworkReachability accNetworkStatus = NVNetworkReachabilityNone;
    if (retVal == ReachableViaWWAN) {
        NSString * radioAccessTechnology = gTelephonyNetworkInfo.currentRadioAccessTechnology;
        if ([radioAccessTechnology isEqualToString:CTRadioAccessTechnologyGPRS] ||
            [radioAccessTechnology isEqualToString:CTRadioAccessTechnologyEdge] ||
            [radioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMA1x])
            accNetworkStatus = NVNetworkReachabilityMobile2G;
        else if ([radioAccessTechnology isEqualToString:CTRadioAccessTechnologyLTE])
            accNetworkStatus = NVNetworkReachabilityMobile4G;
        else
            accNetworkStatus = NVNetworkReachabilityMobile3G;
    } else if (retVal == ReachableViaWiFi) {
        accNetworkStatus = NVNetworkReachabilityWifi;
    } else {
        accNetworkStatus = NVNetworkReachabilityNone;
    }
    
    _accNetworkStatus = accNetworkStatus;
}

static SCNetworkReachabilityRef __simulatorReachability = nil;

- (void)initSimulatorReachability {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        struct sockaddr_in zeroAddress;
        bzero(&zeroAddress, sizeof(zeroAddress));
        zeroAddress.sin_len = sizeof(zeroAddress);
        zeroAddress.sin_family = AF_INET;
        __simulatorReachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)&zeroAddress);
    });
}

- (NetworkStatus) currentReachabilityStatus
{
    if (_useOld) {
        NVNetworkReachability reachability = NVSyncGetNetworkReachability();
        NetworkStatus nstatus = NotReachable;
        if (reachability == NVNetworkReachabilityMobile) {
            nstatus = ReachableViaWWAN;
        }else if (reachability == NVNetworkReachabilityWifi) {
            nstatus = ReachableViaWiFi;
        }
        return nstatus;
    }
    
    //模拟器需要实时获取
#if TARGET_IPHONE_SIMULATOR
    [self initSimulatorReachability];
    [self updateNetworkStatus];
#endif

    return _networkStatus;
}

- (NVNetworkReachability)currentAccurateReachabilityStatus {
    if (_useOld) {
        return NVSyncGetAccurateNetworkReachability();
    }
    //模拟器需要实时获取
#if TARGET_IPHONE_SIMULATOR
    [self initSimulatorReachability];
    [self updateNetworkStatus];
#endif
    return _accNetworkStatus;
}
@end
