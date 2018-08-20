//
//  UIImage+pcs_gradientColor.m
//  Picasso
//
//  Created by 纪鹏 on 2018/1/10.
//

#import "UIImage+pcs_gradientColor.h"

@implementation UIImage (pcs_gradientColor)

+ (UIImage *)pcs_gradientColorImageFromColors:(NSArray*)colors startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint imgSize:(CGSize)imgSize {
    UIGraphicsBeginImageContextWithOptions(imgSize, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGColorSpaceRef colorSpace = CGColorGetColorSpace((CGColorRef)colors.lastObject);
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)colors, NULL);
    CGPoint start = (CGPoint){startPoint.x * imgSize.width, startPoint.y * imgSize.height};
    CGPoint end = (CGPoint){endPoint.x * imgSize.width, endPoint.y * imgSize.height};
    CGContextDrawLinearGradient(context, gradient, start, end, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    CGGradientRelease(gradient);
    CGContextRestoreGState(context);
    CGColorSpaceRelease(colorSpace);
    UIGraphicsEndImageContext();
    return image;
}

@end
