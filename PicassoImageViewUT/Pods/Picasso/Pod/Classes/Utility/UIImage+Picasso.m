//
//  UIImage+Picasso.m
//  Picasso
//
//  Created by xiebohui on 18/10/2016.
//  Copyright © 2016 xiebohui. All rights reserved.
//

#import "UIImage+Picasso.h"

@implementation UIImage (Picasso)

+ (UIImage *)pcsImageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)pcs_imageWithBase64:(NSString *)base64Str {
    if (YES == [base64Str hasPrefix:@"data:image"]) {
        base64Str = [base64Str componentsSeparatedByString:@","].lastObject;
    }
    NSData *imageData = [[NSData alloc] initWithBase64EncodedString:base64Str options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [UIImage imageWithData:imageData];
}

@end
