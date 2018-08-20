//
//  PCSJsonLabel.m
//  Nova
//
//  Created by xwd on 14-7-23.
//  Copyright (c) 2014年 dianping.com. All rights reserved.
//

#import "PCSJsonLabel.h"
#import "NSString+JSON.h"
#import "PCSJsonLabelStyleModel.h"
#import "PCSJsonLabelContentStyleModel.h"
#import "NSDictionary+PCSJsonLabel.h"
#import "UIColor+pcsUtils.h"

@interface PCSJsonLabel()
@property (nonatomic, strong) NSString * labelColorString;
@end

@implementation PCSJsonLabel

#pragma mark - PCSJsonLabel Size

+ (CGSize)boundingRectWithSize:(CGSize)size text:(NSString *)text labelModel:(PCSJsonLabelStyleModel *)model font:(UIFont *)font maxLineNumber:(NSInteger)lineNumber {
    CGSize actualSize;
    NSStringDrawingOptions drawingOptions = lineNumber == 1 ? NSStringDrawingUsesFontLeading : (NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin);
    if (model) {
        NSMutableAttributedString *styleAttributedString = [self getAttributedStringWithModel:model font:font lineBreakMode:NSLineBreakByWordWrapping];
        actualSize = [styleAttributedString boundingRectWithSize:size options:drawingOptions context:nil].size;
    } else if (text.length > 0) {
        actualSize = [text boundingRectWithSize:size options:drawingOptions attributes:@{NSFontAttributeName:(font?:[UIFont systemFontOfSize:[UIFont systemFontSize]])} context:nil].size;
    } else {
        return CGSizeZero;
    }
    if (lineNumber > 1 || lineNumber == 0) {
        UIFont *theFont = [self getMaxSizeFontWithModel:model font:font];
        NSInteger expectLineNumber = (actualSize.height + model.linespacing.floatValue) / (theFont.lineHeight + model.linespacing.floatValue);
        NSInteger actualLineNumber = MIN(expectLineNumber, lineNumber?:NSIntegerMax);
        if (!(lineNumber == 0 && actualSize.height > theFont.lineHeight + model.linespacing.floatValue)) {
            actualSize = CGSizeMake(actualSize.width, actualLineNumber * theFont.lineHeight + (actualLineNumber - 1) * model.linespacing.floatValue);
        }
    }
    CGFloat scale = [UIScreen mainScreen].scale;
    return (CGSize){ceil(actualSize.width * scale) / scale, ceil(actualSize.height * scale) / scale};
}

+ (NSInteger)lineNumberForRenderSize:(CGSize)size jsonString:(NSString *)jsonString font:(UIFont *)font {
    PCSJsonLabelStyleModel *model = [PCSJsonLabelStyleModel modelWithJsonString:jsonString];
    return [self lineNumberForRenderSize:size text:jsonString model:model font:font];
}

+ (NSInteger)lineNumberForRenderSize:(CGSize)size text:(NSString *)text model:(PCSJsonLabelStyleModel *)model font:(UIFont *)font {
    CGSize actualSize;
    if (model) {
        NSMutableAttributedString *styleAttributedString = [self getAttributedStringWithModel:model font:font lineBreakMode:NSLineBreakByWordWrapping];
        actualSize = [styleAttributedString boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size;
    } else if (text.length > 0) {
        actualSize = [text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:(font?:[UIFont systemFontOfSize:[UIFont systemFontSize]])} context:nil].size;
    } else {
        return 0;
    }
    UIFont *theFont = [self getMaxSizeFontWithModel:model font:font];
    NSInteger expectLineNumber = (actualSize.height + model.linespacing.floatValue) / (theFont.lineHeight + model.linespacing.floatValue);
    return expectLineNumber;
}

+ (UIFont *)getMaxSizeFontWithModel:(PCSJsonLabelStyleModel *)styleModel font:(UIFont *)font {
    UIFont *maxFont = nil;
    for (PCSJsonLabelContentStyleModel *model in styleModel.richtextlist) {
        UIFont *jsonFont = [self getFontWithModel:model defaultFont:font];

        if (jsonFont.lineHeight > maxFont.lineHeight) {
            maxFont = jsonFont;
        }
    }
    return maxFont ?: (font ?: [UIFont systemFontOfSize:[UIFont systemFontSize]]);
}

- (void)setLabelBorderStyleWithModel:(PCSJsonLabelStyleModel *)model {
    //边框粗细
    if (model.borderwidth) {
        self.layer.borderWidth = model.borderwidth.floatValue;
        //边框颜色
        if (model.bordercolor.length > 0) {
            self.layer.borderColor = [UIColor pcsColorWithHexString:model.bordercolor].CGColor;
        }
    }
    
    //圆角
    if (model.cornerradius) {
        self.layer.cornerRadius = model.cornerradius.floatValue;
        self.clipsToBounds = YES;
    }
    
    //Label背景色
    if (model.labelcolor.length > 0) {
        self.layer.backgroundColor = [UIColor pcsColorWithHexString:model.labelcolor].CGColor;
        self.backgroundColor = [UIColor pcsColorWithHexString:model.labelcolor];
        self.labelColorString = model.labelcolor;
    }
}

