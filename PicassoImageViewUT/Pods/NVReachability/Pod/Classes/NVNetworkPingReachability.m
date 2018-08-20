//
//  NVNetworkPingReachability.m
//  Pods
//
//  Created by yxn on 2016/11/18.
//
//

#import "NVNetworkPingReachability.h"
#import "NVNetworkPing.h"

#define MAXPingTimes 3

@interface NVNetworkPingReachability()<NVNetworkPingDelegate>

@property(nonatomic, strong)NVNetworkPing *pinger;
@property(nonatomic, copy)NSString *hostName;
@property(nonatomic, assign)BOOL isStarted;
@property(nonatomic, assign)BOOL isTimeOut;
@property(nonatomic, assign)NSInteger rePingTimes;
@property(nonatomic, assign)NSInteger sequenceNumber;
@property(nonatomic, strong)NSMutableArray *pingItemsArr;
@property(nonatomic, strong)void(^callback)(NVNetworkPingItem *item, NSArray *pingItems);

@end

@implementation NVNetworkPingReachability

#pragma mark  --------  initail

+ (NVNetworkPingReachability *)startPingHost:(NSString *)hostName callback:(void(^)(NVNetworkPingItem *pingItem, NSArray *pingItems))handler{
    NVNetworkPingReachability *pingReachalibity = [[NVNetworkPingReachability alloc] initWithHostName:hostName];
    pingReachalibity.callback = handler;
    return pingReachalibity;
    
}

- (instancetype)initWithHostName:(NSString *)hostName{
    if (self = [super init]) {
        _hostName = hostName;
        _timeout = 500;//默认500ms
        _maxPingTimes = MAXPingTimes;
        _pinger = [[NVNetworkPing alloc] initWithHostName:hostName];
        _pinger.addressStyle = NVNetworkPingAddressStyleAny;
        _pinger.delegate = self;
        _pingItemsArr = [NSMutableArray new];
    }
    return self;
}

#pragma mark  --------  functions

- (void)startPing {
    self.rePingTimes = 0;
    self.isStarted = YES;
    [self.pingItemsArr removeAllObjects];
    [self.pinger start];

    [self performSelector:@selector(timeoutActionFired) withObject:nil afterDelay:self.timeout / 1000.0];
}

- (void)reping {
    if (self.isStarted) {
        [self.pinger stop];
        [self.pinger start];
        [self performSelector:@selector(timeoutActionFired) withObject:nil afterDelay:self.timeout / 1000.0];
    }
}

- (void)timeoutActionFired {
    NVNetworkPingItem *pingItem = [[NVNetworkPingItem alloc] init];
    pingItem.ICMPSequence = _sequenceNumber;
    pingItem.originalAddress = self.hostName;
    pingItem.status = NVNetworkPingStatusDidTimeout;
    [self handlePingItem:pingItem];
}

- (void)handlePingItem:(NVNetworkPingItem *)pingItem {
    if (!self.isStarted) {
        return;
    }
    if (pingItem.status == NVNetworkPingStatusFinished) {
        [self reset];
        return;
    }
    
    if ((self.rePingTimes < self.maxPingTimes) && pingItem.status != NVNetworkPingStatusDidStart) {
        [self.pingItemsArr addObject:pingItem];
        if (self.callback) {
            self.callback(pingItem, [self.pingItemsArr copy]);
        }
        self.rePingTimes ++;
        NSTimer *timer = [NSTimer timerWithTimeInterval:0.01 target:self selector:@selector(reping) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        if (self.rePingTimes == self.maxPingTimes) {
            [self cancel];
        }
    }
}

- (void)cancel {
    if (self.isStarted) {
        [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeoutActionFired) object:nil];
        self.isStarted = NO;
        [self.pinger stop];
        NVNetworkPingItem *pingItem = [[NVNetworkPingItem alloc] init];
        pingItem.status = NVNetworkPingStatusFinished;
        [self.pingItemsArr addObject:pingItem];
        if (self.callback) {
            self.callback(pingItem, [self.pingItemsArr copy]);
        }
    }
}

- (void)reset{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    self.isStarted = NO;
    [self.pinger stop];
    self.rePingTimes = 0;
    [self.pingItemsArr removeAllObjects];
}

#pragma mark  --------  delegate

- (void)simplePing:(NVNetworkPing *)pinger didStartWithAddress:(NSData *)address{
    if (self.isStarted) {
        NSData *packet = [pinger sendPingWithData:nil];
        NVNetworkPingItem *pingItem = [[NVNetworkPingItem alloc] init];
        pingItem.IPAddress = pinger.IPAddress;
        pingItem.originalAddress = self.hostName;
        pingItem.dateBytesLength = packet.length - sizeof(ICMPHeader);
        pingItem.status = NVNetworkPingStatusDidStart;
        [self handlePingItem:pingItem];
        [pinger sendPacket:packet];
    }
}

- (void)simplePing:(NVNetworkPing *)pinger didFailWithError:(NSError *)error{
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeoutActionFired) object:nil];
    [self.pinger stop];
    NVNetworkPingItem *errorPingItem = [[NVNetworkPingItem alloc] init];
    errorPingItem.originalAddress = self.hostName;
    errorPingItem.IPAddress = pinger.IPAddress ?: pinger.hostName;
    errorPingItem.status = NVNetworkPingStatusError;
    [self handlePingItem:errorPingItem];
}

- (void)simplePing:(NVNetworkPing *)pinger didSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber{
    self.sequenceNumber = sequenceNumber;
}

- (void)simplePing:(NVNetworkPing *)pinger didFailToSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber error:(NSError *)error{
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeoutActionFired) object:nil];
    _sequenceNumber = sequenceNumber;
    NVNetworkPingItem *pingItem = [[NVNetworkPingItem alloc] init];
    pingItem.ICMPSequence = _sequenceNumber;
    pingItem.originalAddress = self.hostName;
    pingItem.status = NVNetworkPingStatusDidFailToSendPacket;
    [self handlePingItem:pingItem];
    
}


- (void)simplePing:(NVNetworkPing *)pinger didReceivePingResponsePacket:(NSData *)packet timeToLive:(NSInteger)timeToLive sequenceNumber:(uint16_t)sequenceNumber timeElapsed:(NSTimeInterval)timeElapsed{
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeoutActionFired) object:nil];
    NVNetworkPingItem *pingItem = [[NVNetworkPingItem alloc] init];
    pingItem.IPAddress = pinger.IPAddress;
    pingItem.dateBytesLength = packet.length;
    pingItem.timeToLive = timeToLive;
    pingItem.timeMilliseconds = timeElapsed * 1000;
    pingItem.ICMPSequence = sequenceNumber;
    pingItem.originalAddress = self.hostName;
    pingItem.status = NVNetworkPingStatusDidReceivePacket;
    [self handlePingItem:pingItem];
}

- (void)simplePing:(NVNetworkPing *)pinger didReceiveUnexpectedPacket:(NSData *)packet{
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeoutActionFired) object:nil];
    NVNetworkPingItem *pingItem = [[NVNetworkPingItem alloc] init];
    pingItem.ICMPSequence = self.sequenceNumber;
    pingItem.originalAddress = self.hostName;
    pingItem.status = NVNetworkPingStatusDidReceiveUnexpectedPacket;
    [self handlePingItem:pingItem];
}

@end
