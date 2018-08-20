//
//  PicassoStatusBarModule.m
//  Picasso
//
//  Created by 纪鹏 on 2017/12/8.
//

#import "PicassoStatusBarModule.h"
#import "PicassoThreadManager.h"

@implementation PicassoStatusBarModule

PCS_EXPORT_METHOD(@selector(setHidden:))
PCS_EXPORT_METHOD(@selector(setStatusBarStyle:))

- (void)setHidden:(NSDictionary *)params {
    BOOL hidden = [params[@"hidden"] boolValue];
    PCSRunOnMainThread(^{
        [UIApplication sharedApplication].statusBarHidden = hidden;
    });
}

- (void)setStatusBarStyle:(NSDictionary *)params {
    UIStatusBarStyle style = [params[@"style"] integerValue];
    PCSRunOnMainThread(^{
        [UIApplication sharedApplication].statusBarStyle = style;
    });
}

@end
