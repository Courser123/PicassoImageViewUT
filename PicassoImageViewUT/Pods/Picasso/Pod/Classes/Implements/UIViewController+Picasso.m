//
//  UIViewController+Picasso.m
//  Picasso
//
//  Created by 纪鹏 on 2017/12/6.
//

#import "UIViewController+Picasso.h"
#import <objc/runtime.h>

static const void *PicassoNavibarHidden = &PicassoNavibarHidden;

@implementation UIViewController (Picasso)

- (void)setPcs_navibarHidden:(BOOL)pcs_navibarHidden {
    objc_setAssociatedObject(self, PicassoNavibarHidden, @(pcs_navibarHidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)pcs_navibarHidden {
    NSNumber *hidden = objc_getAssociatedObject(self, PicassoNavibarHidden);
    return [hidden boolValue];
}

@end
