//
//  PicassoAnimationView.m
//  Picasso
//
//  Created by Hualin Wang on 2018/3/13.
//

#import "PicassoAnimationView.h"
#import "PicassoAnimationViewModel.h"
#import "PicassoHostManager.h"
#import "PicassoVCHost.h"
#import "EXTScope.h"

@interface PicassoAnimationView()

@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, assign) BOOL isAnimating;
@property (nonatomic, copy) NSString *viewId;
@property (nonatomic, strong) PicassoAnimationViewModel *animationModel;

@end

@implementation PicassoAnimationView

//执行过动画以后，需要保留当前动画后视图的Frame
- (void)setFrame:(CGRect)frame {
    if (CATransform3DEqualToTransform(self.layer.transform, CATransform3DIdentity)) {
        [super setFrame:frame];
    }
}

- (NSString *)buildAnimationKey {
    self.index = self.index % (1024*1024);
    self.index++;
    return [NSString stringWithFormat:@"%@", @(self.index)];
}

- (void)updateWithModel:(PicassoAnimationViewModel *)model {
    self.viewId = model.viewId;
    if ([model.animations isEqualToArray:self.animationModel.animations]) {
        return;
    }
    self.animationModel = model;
    if (model.animations.count == 0 || self.isAnimating) {
        [self.layer removeAllAnimations];
        self.layer.transform = CATransform3DIdentity;
        if (model.animations.count == 0) {
            return;
        }
    }
    self.isAnimating = YES;
    __block CGColorRef backgroundColor = NULL;
    __block CATransform3D transform = CATransform3DIdentity;
    __block CGFloat opacity = CGFLOAT_MIN;
    
    @weakify(self)
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        @strongify(self)
        NSString *animaitonAction = @"onCompletion";
        if ([self.animationModel.actions indexOfObject:animaitonAction] != NSNotFound) {
            PicassoHost *host = [PicassoHostManager hostForId:self.animationModel.hostId];
            if ([host isKindOfClass:[PicassoVCHost class]]) {
                PicassoVCHost *vcHost = (PicassoVCHost *)host;
                [vcHost dispatchViewEventWithViewId:self.viewId action:animaitonAction params:nil];
            }
        }
        
        if (backgroundColor) {
            self.layer.backgroundColor = backgroundColor;
        }
        if (opacity > CGFLOAT_MIN) {
            self.layer.opacity = opacity;
        }
        if (!CATransform3DEqualToTransform(transform, CATransform3DIdentity)) {
            self.layer.transform = transform;
        }
        self.isAnimating = NO;
    }];
    
    for (PicassoAnimationInfo *animationInfo in self.animationModel.animations) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:animationInfo.property];
        animation.fromValue = animationInfo.fromValue;
        animation.toValue = animationInfo.toValue;
        animation.duration = animationInfo.duration;
        animation.beginTime = CACurrentMediaTime() + animationInfo.delay;
        animation.timingFunction = animationInfo.timingFunction;
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
        [self.layer addAnimation:animation forKey:[self buildAnimationKey]];
        
        if (animationInfo.animationType == PicassoAnimatoinTypeBackgroundColor) {
            backgroundColor = (__bridge CGColorRef)animationInfo.toValue;
        } else if (animationInfo.animationType == PicassoAnimatoinTypeOpacity) {
            opacity = [animationInfo.toValue floatValue];
        } else {
            transform = [self handleTransform:animationInfo currentTransform:transform];
        }
    }
    [CATransaction commit];
}

- (CATransform3D)handleTransform:(PicassoAnimationInfo *)animationInfo currentTransform:(CATransform3D)currentTransform {
    if (![animationInfo.toValue isKindOfClass:[NSNumber class]]) {
        return currentTransform;
    }
    CGFloat toValue = [animationInfo.toValue floatValue];
    switch (animationInfo.animationType) {
        case PicassoAnimatoinTypeScaleX:
            currentTransform = CATransform3DScale(currentTransform, toValue, 1.0, 1.0);
            break;
        case PicassoAnimatoinTypeScaleY:
            currentTransform = CATransform3DScale(currentTransform, 1.0, toValue, 1.0);
            break;
        case PicassoAnimatoinTypeTranslateX:
            currentTransform = CATransform3DTranslate(currentTransform, toValue, 0, 0);
            break;
        case PicassoAnimatoinTypeTranslateY:
            currentTransform = CATransform3DTranslate(currentTransform, 0, toValue, 0);
            break;
        case PicassoAnimatoinTypeRotate:
            currentTransform = CATransform3DRotate(currentTransform, toValue, 0, 0, 1);
            break;
        case PicassoAnimatoinTypeRotateX:
            currentTransform = CATransform3DRotate(currentTransform, toValue, 1, 0, 0);
            break;
        case PicassoAnimatoinTypeRotateY:
            currentTransform = CATransform3DRotate(currentTransform, toValue, 0, 1, 0);
            break;
        default:
            break;
    }
    return currentTransform;
}

@end
