//
//  PicassoBaseHelper.m
//  Pods
//
//  Created by 薛琳 on 17/5/9.
//
//

#import "PicassoBaseHelper.h"

@implementation PicassoBaseHelper

+ (BOOL)needChangeHTTP2HTTPS {
    static BOOL needChange;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        needChange = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"NSAppTransportSecurity"] objectForKey:@"NSAllowsArbitraryLoads"] ? ![[[[[NSBundle mainBundle] infoDictionary] objectForKey:@"NSAppTransportSecurity"] objectForKey:@"NSAllowsArbitraryLoads"] boolValue] : YES;
    });
    return needChange;
}

+ (NSString *)translatedUrlString:(NSString *)str {
    if (!str.length) return str;
    if (![self needChangeHTTP2HTTPS]) return str;
    NSRange schemeMarkerRange = [str rangeOfString:@"://"];
    if (schemeMarkerRange.location == NSNotFound) return str;
    NSString *scheme = [str substringWithRange:NSMakeRange(0, schemeMarkerRange.location)];
    if (!([scheme compare:@"http" options:NSCaseInsensitiveSearch] == NSOrderedSame)) return str;
    return [str stringByReplacingCharactersInRange:NSMakeRange(0, schemeMarkerRange.location) withString:@"https"];
}

+ (NSURL *)translatedUrl:(NSURL *)url {
    if ([url isFileURL]) return url;
    if (![self needChangeHTTP2HTTPS]) return url;
    NSString *urlString = [self translatedUrlString:url.absoluteString];
    return [NSURL URLWithString:urlString];
}

@end
