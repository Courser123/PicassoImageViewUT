//
//  UIView+PicassoNotification.m
//  Picasso
//
//  Created by xiebohui on 07/12/2016.
//  Copyright © 2016 xiebohui. All rights reserved.
//

#import "UIView+PicassoNotification.h"
#import <objc/runtime.h>

static const void *PicassoNotificationKey = &PicassoNotificationKey;
static const void *PicassoViewActionKey = &PicassoViewActionKey;

@implementation UIView (PicassoNotification)

- (PicassoNotificationCenter *)pcs_defaultCenter {
    return objc_getAssociatedObject(self, PicassoNotificationKey);
}

- (void)setPcs_defaultCenter:(PicassoNotificationCenter *)pcs_defaultCenter {
    objc_setAssociatedObject(self, PicassoNotificationKey, pcs_defaultCenter, OBJC_ASSOCIATION_ASSIGN);
}

- (PicassoViewAction)pcs_action {
    return objc_getAssociatedObject(self, PicassoViewActionKey);
}

- (void)setPcs_action:(PicassoViewAction)pcs_action {
    objc_setAssociatedObject(self, PicassoViewActionKey, pcs_action, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
