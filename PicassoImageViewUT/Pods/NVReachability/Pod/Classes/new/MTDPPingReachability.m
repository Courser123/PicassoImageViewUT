//
//  MTDPPingReachability.m
//  NVReachability
//
//  Created by xiangnan.yang on 2017/12/18.
//

#import "MTDPPingReachability.h"
#import "MTDPPing.h"
#import "NSThread+Reachability.h"
/*
 每次ping都会重新做一次dns解析
 */
typedef NS_ENUM(NSInteger ,MTDPPingStatus) {
    MTDPPingStatusDidStart,
    MTDPPingStatusDidFailToSendPacket,
    MTDPPingStatusDidReceivePacket,
    MTDPPingStatusDidReceiveUnexpectedPacket,
    MTDPPingStatusDidTimeout,
    MTDPPingStatusError,
    MTDPPingStatusDidForceCancel
};

@interface MTDPPingItem ()

@property(nonatomic, copy) NSString *originalAddress;
@property(nonatomic, copy) NSString *IPAddress;

@property(nonatomic,assign) NSUInteger dateBytesLength;
@property(nonatomic,assign) double     timeMilliseconds;
@property(nonatomic,assign) NSInteger  timeToLive;
@property(nonatomic,assign) NSInteger  ICMPSequence;
@property(nonatomic)        MTDPPingStatus status;
@property (nonatomic, strong)NSTimer *pingTimer;

+ (NSString *)statisticsWithPingItems:(NSArray *)pingItems;

@end

#define MTDPPingTimeout 0

@implementation MTDPPingItem

- (NSString *)description {
    switch (self.status) {
        case MTDPPingStatusDidStart:
            return [NSString stringWithFormat:@"PING %@ (%@): %ld data bytes",self.originalAddress, self.IPAddress, (long)self.dateBytesLength];
        case MTDPPingStatusDidReceivePacket:
            return [NSString stringWithFormat:@"%ld bytes from %@: icmp_seq=%ld ttl=%ld time=%.3f ms", (long)self.dateBytesLength, self.IPAddress, (long)self.ICMPSequence, (long)self.timeToLive, self.timeMilliseconds];
        case MTDPPingStatusDidTimeout:
            return [NSString stringWithFormat:@"Request timeout for icmp_seq %ld", (long)self.ICMPSequence];
        case MTDPPingStatusDidFailToSendPacket:
            return [NSString stringWithFormat:@"Fail to send packet to %@: icmp_seq=%ld", self.IPAddress, (long)self.ICMPSequence];
        case MTDPPingStatusDidReceiveUnexpectedPacket:
            return [NSString stringWithFormat:@"Receive unexpected packet from %@: icmp_seq=%ld", self.IPAddress, (long)self.ICMPSequence];
        case MTDPPingStatusError:
            return [NSString stringWithFormat:@"Can not ping to %@", self.originalAddress];
        case MTDPPingStatusDidForceCancel:
            return @"timeout cancal all ping";
        default:
            break;
    }
    return super.description;
}


+ (NSString *)statisticsWithPingItems:(NSArray *)pingItems {
    NSString *address = [pingItems.firstObject originalAddress];
    __block NSInteger receivedCount = 0, allCount = 0;
    [pingItems enumerateObjectsUsingBlock:^(MTDPPingItem *obj, NSUInteger idx, BOOL *stop) {
        if (obj.status != MTDPPingStatusError) {
            allCount ++;
            if (obj.status == MTDPPingStatusDidReceivePacket) {
                receivedCount ++;
            }
        }
    }];
    
    NSMutableString *description = [NSMutableString stringWithCapacity:50];
    [description appendFormat:@"--- %@ ping statistics ---\n", address];
    
    CGFloat lossPercent = (CGFloat)(allCount - receivedCount) / MAX(1.0, allCount) * 100;
    [description appendFormat:@"%ld packets transmitted, %ld packets received, %.1f%% packet loss\n", (long)allCount, (long)receivedCount, lossPercent];
    return [description stringByReplacingOccurrencesOfString:@".0%" withString:@"%"];
}

@end

@interface MTDPPingReachability ()<MTDPPingDelegate>

@property (nonatomic, strong) NSMutableArray *pingArray;
@property (nonatomic, assign) BOOL isNext;

@end

@implementation MTDPPingReachability

- (instancetype)init{
    if (self = [super init]) {
        _isPinging = NO;
        _pingArray = [NSMutableArray new];
        _maxPingCountPerHost = 5;
        _timeout = 5000;//ms
    }
    return self;
}

