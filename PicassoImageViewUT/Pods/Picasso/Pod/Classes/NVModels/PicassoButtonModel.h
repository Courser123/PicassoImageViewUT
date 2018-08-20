#import "PicassoModel.h"



@interface PicassoButtonModel : PicassoModel
/** 跳转url*/
@property (nonatomic, copy) NSString * schema;
/** 业务数据*/
@property (nonatomic, strong) NSDictionary *data;
/** NormalState背景图片*/
@property (nonatomic, strong) UIImage *normalImage;
/** ClickedState背景图片*/
@property (nonatomic, strong) UIImage *clickedImage;

@end
