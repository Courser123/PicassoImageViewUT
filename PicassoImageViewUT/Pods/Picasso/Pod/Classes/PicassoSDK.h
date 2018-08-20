//
//  PicassoSDK.h
//  Pods
//
//  Created by 纪鹏 on 2017/7/31.
//

#import <Foundation/Foundation.h>
#import "PicassoNotificationCenter.h"

/**
 * Picasso SDK为App统一进行picasso的配置，一般在APP启动时进行配置。
 * 业务方请勿调用该文件的任何接口！！！
 */

typedef NSString *(^PicassoGetUnionIdBlock)();
@interface PicassoSDK : NSObject

+ (void)setAppId:(NSInteger)appId;
+ (void)setUnionIdBlock:(PicassoGetUnionIdBlock)block;

+ (void)registerSchemeCallback:(PicassoNotificationBlock)notificationBlock;
+ (void)registerGAClickCallback:(PicassoNotificationBlock)notificationBlock;
+ (void)registerGAUpdateCallback:(PicassoNotificationBlock)notificationBlock;

+ (void)configImageViewPlaceholderForLoading:(UIImage *)loadingImage error:(UIImage *)errorImage;

@end
