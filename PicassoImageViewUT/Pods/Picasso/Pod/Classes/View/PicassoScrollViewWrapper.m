//
//  PicassoScrollViewWrapper.m
//  Pods
//
//  Created by 纪鹏 on 2017/6/19.
//
//

#import "PicassoScrollViewWrapper.h"
#import "PicassoScrollViewModel.h"
#import "PicassoScrollView.h"

@implementation PicassoScrollViewWrapper

+ (Class)viewClass {
    return [PicassoScrollView class];
}

+ (Class)modelClass {
    return [PicassoScrollViewModel class];
}

+ (UIView *)createViewWithModel:(PicassoModel *)model inPicassoView:(PicassoView *)picassoView {
    PicassoScrollView *scrollview = [[PicassoScrollView alloc] initWithModel:(PicassoScrollViewModel *)model];
    [self updateView:scrollview withModel:model inPicassoView:picassoView];
    return scrollview;
}

+ (void)updateView:(UIView *)view withModel:(PicassoModel *)model inPicassoView:(PicassoView *)picassoView {
    [super updateView:view withModel:model inPicassoView:picassoView];
    if ([view isKindOfClass:[PicassoScrollView class]]) {
        [(PicassoScrollView *)view updateWithModel:(PicassoScrollViewModel *)model];
    }
}

@end
