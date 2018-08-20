//
//  NVNetherSwapHelper.h
//  Pods
//
//  Created by David on 2017/6/23.
//
//
//#ifdef DEBUG

#import <UIKit/UIKit.h>

typedef void(^SwapDataFetched)(NSString * swapData, NSError * error);

@interface NVNetherSwapHelper : NSObject

@property (nonatomic, copy) NSString * swapToken;

+ (NVNetherSwapHelper *)instance;
/*
 * only for debug mode
 * use with DEBUG wrapper
 * scan to get token first
 */
- (void)swapDataFetched:(SwapDataFetched)swapDataFetched;

@end

//#endif
