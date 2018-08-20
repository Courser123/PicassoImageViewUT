//
//  UIColor+pcsUtils.m
//  Pods
//
//  Created by 纪鹏 on 2017/1/24.
//
//

#import "UIColor+pcsUtils.h"

@implementation UIColor (pcsUtils)

+(nonnull UIColor *)pcsColorWithHexString:(nullable NSString *)str {
    if (!([str hasPrefix:@"#"] && (str.length == 7 || str.length == 9))) {
        return [UIColor whiteColor];
    }
    
    NSString *cString = [str substringFromIndex:1];
    if (cString.length == 6) {
        cString = [@"ff" stringByAppendingString:cString];
    }
    
    uint32_t rgba;
    NSScanner *scanner = [NSScanner scannerWithString:[cString lowercaseString]];
    [scanner scanHexInt:&rgba];
    CGFloat alpha = ((rgba >> 24) & 0xFF) / 255.0f;
    CGFloat red = ((rgba >> 16) & 0xFF) / 255.0f;
    CGFloat greed = ((rgba >> 8) & 0xFF) / 255.0f;
    CGFloat blue = (rgba & 0xFF) / 255.0f;
    
    return [UIColor colorWithRed:red green:greed blue:blue alpha:alpha];
}

@end
