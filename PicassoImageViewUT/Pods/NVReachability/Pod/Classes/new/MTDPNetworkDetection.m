//
//  MTDPNetworkDetection.m
//  NVReachability
//
//  Created by xiangnan.yang on 2017/12/19.
//

#import "MTDPNetworkDetection.h"
#import "MTDPDeviceInfo.h"
#import "NVNetworkReachability.h"
#import "NVNetworkWIFIStatus.h"
#import <CoreTelephony/CoreTelephonyDefines.h>
#import <CoreTelephony/CTCellularData.h>
#import "MTDPDNSResolution.h"
#import "MTDPPingReachability.h"

@interface MTDPNetworkDetection ()

@property (nonatomic, copy)NSString *report;
@property (nonatomic, assign)BOOL isDetecting;
@property (nonatomic, strong)MTDPPingReachability *pingReachAbility;

@end

@implementation MTDPNetworkDetection

- (instancetype)init{
    if (self = [super init]) {
        _report = @"";
    }
    return self;
}

#pragma mark Interface

- (void)cancel{
    self.isDetecting = NO;
    if ([self.pingReachAbility isPinging]) {
        [self.pingReachAbility cancel];
    }    
}

- (void)finish{
    if (!self.isDetecting) {
        return;
    }
    self.isDetecting = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.callback) {
            self.callback(self.report);
        }
    });
}

- (void)start{
    NSAssert(self.callback != NULL, @"callback can't be NULL");
    self.isDetecting = YES;
    dispatch_queue_t serialCheckQueue = dispatch_queue_create("serialNetworkCheckQueue", NULL);
    dispatch_async(serialCheckQueue, ^{
        self.report = @"";
        [self deviceInfo];
        [self checkReachability];
        if (!self.isDetecting) {
            [self finish];
            return ;
        }
        [self checkLocalDNS];
        if (self.dnsDamain.count > 0) {
            [self checkRemoteDNS];
        }
        if (self.pingDomain.count > 0) {
            [self checkPing];
        }
    });
}

- (void)deviceInfo{
    [self addReport:[NSString stringWithFormat:@"运营商:%@    \n",[MTDPDeviceInfo mno]]];
}

#pragma mark Detect

- (void)checkReachability{
    if (!self.isDetecting) {
        return;
    }
    [self addReport:@"Checking Reachability:"];
    NVNetworkReachability reachability = NVGetNetworkReachability();
    if (reachability == NVNetworkReachabilityNone) {
        if (([NVNetworkWIFIStatus isCellularOpen] ||
             [NVNetworkWIFIStatus isWiFiConnected])&&
            [MTDPNetworkDetection checkAuthority] == kCTCellularDataRestricted) {
            [self addReport:@"Limits of Network authority is Restricted\n"];
        }else{
            [self addReport:@"There is no network connection\n"];
        }
        [self finish];
    }else{
        [self addReport:[NSString stringWithFormat:@"current network type %@\n",[MTDPDeviceInfo networkType]]];
    }
}

#pragma mark -----  local dns

- (void)checkLocalDNS{
    if (!self.isDetecting) {
        return;
    }
    [self addReport:@"checking Local DNS:\n"];
    [self addReport:[MTDPDeviceInfo getIPAddress]];
}

- (void)checkRemoteDNS{
    if (!self.isDetecting) {
        return;
    }
    [self addReport:@"\nchecking Remote DNS:\n"];
    if (self.dnsDamain.count == 0) {
        return;
    }
    for (NSString *domain in self.dnsDamain) {
        [self addReport:[NSString stringWithFormat:@"%@:\n",domain]];
        NSArray *dnsArr = [MTDPDNSResolution syncResoluteWithHost:domain];
        for (NSString *ip in dnsArr) {
            [self addReport:[NSString stringWithFormat:@"%@\n",ip]];
        }
    }
}

- (void)checkPing{
    if (self.pingDomain.count == 0 || !self.isDetecting) {
        return;
    }
    [self addReport:@"checking Ping:\n"];
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    __weak typeof(self) __weakSelf = self;
    self.pingReachAbility.callBack = ^(NSString *message){
        __strong typeof(__weakSelf) __strongSelf = __weakSelf;
        if (__strongSelf.isDetecting) {
            [__strongSelf addReport:[NSString stringWithFormat:@"%@\n",message]];
        }
        if (!__strongSelf.pingReachAbility.isPinging) {
            dispatch_group_leave(group);
        }
    };
    self.pingReachAbility.hostArray = self.pingDomain;
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [self finish];
    });
    [self.pingReachAbility start];
}

//状态获取超时或者版本低于9。0 默认有权限。
+ (CTCellularDataRestrictedState)checkAuthority{//不在主线程执行
    NSAssert([[NSThread currentThread] isMainThread], @"this function should not be called on main thread");
    __block CTCellularDataRestrictedState restrictedState = kCTCellularDataNotRestricted;
    if ([[UIDevice currentDevice].systemVersion compare:@"9.0" options:NSNumericSearch] != NSOrderedAscending) {
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wpartial-availability"
        __block CTCellularData *cellularData = [[CTCellularData alloc] init];
        cellularData.cellularDataRestrictionDidUpdateNotifier =  ^(CTCellularDataRestrictedState state){
            restrictedState = state;
            cellularData = nil;
            dispatch_semaphore_signal(sema);
        };
        dispatch_semaphore_wait(sema, 2);
        return restrictedState;
#pragma clang diagnostic pop
    }else{
        return restrictedState;
    }
}

- (void)addReport:(NSString *)report{
    if (report.length == 0) {
        return;
    }
    self.report = [self.report stringByAppendingString:report];
}

- (MTDPPingReachability *)pingReachAbility{
    if (!_pingReachAbility) {
        _pingReachAbility = [MTDPPingReachability new];
    }
    return _pingReachAbility;
}

@end
