//
//  NVMonitorCenter.h
//  MonitorDemo
//
//  Created by ZhouHui on 16/1/12.
//  Copyright © 2016年 dianping. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSString* (^UnionIDBlock)();

/**
 * 前端监控服务
 * <p>
 * 监控对象为API的接口调用，包括时长，状态码，错误等<br>
 * 监控日志批量上传，15秒一次<br>
 * 日志缓存为16条，超出部分丢弃只保留最近16条。日志缓存在内存中，进程关闭既消失
 *
 * @author zhouhui
 *
 */
@interface NVMonitorCenter : NSObject

/**
 NVMonitorCenter以单例模式运行
 */
+ (instancetype)defaultCenter;


/**
 *  @param isDebug 是否输出日志，默认关闭
 */

+ (void)isDebug:(BOOL)isDebug;

/*
 * 设置LogReportSwitcher
 * beta  YES:表示是beta环境 环境为:catdot.51ping.com
 */
- (void)setupIsBeta:(BOOL)beta;

/**
 设置服务器地址，!!!!!!!必须设置服务器地址，否则无法上传日志
 */
- (void)setServerUrl:(NSString *)url DEPRECATED_MSG_ATTRIBUTE("use setServerHost: instead");


/**
 for failover monitor use 
 @param url failurl
 */
- (void)setFailoverURL:(NSString *)url DEPRECATED_MSG_ATTRIBUTE("please do not use this method");

/**
 *  设置服务器host，不再需要设置，建议移除
 *
 *  @param host server host
 */
-(void)setServerHost:(NSString *)host;// DEPRECATED_MSG_ATTRIBUTE("host is build in ,this method is useless anymore")

/**
 设置app ID，!!!!!!!必须设置服务器地址，否则无法分辨日志
 1  : 点评主app
 2  : 点评团app
 10 : 美团主app
 11 : 美团外卖app
 12 : 美团猫眼app
 */
- (void)setAppID:(int)p;
/**
 *  返回当前app ID
 *
 *  @return app ID
 */
- (int)appID;

/**
 设置UnionId，由于UnionId会变化，所以需要使用Block来传值
 */
- (void)setUnionIdBlock:(UnionIDBlock)block;

- (void)setDNSDuration:(NSInteger)duration;

- (NSString *)urlEncode:(NSString *)url;

/**
 堆栈上报次数限制（每24小时重新计算）

 @param times 次数
 */
- (void)setCrashMonitorTimes:(NSInteger)times;

/**
 * 记录到本地，并上报到cat服务器，参见https://wiki.sankuai.com/pages/viewpage.action?pageId=1191168484
 *
 * @param url 请求URL，该url为实际发出的url。
 * @param originUrl 原始请求URL，即业务方传入的未修改之前的url。（可选）
 * @param cmd 命令字。可以为空，如果为空则从url中提取命令字。（可选）
 * @param method 请求方法类型。包括POST, GET, PUT, DELETE等
 * @param requestHeader 请求的header头
 * @param requestBytes 请求的发送字节数
 * @param respTime 端到端响应时间，单位ms
 * @param statusCode 响应的状态码
 * @param responseHeader 响应的header头
 * @param responseBytes 响应的接收字节数
 * @param uploadSample 上传的概率，为[0, 1]之间的数字，0代表0%的几率上传，0.5代表50%的几率上传。默认为1
 * @param tunnel 通道类型:0 短连接通道，2  Shark(CIP)，3 Shark(Http)，4 Shark(WNS)，5 Shark通道，7 Fiber通道，8 HTTPS连接
 * @param subTunnel 子通道类型：（Shark内部使用）0 HTTP ， 1 TCP， 8 HTTPS
 * @param ip 请求的IP地址（可选）
 * @param sharkStatus Shark通道内的状况（可选）
 * @param extend 扩展字段，用于端到端上报后的查询（可选）(extend字段会上报cat)
 * @param extra 扩展字段，用于Logan记录（可选）（extra字段不会上报cat，只记录在本地）
 */
- (void)catWithUrl:(NSString *)url
         originUrl:(NSString *)originUrl
               cmd:(NSString *)cmd
            method:(NSString *)method
     requestHeader:(NSDictionary *)requestHeader
      requestBytes:(long)requestBytes
      responseTime:(int)respTime
        statusCode:(NSInteger)statusCode
    responseHeader:(NSDictionary *)responseHeader
     responseBytes:(long)responseBytes
      uploadSample:(float)uploadSample
            tunnel:(int)tunnel
         subTunnel:(int)subTunnel
                ip:(NSString *)ip
       sharkStatus:(NSString *)sharkStatus
            extend:(NSString *)extend
             extra:(NSString *)extra;

