//
//  PicassoLabelModel.m
//  Picasso
//
//  Created by 纪鹏 on 2018/5/8.
//

#import "PicassoLabelModel.h"
#import "UIColor+pcsUtils.h"
#import "PicassoBaseModel+Private.h"
#import "PCSJsonLabelStyleModel.h"
#import "PCSJsonLabel.h"

@interface PicassoLabelModel ()
@property (nonatomic, assign) BOOL needSizeToFit;
@property (nonatomic, copy) NSString *sizeKey;
@end

@implementation PicassoLabelModel

- (void)setModelWithDictionary:(NSDictionary *)dictionaryValue {
    [super setModelWithDictionary:dictionaryValue];
    self.numberOfLines = [dictionaryValue[@"numberOfLines"] integerValue];
    self.lineBreakMode = [dictionaryValue[@"lineBreakMode"] integerValue];
    self.textAlignment = [dictionaryValue[@"textAlignment"] integerValue];
    self.linespacing = [dictionaryValue[@"linespacing"] floatValue];
    self.underline = [dictionaryValue[@"underline"] boolValue];
    self.strikethrough = [dictionaryValue[@"strikethrough"] boolValue];
    
    NSString *colorHex = dictionaryValue[@"textColor"];
    if (colorHex.length > 0) {
        self.textColor = [UIColor pcsColorWithHexString:colorHex];
    }
    
    NSString *highlightedBgColorHex = dictionaryValue[@"highlightedBgColor"];
    if (highlightedBgColorHex.length > 0) {
        self.highlightedBgColor = [UIColor pcsColorWithHexString:highlightedBgColorHex];
    }
    
    CGFloat textSize = [dictionaryValue[@"textSize"] floatValue];
    if (isnan(textSize)) {
        textSize = 0;
    }
    NSInteger fontStyle = [dictionaryValue[@"fontStyle"] integerValue];
    self.font = [self modelFontWithTextSize:textSize fontName:dictionaryValue[@"fontName"] fontStyle:fontStyle];
    
    self.text = dictionaryValue[@"text"];
    
    self.jsonModel = [PCSJsonLabelStyleModel modelWithJsonString:self.text];
    if (!self.jsonModel && (self.strikethrough || self.underline || self.linespacing > CGFLOAT_MIN)) {
        PCSJsonLabelStyleModel *labelModel = [[PCSJsonLabelStyleModel alloc] init];
        PCSJsonLabelContentStyleModel *contentModel = [[PCSJsonLabelContentStyleModel alloc] init];
        contentModel.text = self.text;
        contentModel.underline = @(self.underline);
        contentModel.strikethrough = @(self.strikethrough);
        labelModel.linespacing = @(self.linespacing);
        labelModel.alignment = self.textAlignment;
        labelModel.richtextlist = @[contentModel];
        self.jsonModel = labelModel;
    }
    NSLineBreakMode linebreakMode = NSLineBreakByTruncatingTail;
    switch (self.lineBreakMode) {
        case 0:
        {
            linebreakMode = NSLineBreakByWordWrapping;
            break;
        }
        case 1:
        {
            linebreakMode = NSLineBreakByCharWrapping;
            break;
        }
        default:
            break;
    }
    self.attributedText = [PCSJsonLabel getAttributedTextWithModel:self.jsonModel font:self.font renderSize:[self renderSizeForWidth:self.width maxLine:self.numberOfLines] linebreakMode:linebreakMode];
    
    NSString *textShadowColorStr = dictionaryValue[@"textShadowColor"];
    if (textShadowColorStr.length) {
        self.textShadowColor = [UIColor pcsColorWithHexString:textShadowColorStr];
    }
    self.textShadowRadius = [dictionaryValue[@"textShadowRadius"] doubleValue];
    self.textShadowOffset = CGSizeMake([dictionaryValue[@"textShadowOffsetX"] doubleValue], [dictionaryValue[@"textShadowOffsetY"] doubleValue]);
    
    NSShadow *textShadow = nil;
    if (self.textShadowRadius > 0 || !CGSizeEqualToSize(self.textShadowOffset, CGSizeZero)) {
        textShadow = [[NSShadow alloc] init];
        if (self.textShadowColor) {
            textShadow.shadowColor = self.textShadowColor;
        }
        textShadow.shadowOffset = self.textShadowOffset;
        textShadow.shadowBlurRadius = self.textShadowRadius;
    }
    if (textShadow) {
        if (self.attributedText) {
            NSMutableAttributedString *attributeString = [self.attributedText mutableCopy];
            [attributeString addAttribute:NSShadowAttributeName value:textShadow range:NSMakeRange(0, self.attributedText.length)];
            self.attributedText = [attributeString copy];
        } else {
            self.attributedText = [[NSAttributedString alloc] initWithString:self.text attributes:@{NSShadowAttributeName: textShadow}];
        }
    }
    
    self.needSizeToFit = [dictionaryValue[@"needSizeToFit"] boolValue];
    self.sizeKey = dictionaryValue[@"sizeKey"];
}

- (UIFont *)modelFontWithTextSize:(CGFloat)textSize fontName:(NSString *)fontName fontStyle:(NSInteger)fontStyle {
    UIFont *labelFont = nil;
    if (fontName.length > 0) {
        labelFont = [UIFont fontWithName:fontName size:(textSize > 0 ? textSize : [UIFont systemFontSize])];
    } else {
        labelFont = [UIFont systemFontOfSize:(textSize > 0 ? textSize : [UIFont systemFontSize])];
    }
    if (fontStyle >= 1 && fontStyle <= 3) {
        UIFontDescriptor *fontDescriptor = [self fontDescritorForCur:labelFont.fontDescriptor style:fontStyle];
        labelFont = [UIFont fontWithDescriptor:fontDescriptor size:0];
    }
    return labelFont;
}

-(UIFontDescriptor *)fontDescritorForCur:(UIFontDescriptor *)fd style:(NSInteger)style {
    switch (style) {
        case 1:
            return [fd fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
        case 2:
            return [fd fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic];
        case 3:
            return [fd fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold | UIFontDescriptorTraitItalic];
        default:
            return fd;
    }
}

- (CGSize)renderSizeForWidth:(CGFloat)width maxLine:(NSInteger)lineNumber {
    CGSize limitedSize = CGSizeMake(self.width, 0);
    if (lineNumber == 1) {
        limitedSize = CGSizeZero;
    }
    return limitedSize;
}

- (CGSize)calculateSize {
    CGSize limitedSize = [self renderSizeForWidth:self.width maxLine:self.numberOfLines];
    CGSize size = [PCSJsonLabel boundingRectWithSize:limitedSize text:self.text labelModel:self.jsonModel font:self.font maxLineNumber:self.numberOfLines];
    return size;
}

@end
