#import "LogBaseModel.h"
#import "SwitchProperty.h"
#import "SwitchHertz.h"
#import "SwitchSampleConfig.h"
#import "SwitchTypes.h"

@interface LogReportSwitchModel : LogBaseModel
/** 请求间隔配置*/
@property (nonatomic, strong) NSArray <SwitchProperty *> * appProperties;
/** hertz配置*/
@property (nonatomic, strong) NSArray <SwitchHertz *> * hertz;
/** 采样率配置*/
@property (nonatomic, strong) NSArray <SwitchSampleConfig *> * sampleConfig;
/** 日志类型配置*/
@property (nonatomic, strong) NSArray <SwitchTypes *> * types;
/** 日志版本号*/
@property (nonatomic, strong) NSString *configVersion;
@end
