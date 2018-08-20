#import "LogBaseModel.h"
#import "Properties.h"

@interface SwitchHertz : LogBaseModel
/** 配置项*/
@property (nonatomic, strong) NSArray <Properties *> * properties;
/** 类型（安卓、iOS）*/
@property (nonatomic, copy) NSString * type;
@end