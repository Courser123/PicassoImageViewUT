//
//  LogReportSwitcher.h
//  Pods
//
//  Created by lmc on 16/6/1.
//
//

typedef enum : NSUInteger {
    SwitcherConfigFromCat = 1,
    SwitcherConfigFromHttp = 2,
} SwitcherConfigFrom;

typedef void (^HertzConfigBlock)(NSDictionary *cmd);
typedef void (^SwitcherConfigBlock)(SwitcherConfigFrom from, NSString *config);

// 配置发生变化时发出通知
extern NSNotificationName const SwitcherConfigChangedNotification;

@interface LogReportSwitcher : NSObject

/*
 * LogReportSwitcher单例
 */
+ (instancetype)shareInstance;

/*
 * 设置LogReportSwitcher
 * beta  YES:表示是beta环境 环境为:catdot.51ping.com
 */
- (void)setupIsBeta:(BOOL)beta;
/*
 * 设置参数信息（必须设置，否则获取不到结果）
 * @param appid app注册的的唯一ID
 * @param defaultParameters 请求header中添加的默认参数信息（dpid, unionid）
 */
- (void)setAppID:(NSString *)appid defaultParameters:(NSDictionary *)parameters;


/*
 * 采样率
 * 返回JSON数组数据
 */
- (NSArray *)getSampleRateArray;

/*
 * 测速配置
 * callback JSON数据
 */
- (void)getHertzConfig:(HertzConfigBlock)config;

/*
 * 获取日志上报开关
 * @param logType 日志类型（base:端到端及测速监控 crash:crash日志 codelog:代码级日志）开关默认值为：YES
 */
- (BOOL)isLogReport:(NSString *)logType;

/**
 获取日志上报开关

 @param logType 开关key
 @param value 开关默认值
 @return 该开关是否打开
 */
- (BOOL)isLogReport:(NSString *)logType defaultValue:(BOOL)value;
/*
 * 获取日志大管家Logan配置信息
 * 返回数组
 */
- (NSArray *)getLoganConfig;

/*
 * 获取配置的版本号(供Cat使用)
 */
- (NSString *)configVersion;

/*
 * 设置cat响应返回的新配置
 * @param data Cat返回的数据
 */
- (void)handleCatResponse:(NSData *)data;

/*
 * 设置收到Config时的回调
 */
- (void)setSwitcherConfigBlock:(SwitcherConfigBlock)block;

@end
