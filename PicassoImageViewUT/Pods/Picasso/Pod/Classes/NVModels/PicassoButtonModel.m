//
//  PicassoButtonModel.m
//  Picasso
//
//  Created by 纪鹏 on 2018/5/8.
//

#import "PicassoButtonModel.h"
#import "PicassoBaseModel+Private.h"
#import "UIImage+Picasso.h"
#import "UIColor+pcsUtils.h"

@implementation PicassoButtonModel

- (void)setModelWithDictionary:(NSDictionary *)dictionaryValue {
    [super setModelWithDictionary:dictionaryValue];
    self.schema = [dictionaryValue objectForKey:@"schema"];
    self.data = [dictionaryValue objectForKey:@"data"];
    
    NSString *clickedColorHex = [dictionaryValue objectForKey:@"clickedColor"];
    if (clickedColorHex.length) {
        self.clickedImage = [UIImage pcsImageWithColor:[UIColor pcsColorWithHexString:clickedColorHex]];
    }
    if (self.backgroundColor) {
        self.normalImage = [UIImage pcsImageWithColor:self.backgroundColor];
    }
}

@end
