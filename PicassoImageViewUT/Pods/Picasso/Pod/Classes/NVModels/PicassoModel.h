
#import "PicassoBaseModel.h"

@interface PicassoModel : PicassoBaseModel

- (NSArray <PicassoModel *> *)subModels;

/** 生成时创建的唯一标识*/
@property (nonatomic, copy) NSString * viewId;
/** 父节点的唯一标识*/
@property (nonatomic, copy) NSString * parentId;
/** view所在host的标识*/
@property (nonatomic, copy) NSString *hostId;
/** 唯一标识*/
@property (nonatomic, copy) NSString * tag;
/** 是否隐藏*/
@property (nonatomic, assign) BOOL hidden;
/** 透明度*/
@property (nonatomic, assign) double alpha;
/** 边框颜色*/
@property (nonatomic, strong) UIColor * borderColor;
/** 边框宽度*/
@property (nonatomic, assign) double borderWidth;
/** 圆角*/
@property (nonatomic, assign) double cornerRadius;
/** 类型*/
@property (nonatomic, assign) NSInteger type;
/** 背景颜色*/
@property (nonatomic, strong) UIColor * backgroundColor;
/** y*/
@property (nonatomic, assign) double y;
/** x*/
@property (nonatomic, assign) double x;
/** 高度*/
@property (nonatomic, assign) double height;
/** 宽度*/
@property (nonatomic, assign) double width;
/** GA*/
@property (nonatomic, copy) NSString * gaLabel;
/** GA UserInfo*/
@property (nonatomic, strong) NSDictionary * gaUserInfo;

@property (nonatomic, strong) NSDictionary *extra;

@property (nonatomic, copy) NSString *accessId;

@property (nonatomic, copy) NSString *accessLabel;

@property (nonatomic, strong) NSArray <NSString *> *actions;

@property (nonatomic, assign) double shadowOpacity;
@property (nonatomic, strong) UIColor *shadowColor;
@property (nonatomic, assign) double shadowRadius;
@property (nonatomic, assign) CGSize shadowOffset;

@property (nonatomic, strong) NSArray *gradientColors;
@property (nonatomic, assign) CGPoint gradientStartPoint;
@property (nonatomic, assign) CGPoint gradientEndPoint;

@property (nonatomic, assign) UIRectCorner rectCorner;

@property (nonatomic, strong) NSNumber *key;

@property (nonatomic, strong) NSDictionary *dictionaryValue;
@end
