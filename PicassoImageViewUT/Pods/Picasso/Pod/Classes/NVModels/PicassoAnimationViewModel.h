//
//  PicassoAnimationViewModel.h
//  Picasso
//
//  Created by Wang Hualin on 2018/1/26.
//

#import "PicassoViewModel.h"

typedef NS_ENUM(NSInteger, PicassoAnimatoinType) {
    PicassoAnimatoinTypeNone,
    PicassoAnimatoinTypeScaleX,
    PicassoAnimatoinTypeScaleY,
    PicassoAnimatoinTypeTranslateX,
    PicassoAnimatoinTypeTranslateY,
    PicassoAnimatoinTypeRotate,
    PicassoAnimatoinTypeRotateX,
    PicassoAnimatoinTypeRotateY,
    PicassoAnimatoinTypeBackgroundColor,
    PicassoAnimatoinTypeOpacity
};

typedef NS_ENUM(NSInteger, PicassoTimingFunction) {
    PicassoTimingFunctionLinear,
    PicassoTimingFunctionEaseIn,
    PicassoTimingFunctionEaseOut,
    PicassoTimingFunctionEaseInOut
};

@interface PicassoAnimationInfo : NSObject

@property (nonatomic, assign) PicassoAnimatoinType animationType;
@property (nonatomic, copy) NSString *property;
@property (nonatomic, strong) id fromValue;
@property (nonatomic, strong) id toValue;
@property (nonatomic, assign) double duration;
@property (nonatomic, assign) double delay;
@property (nonatomic, strong) CAMediaTimingFunction *timingFunction;

@end

@interface PicassoAnimationViewModel : PicassoViewModel

@property (nonatomic, strong) NSArray<PicassoAnimationInfo *> *animations;

@end
