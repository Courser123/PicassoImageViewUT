//
//  PicassoImageViewWrapper.m
//  Picasso
//
//  Created by xiebohui on 24/11/2016.
//  Copyright © 2016 xiebohui. All rights reserved.
//

#import "PicassoImageViewWrapper.h"
#import "PicassoImageViewModel.h"
#import "PicassoImageView.h"

@implementation PicassoImageViewWrapper

+ (Class)viewClass {
    return [PicassoImageView class];
}

+ (Class)modelClass {
    return [PicassoImageViewModel class];
}

+ (UIView *)createViewWithModel:(PicassoModel *)model inPicassoView:(PicassoView *)picassoView {
    PicassoImageView *imageView = [PicassoImageView new];
    [self updateView:imageView withModel:model inPicassoView:picassoView];
    return imageView;
}

+ (void)updateView:(UIView *)view withModel:(PicassoModel *)model inPicassoView:(PicassoView *)picassoView {
    [super updateView:view withModel:model inPicassoView:picassoView];
    if ([view isKindOfClass:[PicassoImageView class]]) {
        PicassoImageView *imageView = (PicassoImageView *)view;
        [imageView updateWithModel:(PicassoImageViewModel *)model];
    }
}


@end
