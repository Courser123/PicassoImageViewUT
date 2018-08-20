#import "PCSJsonLabelContentBaseModel.h"

@interface PCSJsonLabelContentStyleModel : PCSJsonLabelContentBaseModel
/** 链接动作*/
@property (nonatomic, copy) NSString * linkaction;
/** 链接*/
@property (nonatomic, copy) NSString * link;
/** 字体样式，粗体或斜体*/
@property (nonatomic, copy) NSString * textstyle;
/** 字间距，默认0*/
@property (nonatomic, strong) NSNumber * kerning; // double
/** 字体背景色*/
@property (nonatomic, copy) NSString * backgroundcolor;
/** 字体颜色*/
@property (nonatomic, copy) NSString * textcolor;
/** 删除线*/
@property (nonatomic, strong) NSNumber * strikethrough; // boolean
/** 下划线*/
@property (nonatomic, strong) NSNumber * underline; // boolean
/** 字体大小*/
@property (nonatomic, strong) NSNumber * textsize; // double
/** 字体名称*/
@property (nonatomic, copy) NSString * fontname;
/** 文字*/
@property (nonatomic, copy) NSString * text;
@end
