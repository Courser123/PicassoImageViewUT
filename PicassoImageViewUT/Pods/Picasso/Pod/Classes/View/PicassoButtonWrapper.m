//
//  PicassoButtonWrapper.m
//  Picasso
//
//  Created by xiebohui on 24/11/2016.
//  Copyright © 2016 xiebohui. All rights reserved.
//

#import "PicassoButtonWrapper.h"
#import "PicassoButtonModel.h"
#import "PicassoButton.h"

@implementation PicassoButtonWrapper

+ (Class)viewClass {
    return [PicassoButton class];
}

+ (Class)modelClass {
    return [PicassoButtonModel class];
}

+ (UIView *)createViewWithModel:(PicassoModel *)model inPicassoView:(PicassoView *)picassoView {
    PicassoButton *button = [[PicassoButton alloc] init];
    [self updateView:button withModel:model inPicassoView:picassoView];
    return button;
}

+ (void)updateView:(UIView *)view withModel:(PicassoModel *)model inPicassoView:(PicassoView *)picassoView {
    [super updateView:view withModel:model inPicassoView:picassoView];
    if ([view isKindOfClass:[PicassoButton class]]) {
        PicassoButton *button = (PicassoButton *)view;
        [button updateViewWithModel:(PicassoButtonModel *)model inPicassoView:picassoView];
    }
}

@end
