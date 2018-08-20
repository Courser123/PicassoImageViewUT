//
//  PicassoHost+Bridge.h
//  CocoaAsyncSocket
//
//  Created by 纪鹏 on 2017/7/14.
//

#import "PicassoHost.h"

@class PicassoError;
@class PicassoBridgeModule;
@interface PicassoHost (Bridge)

- (void)callbackSuccessWithCallbackId:(NSString *)callbackId responseData:(NSDictionary *)responseData;
- (void)callbackFailWithCallbackId:(NSString *)callbackId error:(PicassoError *)error;
- (void)callbackHandleWithCallbackId:(NSString *)callbackId responseData:(NSDictionary *)responseData;

- (PicassoBridgeModule *)moduleInstanceForClass:(Class)cls;

@end
