//
//  PicassoSDK.m
//  Pods
//
//  Created by 纪鹏 on 2017/7/31.
//

#import "PicassoSDK.h"
#import "PicassoAppConfiguration.h"

@interface PicassoNotificationCenter (Private)
+ (void)registerSchemeCallback:(PicassoNotificationBlock)notificationBlock;
+ (void)registerGAClickCallback:(PicassoNotificationBlock)notificationBlock;
+ (void)registerGAUpdateCallback:(PicassoNotificationBlock)notificationBlock;
@end

@implementation PicassoSDK

+ (void)setAppId:(NSInteger)appId {
    [PicassoAppConfiguration instance].appId = @(appId);
}

+ (void)registerSchemeCallback:(PicassoNotificationBlock)notificationBlock {
    [PicassoNotificationCenter registerSchemeCallback:notificationBlock];
}

+ (void)registerGAClickCallback:(PicassoNotificationBlock)notificationBlock {
    [PicassoNotificationCenter registerGAClickCallback:notificationBlock];
}

+ (void)registerGAUpdateCallback:(PicassoNotificationBlock)notificationBlock {
    [PicassoNotificationCenter registerGAUpdateCallback:notificationBlock];
}

+ (void)configImageViewPlaceholderForLoading:(UIImage *)loadingImage error:(UIImage *)errorImage {
    [PicassoAppConfiguration instance].loadingImage = loadingImage;
    [PicassoAppConfiguration instance].errorImage = errorImage;
}

+ (void)setUnionIdBlock:(PicassoGetUnionIdBlock)block {
    [PicassoAppConfiguration instance].unionIdBlock = block;
}

@end
