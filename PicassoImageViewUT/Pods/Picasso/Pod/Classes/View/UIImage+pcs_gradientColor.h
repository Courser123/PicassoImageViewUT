//
//  UIImage+pcs_gradientColor.h
//  Picasso
//
//  Created by 纪鹏 on 2018/1/10.
//

#import <UIKit/UIKit.h>

@interface UIImage (pcs_gradientColor)

+ (UIImage *)pcs_gradientColorImageFromColors:(NSArray*)colors startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint imgSize:(CGSize)imgSize;

@end
