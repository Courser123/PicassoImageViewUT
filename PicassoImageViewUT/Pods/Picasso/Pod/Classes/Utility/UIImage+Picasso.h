//
//  UIImage+Picasso.h
//  Picasso
//
//  Created by xiebohui on 18/10/2016.
//  Copyright © 2016 xiebohui. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Picasso)

+ (UIImage *)pcsImageWithColor:(UIColor *)color;

+ (UIImage *)pcs_imageWithBase64:(NSString *)base64Str;

@end
