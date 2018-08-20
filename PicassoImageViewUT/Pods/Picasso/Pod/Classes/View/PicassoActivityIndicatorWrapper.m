//
//  PicassoActivityIndicatorWrapper.m
//  clogan
//
//  Created by 纪鹏 on 2017/10/25.
//

#import "PicassoActivityIndicatorWrapper.h"
#import "PicassoActivityIndicatorViewModel.h"

@implementation PicassoActivityIndicatorWrapper

+ (Class)viewClass {
    return [UIActivityIndicatorView class];
}

+ (Class)modelClass {
    return [PicassoActivityIndicatorViewModel class];
}

+ (UIView *)createViewWithModel:(PicassoModel *)model inPicassoView:(PicassoView *)picassoView {
    UIActivityIndicatorView *activityIndicator = [UIActivityIndicatorView new];
    activityIndicator.hidesWhenStopped = NO;
    [self updateView:activityIndicator withModel:model inPicassoView:picassoView];
    return activityIndicator;
}

+ (void)updateView:(UIView *)view withModel:(PicassoModel *)model inPicassoView:(PicassoView *)picassoView {
    [super updateView:view withModel:model inPicassoView:picassoView];
    UIActivityIndicatorView *indicatorView = (UIActivityIndicatorView *)view;
    PicassoActivityIndicatorViewModel *indicatorModel = (PicassoActivityIndicatorViewModel *)model;
    if (indicatorModel.style == 0) {
        indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    } else {
        indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    }
    indicatorView.color = indicatorModel.color;
    if (indicatorModel.animating) {
        [indicatorView startAnimating];
    } else {
        [indicatorView stopAnimating];
    }
}

@end
