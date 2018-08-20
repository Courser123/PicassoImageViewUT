//
//  PicassoInputViewModel.m
//  Pods
//
//  Created by game3108 on 2017/9/19.
//
//

#import "PicassoInputViewModel.h"
#import "PicassoBaseModel+Private.h"
#import "UIColor+pcsUtils.h"

@implementation PicassoInputViewModel

- (void)setModelWithDictionary:(NSDictionary *)dictionaryValue {
    [super setModelWithDictionary:dictionaryValue];
    
    self.hint = [dictionaryValue objectForKey:@"hint"];
    NSString *hintColor = [dictionaryValue objectForKey:@"hintColor"];
    if (hintColor.length) {
        self.hintColor = [UIColor pcsColorWithHexString:hintColor];
    }
    
    self.inputType = [[dictionaryValue objectForKey:@"inputType"] integerValue];
    self.returnAction = [[dictionaryValue objectForKey:@"returnAction"] integerValue];
    self.inputAlignment = [[dictionaryValue objectForKey:@"inputAlignment"] integerValue];
    self.maxLength = [[dictionaryValue objectForKey:@"maxLength"] integerValue];
    
    id text = dictionaryValue[@"text"];
    if ([text isKindOfClass:[NSString class]]) {
        self.text = text;
    }
    NSString *colorHex = [dictionaryValue objectForKey:@"textColor"];
    if (colorHex.length > 0) {
        self.textColor = [UIColor pcsColorWithHexString:colorHex];
    }
    
    CGFloat textSize = [[dictionaryValue objectForKey:@"textSize"] floatValue];
    self.font = [UIFont systemFontOfSize:textSize > 0 ? textSize : [UIFont systemFontSize]];
    
    self.multiline = [[dictionaryValue objectForKey:@"multiline"] boolValue];
    self.autoFocus = [dictionaryValue[@"autoFocus"] boolValue];
    self.secureTextEntry = [dictionaryValue[@"secureTextEntry"] boolValue];
    self.autoAdjust = [dictionaryValue[@"autoAdjust"] boolValue];
}

@end
