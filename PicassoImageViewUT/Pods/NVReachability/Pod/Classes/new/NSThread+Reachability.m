//
//  NSThread+Reachability.m
//  NVReachability
//
//  Created by xiangnan.yang on 2017/12/18.
//

#import "NSThread+Reachability.h"

@implementation NSThread (Reachability)

- (void)performRBBlock:(void(^)())block{
    [self performSelector:@selector(onlyForRunBlock:) onThread:self withObject:block waitUntilDone:NO];
}

- (void)performRBBlock:(void (^)())block afterDelay:(NSTimeInterval)delay{
    [self performRBBlock:^{
        [self performSelector:@selector(onlyForRunBlock:) withObject:block afterDelay:delay];
    }];
}

- (void)onlyForRunBlock:(void(^)())block{
    if(block){
        block();
    }
}

+ (NSThread *)threadForReachability{
    BOOL bInit = NO;
    if (processReachabilityThread == nil) {
        @synchronized(self){
            if (processReachabilityThread == nil) {
                processReachabilityThread = [[NSThread alloc] initWithTarget:self selector:@selector(runRequests) object:nil];
                bInit = YES;
            }
        }
    }
    
    if (bInit) {
        [processReachabilityThread setName:@"ReachabilityThread"];
        [processReachabilityThread start];
    }
    return processReachabilityThread;
}

+ (void)releaseReachabilityThread{
    [self performSelectorOnMainThread:@selector(releaseSelf) withObject:nil waitUntilDone:NO];
}

+ (void)releaseSelf{
    processReachabilityThread = nil;
}

+ (void)runRequests{
    CFRunLoopSourceContext context = {0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL};
    CFRunLoopSourceRef source = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &context);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), source, kCFRunLoopDefaultMode);
    
    @autoreleasepool {
        CFRunLoopRun();
    }
    
    CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, kCFRunLoopDefaultMode);
    CFRelease(source);
}


@end