- (void)start{
    if (self.callBack == NULL || !self.hostArray.count) {
        NSAssert(self.callBack != NULL, @"callback can't be NULL");
        NSAssert(self.hostArray.count > 0,@"host count must > 0");
        return;
    }
    [[NSThread threadForReachability] performRBBlock:^{
        if (_isPinging) {
            NSAssert(NO, @"please cancel previous ping");
            return;
        }
//清理历史数据
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [self performSelector:@selector(cancel) withObject:nil afterDelay:self.timeout/1000];
        if (self.pingArray.count > 0) {
            NSArray *arr = [NSArray arrayWithArray:self.pingArray];
            for (MTDPPing *ping in arr) {
                [ping stop];
                ping.delegate = nil;
                [self.pingArray removeObject:ping];
            }
        }
        _isPinging = YES;
//开始ping
        NSArray *arr = [NSArray arrayWithArray:self.hostArray];
        for(NSString *host in arr){
            if(!_isPinging){
                return;
            }
            MTDPPing *ping = [[MTDPPing alloc] initWithHostName:host];
            ping.delegate = self;
            ping.addressStyle = MTDPPingAddressStyleAny;
            [self.pingArray addObject:ping];
            [ping start];
            _isNext = NO;
            while (_isPinging && !_isNext) {
                [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
            }
            if(self.callBack){
                self.callBack([MTDPPingItem statisticsWithPingItems:ping.pingItems]);
            }
        }
    }];
}

//cancel or 整体超时
- (void)cancel{
    [[NSThread threadForReachability] performRBBlock:^{
        MTDPPingItem *pingItem = [[MTDPPingItem alloc] init];
        pingItem.status = MTDPPingStatusDidForceCancel;
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        if(self.callBack){
            self.callBack([pingItem description]);
        }
        if (self.isPinging) {
            self.isPinging = NO;
            _isNext        = YES;
        }
    }];
}

- (void)timeoutActionFired:(MTDPPing *)ping{
    MTDPPingReachability *strongSelf = self;
    MTDPPingItem *pingItem   = [[MTDPPingItem alloc] init];
    pingItem.ICMPSequence    = ping.nextSequenceNumber-1;
    pingItem.originalAddress = ping.hostName;
    pingItem.status          = MTDPPingStatusDidTimeout;
    [ping.pingItems addObject:pingItem];
    ping.pingCount++;
    if (strongSelf.callBack){
        strongSelf.callBack([pingItem description]);
    }
    if (![strongSelf checkIsFinish:ping])
    {
        [ping stop];
        [ping start];
    }
}

- (BOOL)checkIsFinish:(MTDPPing *)ping{

    if(ping.pingCount >= self.maxPingCountPerHost){
        [ping stop];
        ping.delegate = nil;
      
        if(self.pingArray.count == self.hostArray.count){
            self.isPinging = NO;
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(cancel) object:nil];
        }
        _isNext = YES;
        return YES;
    }
    return NO;
}

- (void)onResponse:(MTDPPing *)ping item:(MTDPPingItem *)pingItem{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeoutActionFired:) object:ping];
    ping.pingCount ++;
    if(self.callBack && self.isPinging){
        self.callBack([pingItem description]);
    }
    if(![self checkIsFinish:ping]){
        [self performSelector:@selector(reping:) withObject:ping afterDelay:MTDPPingTimeout];
    }
}

#pragma mark  ping delegate
//dns 解析成功后调用
- (void)simplePing:(MTDPPing *)ping didStartWithAddress:(NSData *)address
{ //解析host结束
    NSData *packet = [ping sendPingWithData:nil];
    if (ping.pingCount == 0)
    {
        MTDPPingItem *pingItem   = [self newItem:ping status:MTDPPingStatusDidStart];
        pingItem.dateBytesLength = packet.length - sizeof(ICMPHeader);
        if (self.callBack && self.isPinging)
        {
            self.callBack([pingItem description]);
        }
    }
    [ping sendPacket:packet];
    [self performSelector:@selector(timeoutActionFired:) withObject:ping afterDelay:0.5];
}

- (void)simplePing:(MTDPPing *)ping didReceivePingResponsePacket:(NSData *)packet timeToLive:(NSInteger)timeToLive sequenceNumber:(uint16_t)sequenceNumber timeElapsed:(NSTimeInterval)timeElapsed{
    MTDPPingItem *pingItem    = [self newItem:ping status:MTDPPingStatusDidReceivePacket];
    pingItem.timeToLive       = timeToLive;
    pingItem.timeMilliseconds = timeElapsed * 1000;
    pingItem.ICMPSequence     = sequenceNumber;
    pingItem.dateBytesLength  = packet.length;
    [ping.pingItems addObject:pingItem];
    [self onResponse:ping item:pingItem];
}

- (void)reping:(MTDPPing *)ping {
    [ping stop];
    ping.delegate = self;
    [ping start];
}

//域名解析失败
- (void)simplePing:(MTDPPing *)ping didFailWithError:(NSError *)error{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeoutActionFired:) object:ping];
    MTDPPingItem *errorItem = [self newItem:ping status:MTDPPingStatusError];
    [ping.pingItems addObject:errorItem];
    if(self.callBack && self.isPinging){
        self.callBack([errorItem description]);
    }
    [ping stop];
    ping.delegate = nil;
    _isNext = YES;
}

- (void)simplePing:(MTDPPing *)ping didSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber{

}
//like dns resolve failed.
//cancel ping
- (void)simplePing:(MTDPPing *)ping didFailToSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber error:(NSError *)error{
    MTDPPingItem *pingItem = [self newItem:ping status:MTDPPingStatusDidFailToSendPacket];
    [self onResponse:ping item:pingItem];
}

- (void)simplePing:(MTDPPing *)ping didReceiveUnexpectedPacket:(NSData *)packet{
    MTDPPingItem *pingItem = [self newItem:ping status:MTDPPingStatusDidReceiveUnexpectedPacket];
    [self onResponse:ping item:pingItem];
}


- (MTDPPingItem *)newItem:(MTDPPing *)ping status:(MTDPPingStatus)status{
    MTDPPingItem *pingItem = [[MTDPPingItem alloc] init];
    pingItem.IPAddress = ping.IPAddress ?: ping.hostName;
    pingItem.status = status;
    pingItem.originalAddress = ping.hostName;
    pingItem.ICMPSequence = ping.nextSequenceNumber;
    return pingItem;
}

- (void)dealloc{
    if (_isPinging) {
        _isPinging = NO;
    }
}

@end
