//
//  PicassoActivityIndicatorViewModel.m
//  clogan
//
//  Created by 纪鹏 on 2017/10/25.
//

#import "PicassoActivityIndicatorViewModel.h"
#import "PicassoBaseModel+Private.h"
#import "UIColor+pcsUtils.h"

@implementation PicassoActivityIndicatorViewModel

- (void)setModelWithDictionary:(NSDictionary *)dictionaryValue {
    [super setModelWithDictionary:dictionaryValue];
    self.animating = [dictionaryValue[@"animating"] boolValue];
    NSString *colorStr = dictionaryValue[@"color"];
    if (colorStr.length) {
        self.color = [UIColor pcsColorWithHexString:colorStr];
    } else {
        self.color = [UIColor grayColor];
    }
    self.style = [dictionaryValue[@"style"] integerValue];
}

@end
