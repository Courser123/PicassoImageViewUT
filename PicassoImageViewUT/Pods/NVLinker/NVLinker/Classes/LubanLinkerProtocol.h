//
//  LubanLinkerProtocol.h
//  Pods
//
//  Created by JiangTeng on 2018/2/28.
//


#ifndef LubanLinkerProtocol_h
#define LubanLinkerProtocol_h

#define LubanLinkerCalssString @"LubanManager"
/**
 更新通知是在主线程中发出。
 调用[hasLubanConfigUpdated:forNotification:]方法，判断相关命令字有没有更新。
 如果有更新请调用[dataForConfigName:]获取最新的配置。
 */
#define LUBANLINKERCONFIGUPDATE @"LUBANCONFIGUPDATE"

/**
 Luban解藕协议，更多功能的接口请使用Luban。
 */
@protocol LubanLinkerProtocol <NSObject>

/**
 通过配置命令字、参数获取配置。
 如果本地缓存中没有配置返回空同时会发起请求拉取配置。配置拉取到后有通知LUBANLINKERCONFIGUPDATE发出
 线程安全
 
 @param configName 配置命令字。后台设置后客户端直接使用。
 @param parameters 参数
 @return 配置内容
 */
- (NSData *)dataForConfigName:(NSString *)configName parameters:(NSDictionary *)parameters;

/**
 通过配置命令字获取JSON配置。
 如果本地缓存中没有配置返回空同时会发起请求拉取配置。配置拉取到后有通知LUBANCONFIGUPDATE发出
 线程安全
 
 @param configName 配置命令字。后台设置后客户端直接使用。
 @param parameters 参数
 @return 配置内容
 */
- (NSDictionary *)jsonDicDataForConfigName:(NSString *)configName parameters:(NSDictionary *)parameters;

/**
 通过配置命令字获取JSON配置。
 只从本地缓存中读取，没有返回nil
 线程安全
 
 @param configName 配置命令字。后台设置后客户端直接使用。
 @param parameters 参数
 @return 配置内容
 */
- (NSDictionary *)jsonDicDataForCache:(NSString *)configName parameters:(NSDictionary *)parameters;

/**
 通过配置命令字、参数获取配置。
 只从本地缓存中读取，没有返回nil
 线程安全
 
 @param configName 配置命令字。后台设置后客户端直接使用。
 @param parameters 参数
 @return 配置内容
 */
- (NSData *)dataForCache:(NSString *)configName parameters:(NSDictionary *)parameters;

/**
 主动更新配置
 线程安全
 
 @param configName 配置命令字。后台设置后客户端直接使用。
 @param parameters 参数
 */
- (void)updateConfig:(NSString *)configName parameters:(NSDictionary *)parameters;

- (BOOL)hasLubanConfigUpdated:(NSString *)configName forNotification:(NSNotification *)n;

@end
#endif /* LubanLinkerProtocol_h */

