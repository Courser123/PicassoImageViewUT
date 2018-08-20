//
//  UIColor+pcsUtils.h
//  Pods
//
//  Created by 纪鹏 on 2017/1/24.
//
//

#import <UIKit/UIKit.h>

@interface UIColor (pcsUtils)

/** 格式 "#abcdef" 或者 "#ffabcdef" */
+(nonnull UIColor *)pcsColorWithHexString:(nullable NSString *)str;

@end
