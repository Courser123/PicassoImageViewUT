//
//  NSThread+Reachability.h
//  NVReachability
//
//  Created by xiangnan.yang on 2017/12/18.
//

#import <Foundation/Foundation.h>

static NSThread *processReachabilityThread;

@interface NSThread (Reachability)

+ (NSThread *)threadForReachability;
- (void)performRBBlock:(void(^)())block;
- (void)performRBBlock:(void (^)())block afterDelay:(NSTimeInterval)delay;
+ (void)releaseReachabilityThread;

@end
