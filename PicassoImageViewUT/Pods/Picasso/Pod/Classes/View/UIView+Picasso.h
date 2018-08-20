//
//  UIView+Picasso.h
//  Picasso
//
//  Created by xiebohui on 28/11/2016.
//  Copyright © 2016 xiebohui. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PicassoBaseViewWrapper;
@class PicassoModel;
@interface UIView (Picasso)

@property (nonatomic, strong) NSString * wrapperClz;
@property (nonatomic, copy) NSString *p_tag;
@property (nonatomic, copy) NSString *viewId;
@property (nonatomic, strong) PicassoModel *pModel;
@end
