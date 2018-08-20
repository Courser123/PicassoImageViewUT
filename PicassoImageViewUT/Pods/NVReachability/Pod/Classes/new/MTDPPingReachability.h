//
//  MTDPPingReachability.h
//  NVReachability
//
//  Created by xiangnan.yang on 2017/12/18.
//

#import <Foundation/Foundation.h>

@interface MTDPPingItem:NSObject @end

typedef void(^DPMTPingBlock)(NSString *pingMessage);

@interface MTDPPingReachability : NSObject

@property (nonatomic, assign) double        timeout;// ms  default is 5000
@property (nonatomic, assign) NSInteger     maxPingCountPerHost;// default is 5
@property (nonatomic, copy  ) DPMTPingBlock callBack;//
@property (nonatomic, strong) NSArray       *hostArray;
@property (nonatomic, assign) BOOL          isPinging;

- (void)start;

- (void)cancel;

@end
