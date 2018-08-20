#import "PCSJsonLabelBaseModel.h"

@interface PCSJsonLabelContentBaseModel : PCSJsonLabelBaseModel
/** 类型*/
@property (nonatomic, strong) NSNumber * type; // int

- (UIFont *)fontWithDefaultFont:(UIFont *)defaultFont;
- (CGFloat)capHeight;

@end
