//
//  PicassoRenderUtils.m
//  clogan
//
//  Created by 纪鹏 on 2017/10/20.
//

#import "PicassoRenderUtils.h"
#import "PicassoView.h"
#import "PicassoViewModel.h"
#import "PicassoViewWrapperFactory.h"
#import "UIView+Picasso.h"
#import "PicassoBaseViewWrapper.h"
#import "UIView+PicassoNotification.h"
#import "PicassoVCHost.h"
#import "PicassoVCHost+Private.h"
#import "PicassoGroupViewWrapper.h"
#import "PicassoHostManager.h"

@implementation PicassoRenderUtils

#pragma mark - ViewTree generate methods
+ (void)updateViewTreeInPicassoView:(PicassoView *)picassoView withModel:(PicassoModel *)model rootView:(UIView *)rootView {
    if (![model isKindOfClass:[PicassoViewModel class]]) {
        return;
    }
    PicassoViewModel *viewmodel = (PicassoViewModel *)model;
    for (NSUInteger i = 0; i < viewmodel.subviews.count; i++) {
        PicassoModel *submodel = viewmodel.subviews[i];
        if (i >= rootView.subviews.count) {
            [self addViewInPicassoView:picassoView withModel:submodel rootView:rootView index:i];
        } else {
            UIView *subview = rootView.subviews[i];
            if ([self isEqualClass:subview type:submodel.type]) {
                if (![subview.pModel.viewId isEqualToString:submodel.viewId]) {
                    [self removeViewMapWithView:subview];
                    [self updateViewMapWithView:subview model:submodel];
                }
                [[PicassoViewWrapperFactory viewWrapperByType:submodel.type] updateView:subview withModel:submodel inPicassoView:picassoView];
            } else {
                [subview removeFromSuperview];
                [self removeViewMapWithView:subview];
                [self addViewInPicassoView:picassoView withModel:submodel rootView:rootView index:i];
            }
        }
    }
    NSInteger totalSubviewCount = rootView.subviews.count;
    if (totalSubviewCount > 0) {
        for (NSInteger j = totalSubviewCount - 1; j >= (NSInteger)viewmodel.subviews.count; j--) {
            UIView *subview = rootView.subviews[j];
            [subview removeFromSuperview];
            [self removeViewMapWithView:subview];
        }
    }
}

+ (void)updateViewMapWithView:(UIView *)view model:(PicassoModel *)model {
    PicassoHost *host = [PicassoHostManager hostForId:model.hostId];
    if ([host isKindOfClass:[PicassoVCHost class]]) {
        PicassoVCHost *vchost = (PicassoVCHost *)host;
        [vchost storeView:view withId:model.viewId];
    }
}

+ (void)removeViewMapWithView:(UIView *)view {
    PicassoModel *model = view.pModel;
    PicassoHost *host = [PicassoHostManager hostForId:model.hostId];
    if ([host isKindOfClass:[PicassoVCHost class]]) {
        PicassoVCHost *vchost = (PicassoVCHost *)host;
        [vchost removeViewForId:model.viewId];
    }
}

+ (void)addViewInPicassoView:(PicassoView *)picassoView withModel:(PicassoModel *)model rootView:(UIView *)rootView index:(NSInteger)index {
    UIView *newView = [self createViewInPicassoView:picassoView withModel:model];
    [self updateViewMapWithView:newView model:model];
    if (index > rootView.subviews.count - 1) {
        [rootView addSubview:newView];
    } else {
        [rootView insertSubview:newView atIndex:index];
    }
}

+ (UIView *)createViewInPicassoView:(PicassoView *)picassoView withModel:(PicassoModel *)model {
    UIView *view = [[PicassoViewWrapperFactory viewWrapperByType:model.type] createViewWithModel:model inPicassoView:picassoView];
    view.pcs_defaultCenter = picassoView.defaultCenter;
    return view;
}

+ (BOOL)isEqualClass:(UIView *)view type:(NSInteger)type {
    return NSClassFromString(view.wrapperClz) == [PicassoViewWrapperFactory viewWrapperByType:type];
}

@end
