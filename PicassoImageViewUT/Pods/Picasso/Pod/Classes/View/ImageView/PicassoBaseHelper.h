//
//  PicassoBaseHelper.h
//  Pods
//
//  Created by 薛琳 on 17/5/9.
//
//

#import <Foundation/Foundation.h>

@interface PicassoBaseHelper : NSObject

+ (BOOL)needChangeHTTP2HTTPS;
+ (NSString *)translatedUrlString:(NSString *)str;
+ (NSURL *)translatedUrl:(NSURL *)url;

@end
