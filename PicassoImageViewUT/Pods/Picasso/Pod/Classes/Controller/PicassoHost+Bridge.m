//
//  PicassoHost+Bridge.m
//  CocoaAsyncSocket
//
//  Created by 纪鹏 on 2017/7/14.
//

#import "PicassoHost+Bridge.h"
#import "PicassoBridgeContext.h"
#import "PicassoBridgeModule.h"
#import "PicassoHost+Private.h"

@implementation PicassoHost (Bridge)

- (void)callbackSuccessWithCallbackId:(NSString *)callbackId responseData:(NSDictionary *)responseData {
    [[PicassoBridgeContext sharedInstance] callbackSuccessWithHost:self.hostId callbackId:callbackId responseData:responseData];
}

- (void)callbackFailWithCallbackId:(NSString *)callbackId error:(PicassoError *)error {
    [[PicassoBridgeContext sharedInstance] callbackFailWithHost:self.hostId callbackId:callbackId error:error];
}

- (void)callbackHandleWithCallbackId:(NSString *)callbackId responseData:(NSDictionary *)responseData {
    [[PicassoBridgeContext sharedInstance] callbackHandleWithHost:self.hostId callbackId:callbackId responseData:responseData];
}

- (PicassoBridgeModule *)moduleInstanceForClass:(Class)cls {
    NSString *clz = NSStringFromClass(cls);
    if (clz.length == 0) {
        return nil;
    }
    PicassoBridgeModule *module = [self.moduleInstanceMapper objectForKey:clz];
    if (!module) {
        module = [[cls alloc] init];
        module.host = self;
        [self.moduleInstanceMapper setObject:module forKey:clz];
    }
    return module;
}

@end
