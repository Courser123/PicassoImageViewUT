#import "LogBaseModel.h"

@interface SwitchProperty : LogBaseModel
/** 内容*/
@property (nonatomic, strong) NSNumber * content; // int
/** 名称*/
@property (nonatomic, copy) NSString * configId;
@end