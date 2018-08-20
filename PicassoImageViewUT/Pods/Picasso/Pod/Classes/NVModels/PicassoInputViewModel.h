//
//  PicassoInputViewModel.h
//  Pods
//
//  Created by game3108 on 2017/9/19.
//
//

#import "PicassoModel.h"

@interface PicassoInputViewModel : PicassoModel
@property (nonatomic, copy) NSString *hint;
@property (nonatomic, strong) UIColor *hintColor;
@property (nonatomic, assign) NSInteger inputType;
@property (nonatomic, assign) NSInteger returnAction;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, assign) BOOL multiline;
@property (nonatomic, assign) BOOL autoFocus;
@property (nonatomic, assign) BOOL secureTextEntry;
@property (nonatomic, assign) NSInteger inputAlignment;
@property (nonatomic, assign) NSInteger maxLength;
/// 当inputView被键盘遮挡的时候，是否自动调整inputView的位置，ts 侧默认值：true
@property (nonatomic, assign) BOOL autoAdjust;
@end
