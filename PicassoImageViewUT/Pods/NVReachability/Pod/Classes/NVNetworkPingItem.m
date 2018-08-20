//
//  NVNetworkPingItem.m
//  Pods
//
//  Created by yxn on 2016/11/20.
//
//

#import "NVNetworkPingItem.h"

@implementation NVNetworkPingItem

- (NSString *)description {
    switch (self.status) {
        case NVNetworkPingStatusDidStart:
            return [NSString stringWithFormat:@"PING %@ (%@): %ld data bytes",self.originalAddress, self.IPAddress, (long)self.dateBytesLength];
        case NVNetworkPingStatusDidReceivePacket:
            return [NSString stringWithFormat:@"%ld bytes from %@: icmp_seq=%ld ttl=%ld time=%.3f ms", (long)self.dateBytesLength, self.IPAddress, (long)self.ICMPSequence, (long)self.timeToLive, self.timeMilliseconds];
        case NVNetworkPingStatusDidTimeout:
            return [NSString stringWithFormat:@"Request timeout for icmp_seq %ld", (long)self.ICMPSequence];
        case NVNetworkPingStatusDidFailToSendPacket:
            return [NSString stringWithFormat:@"Fail to send packet to %@: icmp_seq=%ld", self.IPAddress, (long)self.ICMPSequence];
        case NVNetworkPingStatusDidReceiveUnexpectedPacket:
            return [NSString stringWithFormat:@"Receive unexpected packet from %@: icmp_seq=%ld", self.IPAddress, (long)self.ICMPSequence];
        case NVNetworkPingStatusError:
            return [NSString stringWithFormat:@"Can not ping to %@", self.originalAddress];
        default:
            break;
    }
    return super.description;
}

+ (NSString *)statisticsWithPingItems:(NSArray *)pingItems {
    //    --- ping statistics ---
    //    5 packets transmitted, 5 packets received, 0.0% packet loss
    //    round-trip min/avg/max/NVNetworkdev = 4.445/9.496/12.210/2.832 ms
    NSString *address = [pingItems.firstObject originalAddress];
    __block NSInteger receivedCount = 0, allCount = 0;
    [pingItems enumerateObjectsUsingBlock:^(NVNetworkPingItem *obj, NSUInteger idx, BOOL *stop) {
        if (obj.status != NVNetworkPingStatusFinished && obj.status != NVNetworkPingStatusError) {
            allCount ++;
            if (obj.status == NVNetworkPingStatusDidReceivePacket) {
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

+ (BOOL)isNetworkReachableWithPingItems:(NSArray *)pingItems {
    __block NSInteger receivedCount = 0;
    [pingItems enumerateObjectsUsingBlock:^(NVNetworkPingItem *obj, NSUInteger idx, BOOL *stop) {
        if (obj.status != NVNetworkPingStatusFinished && obj.status != NVNetworkPingStatusError) {
            if (obj.status == NVNetworkPingStatusDidReceivePacket) {
                receivedCount ++;
            }
        }
    }];
    
    if (receivedCount > 0) {
        return YES;
    }else{
        return NO;
    }
}

@end
