//
//  PicassoInputViewWrapper.m
//  Pods
//
//  Created by game3108 on 2017/9/19.
//
//

#import "PicassoInputViewWrapper.h"
#import "PicassoInputViewModel.h"
#import "PicassoInputView.h"

@interface PicassoInputViewWrapper()

@end

@implementation PicassoInputViewWrapper

+ (Class)viewClass {
    return [PicassoInputView class];
}

+ (Class)modelClass {
    return [PicassoInputViewModel class];
}

+ (UIView *)createViewWithModel:(PicassoModel *)model inPicassoView:(PicassoView *)picassoView {
    PicassoInputView *inputView = [[PicassoInputView alloc] initWithModel:(PicassoInputViewModel *)model];
    [self updateView:inputView withModel:model inPicassoView:picassoView];
    return inputView;
}

+ (void)updateView:(UIView *)view withModel:(PicassoModel *)model inPicassoView:(PicassoView *)picassoView {
    [super updateView:view withModel:model inPicassoView:picassoView];
    if ([view isKindOfClass:[PicassoInputView class]]) {
        PicassoInputView *inputView = (PicassoInputView *)view;
        [inputView updateViewWithModel:(PicassoInputViewModel *)model inPicassoView:picassoView];
    }
}

@end
