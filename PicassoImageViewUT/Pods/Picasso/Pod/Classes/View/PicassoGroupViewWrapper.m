//
//  PicassoGroupViewWrapper.m
//  clogan
//
//  Created by 纪鹏 on 2017/10/19.
//

#import "PicassoGroupViewWrapper.h"
#import "PicassoGroupView.h"
#import "PicassoRenderUtils.h"
#import "PicassoViewModel.h"

@implementation PicassoGroupViewWrapper

+ (Class)viewClass {
    return [PicassoGroupView class];
}

+ (Class)modelClass {
    return [PicassoViewModel class];
}

+ (UIView *)createViewWithModel:(PicassoModel *)model inPicassoView:(PicassoView *)picassoView {
    PicassoGroupView *view = [PicassoGroupView new];
    [self updateView:view withModel:model inPicassoView:picassoView];
    return view;
}

+ (void)updateView:(UIView *)view withModel:(PicassoModel *)model inPicassoView:(PicassoView *)picassoView {
    [super updateView:view withModel:model inPicassoView:picassoView];
    [PicassoRenderUtils updateViewTreeInPicassoView:picassoView withModel:model rootView:view];
    if ([view isKindOfClass:[PicassoGroupView class]]) {
        PicassoGroupView *groupView = (PicassoGroupView *)view;
        [groupView updateWithModel:(PicassoViewModel *)model inPicassoView:picassoView];
    }
}

+ (void)updateViewWithoutSubviewUpdate:(UIView *)view withModel:(PicassoModel *)model inPicassoView:(PicassoView *)picassoView {
    [super updateView:view withModel:model inPicassoView:picassoView];
    if ([view isKindOfClass:[PicassoGroupView class]]) {
        PicassoGroupView *groupView = (PicassoGroupView *)view;
        [groupView updateWithModel:(PicassoViewModel *)model inPicassoView:picassoView];
    }
}

@end
