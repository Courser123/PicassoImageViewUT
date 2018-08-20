//
//  PicassoMapperModel.h
//  Picasso
//
//  Created by xiebohui on 27/11/2016.
//  Copyright © 2016 xiebohui. All rights reserved.
//


@class PicassoBridgeMethodConfig;
@interface PicassoMapperModel : NSObject

@property (nonatomic, assign) NSInteger viewType;
@property (nonatomic, strong) NSString * viewWrapperClz;
@property (nonatomic, strong) NSString * modelClz;
@property (nonatomic, strong) NSString * viewClz;
@property (nonatomic, strong) PicassoBridgeMethodConfig *methodsConfig;

@end
