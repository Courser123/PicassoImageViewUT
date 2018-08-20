#import "PicassoModel.h"



@interface PicassoImageViewModel : PicassoModel
/** 缩放类型*/
@property (nonatomic, assign) NSInteger contentMode;
/** App本地图片*/
@property (nonatomic, strong) UIImage *localImage;
/** 图片url*/
@property (nonatomic, copy) NSString * imageUrl;

@property (nonatomic, strong) UIImage *loadingImage;
@property (nonatomic, strong) UIImage *errorImage;

@property (nonatomic, assign) UIEdgeInsets edgeInsets;
@property (nonatomic, assign) NSInteger imageScale;
/// gif 图片播放次数
@property (nonatomic, assign) NSInteger gifLoopCount;
@property (nonatomic, assign) BOOL fadeEffect;
/// 图片缓存类型
@property (nonatomic, assign) NSInteger cacheType;
/// 图片加载失败点击重试
@property (nonatomic, assign) BOOL failedRetry;
/// 图片高斯模糊半径，默认0，取值 0 ~ 1 之间
@property (nonatomic, assign) CGFloat blurRadius;

@end
