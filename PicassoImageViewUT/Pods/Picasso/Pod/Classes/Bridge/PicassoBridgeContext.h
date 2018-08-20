//
//  PicassoBridgeContext.h
//  Pods
//
//  Created by 纪鹏 on 2017/5/10.
//
//

#import <Foundation/Foundation.h>

@class JSValue;
@class PicassoError;

typedef NS_ENUM(NSInteger, PicassoBridgeStatus){
    PicassoBridgeStatusSuccess,           // JS桥事件成功回调
    PicassoBridgeStatusFailure,           // JS桥事件失败回调
    PicassoBridgeStatusAction             // JS桥事件动作回调
};

@interface PicassoBridgeContext : NSObject

+ (instancetype)sharedInstance;

- (void)createPCWithHostId:(NSString *)hId jsScript:(NSString *)script options:(NSDictionary *)options data:(NSDictionary *)data;
- (void)createPCWithHostId:(NSString *)hostId jsScript:(NSString *)script options:(NSDictionary *)options stringData:(NSString *)strData;
- (void)updatePCWithHostId:(NSString *)hostId method:(NSString *)method argument:(NSDictionary *)args;
- (JSValue *)syncCallPCWithHostId:(NSString *)hostId method:(NSString *)method argument:(NSDictionary *)args;
- (void)destroyPCWithHostId:(NSString *)hostId;

- (void)callbackSuccessWithHost:(NSString *)hostId callbackId:(NSString *)callbackId responseData:(NSDictionary *)responseData;
- (void)callbackFailWithHost:(NSString *)hostId callbackId:(NSString *)callbackId error:(PicassoError *)error;
- (void)callbackHandleWithHost:(NSString *)hostId callbackId:(NSString *)callbackId responseData:(NSDictionary *)responseData;

@end
