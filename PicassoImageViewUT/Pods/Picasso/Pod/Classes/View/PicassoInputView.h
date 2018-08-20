//
//  PicassoInputView.h
//  Pods
//
//  Created by game3108 on 2017/9/19.
//
//

#import <UIKit/UIKit.h>

@class PicassoInputViewModel;
@class PicassoView;
@interface PicassoInputView : UIView
- (instancetype)initWithModel:(PicassoInputViewModel *)model;
- (void)updateViewWithModel:(PicassoInputViewModel *)model inPicassoView:(PicassoView *)picassoView;
//获取实际接受文本输入的视图，UITextField或UITextView
- (UIView <UITextInput> *)inputInstanceView;
@end
