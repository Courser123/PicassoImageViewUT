#import "PCSJsonLabelBaseModel.h"
#import "PCSJsonLabelContentBaseModel.h"
#import "PCSJsonLabelContentStyleModel.h"

typedef NS_ENUM(NSInteger, PCSJsonLabelVerticalAlignment) {
    PCSJsonLabelVerticalAlignmentBottom = 0,
    PCSJsonLabelVerticalAlignmentCenter,
    PCSJsonLabelVerticalAlignmentTop
};

@interface PCSJsonLabelStyleModel : PCSJsonLabelBaseModel
/** 文本水平对齐方式, left | center | right*/
@property (nonatomic, assign) NSTextAlignment alignment;
/** 富文本基线对齐样式, bottom | center | top*/
@property (nonatomic, assign) PCSJsonLabelVerticalAlignment verticalalignment;
/** 行间距*/
@property (nonatomic, strong) NSNumber * linespacing; // double
/** label中的文字*/
@property (nonatomic, strong) NSArray <PCSJsonLabelContentBaseModel *> * richtextlist;
/** 背景颜色*/
@property (nonatomic, copy) NSString * labelcolor;
/** 圆角半径*/
@property (nonatomic, strong) NSNumber * cornerradius; // double
/** 边框颜色*/
@property (nonatomic, copy) NSString * bordercolor;
/** 边框宽度*/
@property (nonatomic, strong) NSNumber * borderwidth; // double

+ (NSDictionary *)contentModelMapping;

+ (PCSJsonLabelStyleModel *)modelWithJsonString:(NSString *)jsonString;

@end