/**
 * API访问的PV日志
 *
 * @param command
 *            标示符，一般用url里最后的path表示，如“shop.bin”
 * @param network
 *            网络类型，1=Wifi，2=2G，3=3G，4=4G。传0表示自动检测当前网络状态
 * @param code
 *            状态码，返回码范围(-32768,32767)。其中(1000,32767)用于业务错误码，(-1000,0)网络通道已占用的错误码，(0,500)HTTP状态码
 * @param tunnel
 *            连接通道，0 短连接通道，2 	Shark(CIP)，3 Shark(Http)，4 Shark(WNS)，5 Shark通道，7 Fiber通道，8 HTTPS连接
 * @param requestBytes
 *            请求字节数
 * @param responseBytes
 *            返回字节数
 * @param responseTime
 *            端到端响应时间，单位ms
 * @param ip
 *            当前请求的IP地址，可以为空
 * @param uploadPercent
 *            上传的概率，为[0, 100]之间的数字，0代表0%的几率上传，100代表100%的几率上传。
 *            默认为100
 * @param extend
 *            扩展字段，用于端到端查询，可以为空。
 */
- (void)pvWithCommand:(NSString *)cmd network:(int)network code:(int)code tunnel:(int)tunnel requestBytes:(int)reqBytes responseBytes:(int)respBytes responseTime:(int)respTime ip:(NSString *)ip uploadPercent:(int)uploadPercent extend:(NSString *)extend;

/**
 * API访问的PV日志
 *
 * @param command
 *            标示符，一般用url里最后的path表示，如“shop.bin”
 * @param network
 *            网络类型，1=Wifi，2=2G，3=3G，4=4G。传0表示自动检测当前网络状态
 * @param code
 *            状态码，返回码范围(-32768,32767)。其中(1000,32767)用于业务错误码，(-1000,0)网络通道已占用的错误码，(0,500)HTTP状态码
 * @param tunnel
 *            连接通道，0 短连接通道，2 	Shark(CIP)，3 Shark(Http)，4 Shark(WNS)，5 Shark通道，7 Fiber通道，8 HTTPS连接
 * @param requestBytes
 *            请求字节数
 * @param responseBytes
 *            返回字节数
 * @param responseTime
 *            端到端响应时间，单位ms
 * @param ip
 *            当前请求的IP地址，可以为空
 * @param uploadSample
 *            上传的概率，为[0, 1]之间的数字，0代表0%的几率上传，0.5代表50%的几率上传。
 *            默认为1
 * @param extend
 *            扩展字段，用于端到端查询，可以为空。
 */
- (void)pvWithCommand:(NSString *)cmd network:(int)network code:(int)code tunnel:(int)tunnel requestBytes:(int)reqBytes responseBytes:(int)respBytes responseTime:(int)respTime ip:(NSString *)ip uploadSample:(float)uploadMilli extend:(NSString *)extend;

- (void)pvWithCommand:(NSString *)cmd network:(int)network code:(int)code tunnel:(int)tunnel requestBytes:(int)reqBytes responseBytes:(int)respBytes responseTime:(int)respTime ip:(NSString *)ip uploadPercent:(int)uploadPercent;

- (void)pvWithCommand:(NSString *)cmd network:(int)network code:(int)code tunnel:(int)tunnel requestBytes:(int)reqBytes responseBytes:(int)respBytes responseTime:(int)respTime ip:(NSString *)ip;

- (void)pvWithCommand:(NSString *)cmd network:(int)network code:(int)code requestBytes:(int)reqBytes responseBytes:(int)respBytes responseTime:(int)respTime ip:(NSString *)ip;

- (void)pvWithCommand:(NSString *)cmd network:(int)network code:(int)code requestBytes:(int)reqBytes responseBytes:(int)respBytes responseTime:(int)respTime;

/**
 获取URL中的Command，比如http://m.api.dianping.com/shop.bin?id=1234的Command=m.api.dianping.com/shop.bin
 */
- (NSString *)commandWithUrl:(NSString *)url;

/**
 强制上传当前栈中的数据
 */
- (void)flush;

/**
 *  speedmonitor 获取unionId与version code
 *
 *  @return unionId && version code
 */
- (NSString *)getUnionId;

- (NSInteger)getVersionCode;

- (NSString *)platformString;

/**
 *  与speedmonitor统一host
 *
 *  @return host
 */
-(NSString *)serverHost;

@end
