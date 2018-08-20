//
//  PicassoBaseView.m
//  Pods
//
//  Created by 纪鹏 on 2017/6/5.
//
//

#import "PicassoBaseViewWrapper.h"
#import "PicassoHostManager.h"
#import "PicassoModel.h"
#import "UIView+Picasso.h"
#import "ReactiveCocoa.h"
#import "PicassoBridgeContext.h"
#import "PicassoView.h"
#import "PicassoVCHost.h"
#import "PicassoCallBack.h"
#import "UIView+PicassoNotification.h"
#import "PicassoViewWrapperFactory.h"
#import "UIImage+pcs_gradientColor.h"

@implementation PicassoBaseViewWrapper

+ (Class)viewClass {
    return nil;
}

+ (Class)modelClass {
    return nil;
}

+ (UIView *)createViewWithModel:(PicassoModel *)model inPicassoView:(PicassoView *)picassoView {
    return nil;
}

+ (void)updateView:(UIView *)view withModel:(PicassoModel *)model inPicassoView:(PicassoView *)picassoView {
    view.p_tag = model.tag;
    view.wrapperClz = NSStringFromClass([PicassoViewWrapperFactory viewWrapperByType:model.type]);
    [self postUpdateNotificationWithOldModel:view.pModel newModel:model forView:view inPicassoView:picassoView];
    view.pModel = model;

    if (view == picassoView) {
        CGRect rect = view.frame;
        rect.size = CGSizeMake(model.width, model.height);
        view.frame = rect;
    } else {
        if (!CGRectEqualToRect((CGRect){model.x, model.y, model.width, model.height}, view.frame)) {
            view.frame = CGRectMake(model.x, model.y, model.width, model.height);
        }
    }
    
    view.backgroundColor = model.backgroundColor;
    if (model.gradientColors.count) {
        UIImage *bgImg = [UIImage pcs_gradientColorImageFromColors:model.gradientColors startPoint:model.gradientStartPoint endPoint:model.gradientEndPoint imgSize:view.frame.size];
        view.backgroundColor = [UIColor colorWithPatternImage:bgImg];
    }
    view.hidden = model.hidden;
    view.alpha = model.alpha;
    view.clipsToBounds = YES;
    if (model.rectCorner == 0 || model.rectCorner == 15) {
        view.layer.mask = nil;
        view.layer.cornerRadius = model.cornerRadius;
    } else {
        view.layer.cornerRadius = 0;
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners:model.rectCorner cornerRadii:CGSizeMake(model.cornerRadius, model.cornerRadius)];
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.frame = view.bounds;
        maskLayer.path = maskPath.CGPath;
        view.layer.mask = maskLayer;
    }
    view.layer.borderWidth = model.borderWidth;
    if (model.borderWidth) {
        view.layer.borderColor = model.borderColor.CGColor;
    }
    view.layer.shadowOpacity = model.shadowOpacity;
    if (model.shadowOpacity > CGFLOAT_MIN) {
        view.clipsToBounds = NO;
        view.layer.shadowRadius = model.shadowRadius;
        view.layer.shadowOffset = model.shadowOffset;
        view.layer.shadowColor = model.shadowColor.CGColor;
    }
        
    view.accessibilityIdentifier = model.accessId;
    view.isAccessibilityElement = model.accessLabel.length > 0;
    view.accessibilityLabel = model.accessLabel;
}

+ (void)postUpdateNotificationWithOldModel:(PicassoModel *)oldModel newModel:(PicassoModel *)newModel forView:(UIView *)view inPicassoView:(PicassoView *)picassoView
{
    if (!newModel.gaLabel.length || !view) {
        return ;
    }
    if ([oldModel.gaLabel isEqualToString:newModel.gaLabel] && [oldModel.gaUserInfo isEqualToDictionary:newModel.gaUserInfo]) {
        return;
    }
    __weak typeof(view) weakView = view;
    NSDictionary *userInfo = @{
                               @"view" : weakView,
                               @"gaLabel" : newModel.gaLabel?:@"",
                               @"gaUserInfo" : newModel.gaUserInfo?:@{}
                               };
    PicassoNotificationUserInfo *notificationUserInfo = [[PicassoNotificationUserInfo alloc] initWithViewTag:newModel.tag userInfo:userInfo];
    [picassoView.defaultCenter postNotificationName:PicassoControlEventUpdate userInfo:notificationUserInfo];
}

@end
