//
//  NVJsonLabel.h
//  Nova
//
//  Created by xwd on 14-7-23.
//  Copyright (c) 2014年 dianping.com. All rights reserved.
//

@class PCSJsonLabelStyleModel;

@interface PCSJsonLabel : UILabel

/**
 计算label size的方法，text和model如果都传，优先使用model进行size计算

 @param size 限定大小
 @param text 文本
 @param model NVJsonLabel制定的模型
 @param font 默认文字大小
 @param lineNumber 文本最大行数，0为无限行
 @return 计算得出的size
 */
+ (CGSize)boundingRectWithSize:(CGSize)size text:(NSString *)text labelModel:(PCSJsonLabelStyleModel *)model font:(UIFont *)font maxLineNumber:(NSInteger)lineNumber;

/**
 *  计算富文本在控件中布局后的行数
 *  font传nil时，使用富文本中指定的字体库和大小，如果富文本中未指定，使用系统默认字体
 */
+ (NSInteger)lineNumberForRenderSize:(CGSize)size text:(NSString *)text model:(PCSJsonLabelStyleModel *)model font:(UIFont *)font;

/**
 根据富文本模型获取AttributedString

 @param labelModel 富文本模型
 @param font 默认字体
 @param size 文本控件大小，设置linespacing时，如果计算出来只有一行，将linespacing置为0.01
 @return AttributedString
 */
+ (NSAttributedString *)getAttributedTextWithModel:(PCSJsonLabelStyleModel *)labelModel font:(UIFont *)font renderSize:(CGSize)size linebreakMode:(NSLineBreakMode)lineBreakMode;

/**
 *  根据富文本设置label的外观
 */
- (void)setLabelBorderStyleWithJsonString:(NSString *)jsonString;

@end
