#import "PCSJsonLabelBaseModel.h"
#import "PCSJsonLabelStyleModel.h"
#import "PCSJsonLabelContentStyleModel.h"
#import "PCSJsonLabelContentBaseModel.h"
#import "NSDictionary+PCSJsonLabel.h"
#import "NSString+JSON.h"

@interface PCSJsonLabelBaseModel (Private)
- (void)setModelWithJSONDictionary:(NSDictionary *)dictionary;
@end

@implementation PCSJsonLabelStyleModel

+ (PCSJsonLabelStyleModel *)modelWithJsonString:(NSString *)jsonString {
    if (!(([jsonString hasPrefix:@"["] && [jsonString hasSuffix:@"]"]) || ([jsonString hasPrefix:@"{"] && [jsonString hasSuffix:@"}"]))) {
        return nil;
    }
    id value = [jsonString JSONValue];
    if ([value isKindOfClass:[NSArray class]]) {
        return [PCSJsonLabelStyleModel modelWithJSONDictionary:@{@"richtextlist":value?:@[]}];
    }
    else if ([value isKindOfClass:[NSDictionary class]]) {
        id richTextList = [value pcs_objectForKey:@"richtextlist" abbreviatedKey:@"rl"];
        if ([richTextList isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *_value = [value mutableCopy];
            [_value setObject:@[richTextList?:@{}] forKey:@"richtextlist"];
            return [PCSJsonLabelStyleModel modelWithJSONDictionary:_value];
        }
        else if ([richTextList isKindOfClass:[NSArray class]]) {
            return [PCSJsonLabelStyleModel modelWithJSONDictionary:value];
        }
        else {
            return [PCSJsonLabelStyleModel modelWithJSONDictionary:@{@"richtextlist":@[value?:@{}]}];
        }
    }
    return nil;
}

+ (NSDictionary *)contentModelMapping {
    return @{@(0):[PCSJsonLabelContentStyleModel class]};
}

- (void)setModelWithJSONDictionary:(NSDictionary *)dictionary {
	[super setModelWithJSONDictionary:dictionary];
    NSArray *list = [dictionary pcs_objectForKey:@"richtextlist" abbreviatedKey:@"rl"];
    if ([list isKindOfClass:[NSArray class]] && list.count > 0) {
        NSMutableArray<PCSJsonLabelContentBaseModel *> *mList = [NSMutableArray array];
        for (NSDictionary *jsonDictionary in list) {
            PCSJsonLabelContentBaseModel *model = nil;
            NSNumber *type = [jsonDictionary pcs_objectForKey:@"type" abbreviatedKey:@"tp"] ? : @(0);
            Class modelCls = [[self.class contentModelMapping] objectForKey:type];
            if (modelCls) {
                model = [modelCls modelWithJSONDictionary:jsonDictionary];
            }
            if (model) {
                [mList addObject:model];
            }
        }
        self.richtextlist = mList;
    }
	self.alignment = [[dictionary pcs_objectForKey:@"alignment" abbreviatedKey:@"al"] integerValue];
    self.verticalalignment = [[dictionary pcs_objectForKey:@"verticalalignment" abbreviatedKey:@"va"] integerValue];
	self.linespacing = [dictionary pcs_objectForKey:@"linespacing" abbreviatedKey:@"ls"];
    self.labelcolor = [dictionary pcs_objectForKey:@"labelcolor" abbreviatedKey:@"lc"];
	self.cornerradius = [dictionary pcs_objectForKey:@"cornerradius" abbreviatedKey:@"cr"];
	self.bordercolor = [dictionary pcs_objectForKey:@"bordercolor" abbreviatedKey:@"bc"];
	self.borderwidth = [dictionary pcs_objectForKey:@"borderwidth" abbreviatedKey:@"bw"];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wcompare-distinct-pointer-types"
	if (self.linespacing == [NSNull null]) { self.linespacing = nil; }
	if (self.labelcolor == [NSNull null]) { self.labelcolor = nil; }
	if (self.cornerradius == [NSNull null]) { self.cornerradius = nil; }
	if (self.bordercolor == [NSNull null]) { self.bordercolor = nil; }
	if (self.borderwidth == [NSNull null]) { self.borderwidth = nil; }
#pragma clang diagnostic pop
}

@end

@implementation PCSJsonLabelContentStyleModel
- (void)setModelWithJSONDictionary:(NSDictionary *)dictionary {
	[super setModelWithJSONDictionary:dictionary];
	self.linkaction = [dictionary pcs_objectForKey:@"linkaction" abbreviatedKey:@"la"];
	self.link = [dictionary pcs_objectForKey:@"link" abbreviatedKey:@"lk"];
	self.textstyle = [dictionary pcs_objectForKey:@"textstyle" abbreviatedKey:@"tst"];
	self.kerning = [dictionary pcs_objectForKey:@"kerning" abbreviatedKey:@"kn"];
	self.backgroundcolor = [dictionary pcs_objectForKey:@"backgroundcolor" abbreviatedKey:@"bgc"];
	self.textcolor = [dictionary pcs_objectForKey:@"textcolor" abbreviatedKey:@"tc"];
	self.strikethrough = [dictionary pcs_objectForKey:@"strikethrough" abbreviatedKey:@"st"];
	self.underline = [dictionary pcs_objectForKey:@"underline" abbreviatedKey:@"ul"];
	self.textsize = [dictionary pcs_objectForKey:@"textsize" abbreviatedKey:@"ts"];
	self.fontname = [dictionary pcs_objectForKey:@"fontname" abbreviatedKey:@"fn"];
	self.text = [dictionary pcs_objectForKey:@"text" abbreviatedKey:@"te"];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wcompare-distinct-pointer-types"
	if (self.linkaction == [NSNull null]) { self.linkaction = nil; }
	if (self.link == [NSNull null]) { self.link = nil; }
	if (self.textstyle == [NSNull null]) { self.textstyle = nil; }
	if (self.kerning == [NSNull null]) { self.kerning = nil; }
	if (self.backgroundcolor == [NSNull null]) { self.backgroundcolor = nil; }
	if (self.textcolor == [NSNull null]) { self.textcolor = nil; }
	if (self.strikethrough == [NSNull null]) { self.strikethrough = nil; }
	if (self.underline == [NSNull null]) { self.underline = nil; }
	if (self.textsize == [NSNull null]) { self.textsize = nil; }
	if (self.fontname == [NSNull null]) { self.fontname = nil; }
	if (self.text == [NSNull null]) { self.text = nil; }
#pragma clang diagnostic pop
}

- (UIFont *)fontWithDefaultFont:(UIFont *)defaultFont {
    UIFont *font = defaultFont;
    if (self.fontname.length > 0) {
        font = [UIFont fontWithName:self.fontname size:font.pointSize];
    }
    //字体大小
    CGFloat fontSize = self.textsize.floatValue;
    if (fabs(fontSize - 0) <= 0.5) {
        fontSize = font.pointSize;
    }
    
    UIFont *jsonFont = [UIFont fontWithName:font.fontName size:fontSize];
    if (self.textstyle.length > 0) {
        jsonFont = [self.class fontWithTextStyle:self.textstyle font:jsonFont];
    }
    return jsonFont;
}

- (CGFloat)capHeight {
    return [self fontWithDefaultFont:[UIFont systemFontOfSize:[UIFont systemFontSize]]].capHeight;
}

+ (UIFont *)fontWithTextStyle:(NSString *)style font:(UIFont *)font {
    UIFontDescriptor *fontDescriptor = font.fontDescriptor;
    if ([style isEqualToString:@"Bold"]) {
        fontDescriptor = [fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
    } else if ([style isEqualToString:@"Italic"]) {
        fontDescriptor = [fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic];
    } else if ([style isEqualToString:@"Bold_Italic"]) {
        fontDescriptor = [fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold | UIFontDescriptorTraitItalic];
    }
    return [UIFont fontWithDescriptor:fontDescriptor size:0];
}

@end

@implementation PCSJsonLabelContentBaseModel
- (void)setModelWithJSONDictionary:(NSDictionary *)dictionary {
	[super setModelWithJSONDictionary:dictionary];
    self.type = [dictionary pcs_objectForKey:@"type" abbreviatedKey:@"tp"] ? : @0;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wcompare-distinct-pointer-types"
	if (self.type == [NSNull null]) { self.type = nil; }
#pragma clang diagnostic pop
}

- (CGFloat)capHeight {
    return 0;
}

- (UIFont *)fontWithDefaultFont:(UIFont *)defaultFont {
    return defaultFont;
}

@end


