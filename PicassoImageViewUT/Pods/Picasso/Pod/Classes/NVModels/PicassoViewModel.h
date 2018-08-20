#import "PicassoModel.h"



@interface PicassoViewModel : PicassoModel
/** 子视图*/
@property (nonatomic, strong) NSArray <PicassoModel *> * subviews;

@property (nonatomic, assign) BOOL clipToBounds;

@end
