//
//  PicassoCallBack.h
//  AFNetworking
//
//  Created by 纪鹏 on 2017/7/19.
//

#import <Foundation/Foundation.h>

@class PicassoHost;

@interface PicassoError : NSObject

+(nonnull PicassoError *)errorWithCode:(NSInteger)errCode msg:(nullable NSString *)msg customInfo:(nullable NSDictionary *)info;

@property (nonatomic, copy, nullable) NSString  *errorMsg;
@property (nonatomic, assign) NSInteger errorCode;
@property (nonatomic, strong, nullable) NSDictionary  *customInfo;

@end


@interface PicassoCallBack : NSObject

+ (nonnull instancetype)callbackWithHost:(nonnull PicassoHost *)host callbackId:(nonnull NSString *)callbackId;

- (void)sendSuccess:(nullable NSDictionary *)data;
- (void)sendError:(nullable PicassoError *)error;
- (void)sendNext:(nullable NSDictionary *)data;

@end
