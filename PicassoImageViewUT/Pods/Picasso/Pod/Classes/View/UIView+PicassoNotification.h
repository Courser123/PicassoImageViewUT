//
//  UIView+PicassoNotification.h
//  Picasso
//
//  Created by xiebohui on 07/12/2016.
//  Copyright © 2016 xiebohui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PicassoNotificationCenter.h"

typedef void(^PicassoViewAction)(void);

@interface UIView (PicassoNotification)

@property (nonatomic, copy) PicassoViewAction pcs_action;
@property (nonatomic, weak) PicassoNotificationCenter *pcs_defaultCenter;

@end
