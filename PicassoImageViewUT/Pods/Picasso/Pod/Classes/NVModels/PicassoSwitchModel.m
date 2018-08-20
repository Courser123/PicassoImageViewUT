//
//  PicassoSwitchModel.m
//  Picasso
//
//  Created by pengfei.zhou on 2018/4/26.
//

#import "PicassoSwitchModel.h"
#import "PicassoBaseModel+Private.h"
#import "UIColor+pcsUtils.h"

@implementation PicassoSwitchModel

- (void)setModelWithDictionary:(NSDictionary *)dictionaryValue {
    [super setModelWithDictionary:dictionaryValue];
    self.on = [dictionaryValue[@"on"] boolValue];
    NSString *tintColorHex = [dictionaryValue objectForKey:@"tintColor"];
    self.tintColor = tintColorHex.length ? [UIColor pcsColorWithHexString:tintColorHex] : nil;
    NSString *onTintColorHex = [dictionaryValue objectForKey:@"onTintColor"];
    self.onTintColor = onTintColorHex.length ? [UIColor pcsColorWithHexString:onTintColorHex] : nil;
    NSString *thumbTintColorHex = [dictionaryValue objectForKey:@"thumbTintColor"];
    self.thumbTintColor = thumbTintColorHex.length ? [UIColor pcsColorWithHexString:thumbTintColorHex] : nil;
}

@end
