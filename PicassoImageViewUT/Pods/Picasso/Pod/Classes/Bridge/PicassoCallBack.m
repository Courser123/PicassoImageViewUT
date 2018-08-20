//
//  PicassoCallBack.m
//  AFNetworking
//
//  Created by 纪鹏 on 2017/7/19.
//

#import "PicassoCallBack.h"
#import "PicassoHost+Bridge.h"


@implementation PicassoError

+(PicassoError *)errorWithCode:(NSInteger)errCode msg:(NSString *)msg customInfo:(NSDictionary *)info {
    PicassoError *error = [PicassoError new];
    error.errorMsg = msg;
    error.errorCode = errCode;
    error.customInfo = info;
    return error;
}

@end

@interface PicassoCallBack ()

@property (nonatomic, weak) PicassoHost *host;
@property (nonatomic, copy) NSString *callbackId;

@end

@implementation PicassoCallBack

+ (nonnull instancetype)callbackWithHost:(nonnull PicassoHost *)host callbackId:(nonnull NSString *)callbackId {
    PicassoCallBack *callback = [[PicassoCallBack alloc] init];
    callback.callbackId = callbackId;
    callback.host = host;
    return callback;
}

- (void)sendSuccess:(nullable NSDictionary *)data {
    [self.host callbackSuccessWithCallbackId:self.callbackId responseData:data];
}

- (void)sendError:(nullable PicassoError *)error {
    [self.host callbackFailWithCallbackId:self.callbackId error:error];
}

- (void)sendNext:(nullable NSDictionary *)data {
    [self.host callbackHandleWithCallbackId:self.callbackId responseData:data];
}


@end
