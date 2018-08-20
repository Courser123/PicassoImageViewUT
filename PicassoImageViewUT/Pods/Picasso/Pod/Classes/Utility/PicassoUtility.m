//
//  PicassoUtility.m
//  Picasso
//
//  Created by xiebohui on 14/12/2016.
//  Copyright © 2016 huang.zhang. All rights reserved.
//

#import "PicassoUtility.h"
#import <sys/utsname.h>
#import "PicassoAppConfiguration.h"
#import <JavaScriptCore/JavaScriptCore.h>

#if defined(TEST) || defined(DEBUG)
static BOOL PICASSOENVIRNOMENT = YES;
#else
static BOOL PICASSOENVIRNOMENT = NO;
#endif

@interface PicassoUtility()
@end

@implementation PicassoUtility

+ (NSDictionary *)getEnvironment {
    NSString *platform = @"iOS";
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion] ?: @"";
    NSString *picassoVersion = @"1.0.0";
    NSString *machine = [self deviceName] ? : @"";
    NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] ? : @"";
    CGFloat deviceWidth = [[UIScreen mainScreen] bounds].size.width;
    CGFloat deviceHeight = [[UIScreen mainScreen] bounds].size.height;
    CGFloat scale = [[UIScreen mainScreen] scale];
    UIFont *font = [UIFont systemFontOfSize:1.0f];

    NSDictionary *data = @{
                            @"appId"            :[self appId],
                            @"platform"         :platform,
                            @"osVersion"        :systemVersion,
                            @"picassoVersion"   :picassoVersion,
                            @"deviceModel"      :machine,
                            @"appVersion"       :appVersion,
                            @"deviceWidth"      :@(deviceWidth),
                            @"deviceHeight"     :@(deviceHeight),
                            @"scale"            :@(scale),
                            @"isDebug"          :@(PICASSOENVIRNOMENT),
                            @"fontLineHeight"   :@(font.lineHeight),
                            @"fontDescender"    :@(font.descender)
                            };
    return data;
}

+ (NSNumber *)appId {
    return [PicassoAppConfiguration instance].appId?:@(-1);
}

+ (BOOL)isDebug {
    return PICASSOENVIRNOMENT;
}

+ (NSString *)unionId {
    PicassoGetUnionIdBlock block = [PicassoAppConfiguration instance].unionIdBlock;
    if (block) {
        NSString *unionId = block();
        if (unionId && [unionId isKindOfClass:[NSString class]]) return unionId;
    }
    return @"";
}

+ (NSString *)deviceName
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *machine = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    return machine;
}

+ (nonnull NSString *)errorStringWithException:(JSValue *_Nonnull)exception {
    NSString *logStr = [NSString stringWithFormat:@"PicassoJSObject解析失败[source:%@, line:%@, column:%@]：%@\n%@", exception[@"sourceURL"], exception[@"line"], exception[@"column"], exception, [exception[@"stack"] toObject]];
    return logStr;
}

@end