+ (NSMutableAttributedString *)getAttributedStringWithModel:(PCSJsonLabelStyleModel *)styleModel font:(UIFont *)font lineBreakMode:(NSLineBreakMode)lineBreakMode {
    if (!styleModel) return nil;
    
    NSMutableAttributedString *allAttributedString = [[NSMutableAttributedString alloc] init];
    NSMutableParagraphStyle *paragraphStyle = nil;
    if (styleModel.linespacing.floatValue > 0 || styleModel.alignment) {
        paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing  = styleModel.linespacing.floatValue;
        paragraphStyle.lineBreakMode = lineBreakMode;
        paragraphStyle.alignment = styleModel.alignment;
    }
    
    CGFloat maxPointSize = 0;
    if (styleModel.verticalalignment == PCSJsonLabelVerticalAlignmentCenter) {
        UIFont *maxSizeFont = [self getMaxSizeFontWithModel:styleModel font:font];
        maxPointSize = maxSizeFont.pointSize;
    }
    
    for (PCSJsonLabelContentStyleModel *model in styleModel.richtextlist) {
        if (![model isKindOfClass:[PCSJsonLabelContentStyleModel class]]) {
            continue;
        }
        if (model.text.length > 0) {
            NSMutableAttributedString *fragmentAttributedString = [[NSMutableAttributedString alloc] initWithString:model.text];
            
            //字体
            UIFont *jsonFont = [self getFontWithModel:model defaultFont:font];
            if (jsonFont) {
                [fragmentAttributedString addAttribute:NSFontAttributeName value:jsonFont range:NSMakeRange(0, model.text.length)];
            }
            
            //kerning
            if (model.kerning) {
                [fragmentAttributedString addAttribute:NSKernAttributeName value:@([model.kerning floatValue]) range:NSMakeRange(0, model.text.length)];
            }
            
            //下划线
            if (model.underline.boolValue) {
                [fragmentAttributedString addAttribute:NSUnderlineStyleAttributeName value:@([model.underline boolValue]) range:NSMakeRange(0, model.text.length)];
            }
            
            if (styleModel.verticalalignment == PCSJsonLabelVerticalAlignmentCenter) {
                if (jsonFont.pointSize < maxPointSize) {
                    [fragmentAttributedString addAttribute:NSBaselineOffsetAttributeName value:@((maxPointSize - jsonFont.pointSize) / 2.0) range:NSMakeRange(0, model.text.length)];
                }
            }
            
            //删除线
            if (model.strikethrough.boolValue) {
                [fragmentAttributedString addAttribute:NSStrikethroughStyleAttributeName value:@([model.strikethrough boolValue]) range:NSMakeRange(0, model.text.length)];
                if ([UIDevice currentDevice].systemVersion.doubleValue >= 10.3) {
                    [fragmentAttributedString addAttribute:NSBaselineOffsetAttributeName value:@(0) range:NSMakeRange(0, model.text.length)];
                }
            }
            
            //字体颜色
            if (model.textcolor.length > 0) {
                UIColor *textColor = [UIColor pcsColorWithHexString:model.textcolor];
                if (textColor) {
                    [fragmentAttributedString addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(0, model.text.length)];
                }
            };
            
            //背景色
            if (model.backgroundcolor.length > 0) {
                UIColor *backgroundColor = [UIColor pcsColorWithHexString:model.backgroundcolor];
                if (backgroundColor) {
                    [fragmentAttributedString addAttribute:NSBackgroundColorAttributeName value:backgroundColor range:NSMakeRange(0, model.text.length)];
                }
            }
            
            //ParagraphStyle
            if (paragraphStyle) {
                [fragmentAttributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, model.text.length)];
            }
            
            [allAttributedString appendAttributedString:fragmentAttributedString];
        }
    }
    
    return allAttributedString;
}

+ (UIFont *)getFontWithModel:(PCSJsonLabelContentStyleModel *)model defaultFont:(UIFont *)font {
    UIFont *currentFont = font ? font : [UIFont systemFontOfSize:[UIFont systemFontSize]];
    if (model.fontname.length > 0) {
        currentFont = [UIFont fontWithName:model.fontname size:currentFont.pointSize];
    }
    //字体大小
    CGFloat fontSize = model.textsize.floatValue;
    if (fabs(fontSize - 0) <= 0.5) {
        fontSize = currentFont.pointSize;
    }
    
    UIFont *jsonFont = [UIFont fontWithName:currentFont.fontName size:fontSize];
    if (model.textstyle.length > 0) {
        jsonFont = [self fontWithTextStyle:model.textstyle font:jsonFont];
    }
    return jsonFont;
}

+ (UIFont *)fontWithTextStyle:(NSString *)style font:(UIFont *)oriFont {
    UIFontDescriptor *fontDescriptor = oriFont.fontDescriptor;
    if ([style isEqualToString:@"Bold"]) {
        fontDescriptor = [fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
    } else if ([style isEqualToString:@"Italic"]) {
        fontDescriptor = [fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic];
    } else if ([style isEqualToString:@"Bold_Italic"]) {
        fontDescriptor = [fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold | UIFontDescriptorTraitItalic];
    }
    return [UIFont fontWithDescriptor:fontDescriptor size:0];
}

+ (NSAttributedString *)getAttributedTextWithModel:(PCSJsonLabelStyleModel *)labelModel font:(UIFont *)font renderSize:(CGSize)size linebreakMode:(NSLineBreakMode)lineBreakMode{
    if (!labelModel) {
        return nil;
    }
    if (labelModel.linespacing.floatValue > 0 && [self lineNumberForRenderSize:size text:nil model:labelModel font:font] == 1) {
        labelModel.linespacing = @(0.01);
    }
    return [self getAttributedStringWithModel:labelModel font:font lineBreakMode:lineBreakMode];
}

- (void)setLabelBorderStyleWithJsonString:(NSString *)jsonString {
    PCSJsonLabelStyleModel *labelModel = [PCSJsonLabelStyleModel modelWithJsonString:jsonString];
    if (!labelModel) {
        return ;
    }
    [self setLabelBorderStyleWithModel:labelModel];
}

@end
