//
//  PicassoView.h
//  Pods
//
//  Created by Stephen Zhang on 16/7/18.
//
//

#import "PicassoNotificationCenter.h"
#import "PicassoGroupView.h"

@class PicassoView;
@class PicassoInput;
@class PicassoModel;
@class PicassoViewInput;

@interface PicassoView : PicassoGroupView

@property (nonatomic, strong, readonly) PicassoNotificationCenter *defaultCenter;

//初始化方法
+ (PicassoView *)createView:(PicassoInput *)input;

//绘制方法
- (void)painting:(PicassoInput *)input;

//获取view高度
+ (CGFloat)getViewHeight:(PicassoInput *)input;
//获取view宽度
+ (CGFloat)getViewWidth:(PicassoInput *)input;

// UT
- (UIView *)viewWithPTag:(NSString *)pTag;

- (void)modelPainting:(PicassoModel *)model;


/************** PicassoViewInput接口 ******************/
- (void)paintingInput:(PicassoViewInput *)input;

+ (CGFloat)getHeight:(PicassoViewInput *)input;

+ (CGFloat)getWidth:(PicassoViewInput *)input;


@end
