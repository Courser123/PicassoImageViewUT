#import "LogBaseModel.h"

@interface SwitchTypes : LogBaseModel
/** 是否可以上报*/
@property (nonatomic, strong) NSNumber * enable; // boolean
/** 日志类型*/
@property (nonatomic, copy) NSString * uid;
@end