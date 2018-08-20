/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ NetworkClock.h                                                                                   ║
  ║                                                                                                  ║
  ║ Created by Gavin Eadie on Oct17/10                                                               ║
  ║ Copyright 2010 Ramsay Consulting. All rights reserved.                                           ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

#import <Foundation/Foundation.h>
#import <CFNetwork/CFNetwork.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "GCDAsyncUdpSocket.h"
#import "NetAssociation.h"

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ The NetworkClock sends notifications of the network time.  It will attempt to provide a very     ┃
  ┃ early estimate and then refine that and reduce the number of notifications ...                   ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
extern NSString *const networkDateDidChanged;

@interface NetworkClock : NSObject {
@private
    NSTimeInterval _timeIntervalSinceDeviceTime;
    NSMutableArray * _timeAssociations;
    dispatch_queue_t _associationDelegateQueue;
    SCNetworkReachabilityRef _networkReachability;
}
@property(nonatomic,assign)NSTimeInterval timeIntervalSinceDeviceTime;

+ (NetworkClock *)sharedNetworkClock;

- (void)createAssociations;
- (void)enableAssociations;
- (void)finishAssociations;

- (NSDate *)networkTime;

- (void)didConnectInternet;
- (void)didDisconnectInternet;
- (void)finishUpdate;

@end
