#import "LogBaseModel.h"

@interface SwitchSampleConfig : LogBaseModel
/** 采样率数值*/
@property (nonatomic, strong) NSNumber * sample; // double
/** 采样接口名称*/
@property (nonatomic, copy) NSString * uid;
@end