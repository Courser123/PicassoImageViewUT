//
//  PicassoAnimationViewModel.m
//  Picasso
//
//  Created by Wang Hualin on 2018/1/26.
//

#import "PicassoAnimationViewModel.h"
#import "PicassoBaseModel+Private.h"
#import "UIColor+pcsUtils.h"
#import <objc/runtime.h>

@implementation PicassoAnimationInfo

- (NSUInteger)hash {
    NSUInteger value = 0;
    
    for (NSString *key in [self propertyKeys]) {
        value ^= [[self valueForKey:key] hash];
    }
    
    return value;
}

- (BOOL)isEqual:(PicassoAnimationInfo *)model {
    if (self == model) return YES;
    if (![model isMemberOfClass:self.class]) return NO;
    
    for (NSString *key in [self propertyKeys]) {
        id selfValue = [self valueForKey:key];
        id modelValue = [model valueForKey:key];
        
        BOOL valuesEqual = ((selfValue == nil && modelValue == nil) || [selfValue isEqual:modelValue]);
        if (!valuesEqual) return NO;
    }
    
    return YES;
}

- (NSSet *)propertyKeys {
    NSMutableSet *keys = [NSMutableSet set];
    unsigned int numberOfProperties = 0;
    objc_property_t *propertyArray = class_copyPropertyList([self class], &numberOfProperties);
    for (NSUInteger i = 0; i < numberOfProperties; i++) {
        objc_property_t property = propertyArray[i];
        NSString *name = [[NSString alloc] initWithUTF8String:property_getName(property)];
        [keys addObject:name];
    }
    free(propertyArray);
    return keys;
}
@end

@implementation PicassoAnimationViewModel

- (void)setModelWithDictionary:(NSDictionary *)dictionaryValue {
    [super setModelWithDictionary:dictionaryValue];
    
    NSArray *animations = dictionaryValue[@"animations"];
    NSMutableArray *animationsData = [NSMutableArray new];
    PicassoAnimationInfo *animationInfo;
    for (NSDictionary *propertyInfo in animations) {
        if ([propertyInfo isKindOfClass:[NSDictionary class]]) {
            animationInfo = [PicassoAnimationInfo new];
            animationInfo.animationType = [propertyInfo[@"property"] integerValue];
            animationInfo.property = [self mappingproperty:@(animationInfo.animationType)];
            switch (animationInfo.animationType) {
                case PicassoAnimatoinTypeRotate:
                case PicassoAnimatoinTypeRotateX:
                case PicassoAnimatoinTypeRotateY:
                    animationInfo.fromValue = [self parseAngle:propertyInfo[@"fromValue"]];
                    animationInfo.toValue = [self parseAngle:propertyInfo[@"toValue"]];
                    break;
                case PicassoAnimatoinTypeBackgroundColor:
                    animationInfo.fromValue = (__bridge id)[self parseColor:propertyInfo[@"fromValue"]];
                    animationInfo.toValue = (__bridge id)[self parseColor:propertyInfo[@"toValue"]];
                    break;
                default:
                    //ts传过来的是string类型，除背景色之外，fromValue和toValue需要转值换成NSNumber类型
                    animationInfo.fromValue = propertyInfo[@"fromValue"] ?@([propertyInfo[@"fromValue"] doubleValue]) : NULL;
                    animationInfo.toValue = propertyInfo[@"toValue"] ?@([propertyInfo[@"toValue"] doubleValue]) : NULL;
                    break;
            }
            animationInfo.duration = [propertyInfo[@"duration"] doubleValue] / 1000;
            animationInfo.delay = [propertyInfo[@"delay"] doubleValue] / 1000;
            animationInfo.timingFunction = [self mappingTimingFunction:propertyInfo[@"timingFunction"]];
            if (animationInfo.property) {
                [animationsData addObject:animationInfo];
            }
        }
    }
    self.animations = [animationsData copy];
}

- (NSString *)mappingproperty:(NSNumber *)property {
    if (property) {
        static NSDictionary *mapping;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            mapping = @{
                        @(PicassoAnimatoinTypeScaleX) : @"transform.scale.x",
                        @(PicassoAnimatoinTypeScaleY) : @"transform.scale.y",
                        @(PicassoAnimatoinTypeTranslateX) : @"transform.translation.x",
                        @(PicassoAnimatoinTypeTranslateY) : @"transform.translation.y",
                        @(PicassoAnimatoinTypeRotate) : @"transform.rotation",
                        @(PicassoAnimatoinTypeRotateX) : @"transform.rotation.x",
                        @(PicassoAnimatoinTypeRotateY) : @"transform.rotation.y",
                        @(PicassoAnimatoinTypeOpacity) : @"opacity",
                        @(PicassoAnimatoinTypeBackgroundColor) : @"backgroundColor"
                        };
        });

        NSString *keyPath = mapping[property];
        if (keyPath.length > 0) {
            return keyPath;
        } else {
            return nil;
        }
    } else {
        return nil;
    }
}

- (NSNumber *)parseAngle:(id)value {
    if (!value) {
        return nil;
    }
    double angle = [value doubleValue];
    return @(angle * M_PI / 180.0);
}

- (CGColorRef)parseColor:(id)value {
    if (![value isKindOfClass:[NSString class]]) {
        return nil;
    }
    
    UIColor *color = [UIColor pcsColorWithHexString:value];
    return [color CGColor];
}

- (CAMediaTimingFunction *)mappingTimingFunction:(NSNumber *)value {
    if (![value isKindOfClass:[NSNumber class]]) {
        return nil;
    }
    
    static NSDictionary *mapping;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mapping = @{
                    @(PicassoTimingFunctionLinear): kCAMediaTimingFunctionLinear,
                    @(PicassoTimingFunctionEaseIn): kCAMediaTimingFunctionEaseIn,
                    @(PicassoTimingFunctionEaseOut): kCAMediaTimingFunctionEaseOut,
                    @(PicassoTimingFunctionEaseInOut): kCAMediaTimingFunctionEaseInEaseOut
                    };
    });
    
    NSString *timingFunction = mapping[value];
    if ([timingFunction length] > 0) {
        return [CAMediaTimingFunction functionWithName:timingFunction];
    }
    
    return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
}

@end
