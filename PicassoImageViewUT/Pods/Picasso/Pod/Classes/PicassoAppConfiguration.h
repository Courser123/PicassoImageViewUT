//
//  PicassoAppConfiguration.h
//  CocoaAsyncSocket
//
//  Created by 纪鹏 on 2017/7/31.
//

#import <Foundation/Foundation.h>
#import "PicassoSDK.h"

@interface PicassoAppConfiguration : NSObject

@property (nonatomic, strong) NSNumber *appId;
@property (nonatomic, strong) UIImage *loadingImage;
@property (nonatomic, strong) UIImage *errorImage;
@property (nonatomic, copy) PicassoGetUnionIdBlock unionIdBlock;

+ (PicassoAppConfiguration *)instance;


@end
