//
//  PicassoAnimationViewWrapper.m
//  Picasso
//
//  Created by Wang Hualin on 2018/1/26.
//

#import "PicassoAnimationViewWrapper.h"
#import "PicassoAnimationViewModel.h"
#import "PicassoAnimationView.h"

@implementation PicassoAnimationViewWrapper

+ (Class)viewClass {
    return [PicassoAnimationView class];
}

+ (Class)modelClass {
    return [PicassoAnimationViewModel class];
}

+ (UIView *)createViewWithModel:(PicassoModel *)model inPicassoView:(PicassoView *)picassoView {
    PicassoAnimationView *animationView = [[PicassoAnimationView alloc] init];
    [self updateView:animationView withModel:model inPicassoView:picassoView];
    return animationView;
}

+ (void)updateView:(UIView *)view withModel:(PicassoModel *)model inPicassoView:(PicassoView *)picassoView {
    [super updateView:view withModel:model inPicassoView:picassoView];
    if ([view isKindOfClass:[PicassoAnimationView class]]) {
        PicassoAnimationView *animationView = (PicassoAnimationView *)view;
        [animationView updateWithModel:(PicassoAnimationViewModel *)model];
    }
}

@end
