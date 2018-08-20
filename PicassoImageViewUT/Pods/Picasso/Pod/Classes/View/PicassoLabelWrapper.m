//
//  PicassoLabelModule.m
//  Pods
//
//  Created by 纪鹏 on 2017/6/6.
//
//

#import "PicassoLabelWrapper.h"
#import "PicassoLabelModel.h"
#import "PicassoLabel.h"

@implementation PicassoLabelWrapper

+ (Class)viewClass {
    return [PicassoLabel class];
}

+ (Class)modelClass {
    return [PicassoLabelModel class];
}

+ (UIView *)createViewWithModel:(PicassoModel *)model inPicassoView:(PicassoView *)picassoView {
    PicassoLabel *label = [PicassoLabel new];
    [self updateView:label withModel:model inPicassoView:picassoView];
    return label;
}

+ (void)updateView:(UIView *)view withModel:(PicassoModel *)model inPicassoView:(PicassoView *)picassoView {
    [super updateView:view withModel:model inPicassoView:picassoView];
    if ([view isKindOfClass:[PicassoLabel class]]) {
        PicassoLabel *label = (PicassoLabel *)view;
        [label updateWithModel:(PicassoLabelModel *)model];
    }
}

@end
