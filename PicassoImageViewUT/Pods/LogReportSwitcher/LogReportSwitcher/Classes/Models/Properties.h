#import "LogBaseModel.h"

@interface Properties : LogBaseModel
/** 名称*/
@property (nonatomic, copy) NSString * value;
/** 数值*/
@property (nonatomic, copy) NSString * key;
@end