//
//  MTDPNetworkDetection.h
//  NVReachability
//
//  Created by xiangnan.yang on 2017/12/19.
//


#import <Foundation/Foundation.h>

typedef void(^NetworkDetectionCallBack)(NSString *report);

@interface MTDPNetworkDetection : NSObject

@property (nonatomic, copy,readonly)NSString *report;
@property (nonatomic, copy)NetworkDetectionCallBack callback;
@property (nonatomic, assign)NSTimeInterval timeout;
@property (nonatomic, strong)NSArray *dnsDamain;//for dns
@property (nonatomic, strong)NSArray *pingDomain;//for dns
@property (nonatomic, assign,readonly)BOOL isDetecting;

- (void)start;
- (void)cancel;

//+ (CTCellularDataRestrictedState)checkAuthority;
@end
