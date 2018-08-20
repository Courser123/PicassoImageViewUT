
#import "PicassoModel.h"
#import "PicassoSizeToFitProtocol.h"

@class PCSJsonLabelStyleModel;
@interface PicassoLabelModel : PicassoModel <PicassoSizeToFitProtocol>
/** 行数*/
@property (nonatomic, assign) NSInteger numberOfLines;
/** 字符截断类型*/
@property (nonatomic, assign) NSInteger lineBreakMode;
/** 字符对齐类型*/
@property (nonatomic, assign) NSInteger textAlignment;
/** 字符串*/
@property (nonatomic, copy) NSString * text;
/** 富文本字符串*/
@property (nonatomic, strong) NSAttributedString *attributedText;
/** 字体*/
@property (nonatomic, strong) UIFont *font;
/** 字体颜色*/
@property (nonatomic, strong) UIColor *textColor;
/** 删除线*/
@property (nonatomic, assign) BOOL strikethrough;
/** 下划线*/
@property (nonatomic, assign) BOOL underline;
/** 行间距*/
@property (nonatomic, assign) CGFloat linespacing;

@property (nonatomic, strong) PCSJsonLabelStyleModel *jsonModel;

@property (nonatomic, strong) UIColor *textShadowColor;
@property (nonatomic, assign) CGFloat textShadowRadius;
@property (nonatomic, assign) CGSize textShadowOffset;
@property (nonatomic, strong) UIColor *highlightedBgColor;


@end
