## NVMonitorCenter
NVMonitorCenter是网络端到端监控的上报组件。  
项目地址：[http://code.dianpingoa.com/mobile/nvmonitorcenter][1]  

**文件说明**  

- MonitorDemo.xcworkspace：demo工程。
- Monitor文件夹：NVMonitorCenter的主要代码。
- MonitorDemo/ViewController.m：测试代码位于ViewDidLoad方法中。
**使用说明**  

NVMonitorCenter类是单例类，使用前需要先进行配置。  
配置代码如下：(初始化代码位于MonitorDemo/ViewController/ViewDidLoad)  

	// NVMonitorCenter配置参数
	NVMonitorCenter *monitor = [NVMonitorCenter defaultCenter];
	[monitor setServerHost:@"catdot.dianping.com"];
	[monitor setappID:1];
	[monitor setDPIDBlock:^NSString *{
	    // 设置DPID。由于dpid会变动，而且没有变动通知，所以需要放在Block中进行获取
	    return [[NVEnvironment defaultEnvironment] dpid];
	}];
初始化代码中必须设置
   * 服务器Host(setServerHost:)
   * DPID的获取方法(setDPIDBlock:)
   * app前给定相关app的appID：详情地址：[http://code.dianpingoa.com/mobile/nvmonitorcenter][2]
初始化后，NVMonitorCenter即可上传网络监控数据。

	[[NVMonitorCenter defaultCenter] pvWithCommand:@"mapi.dianping.com/mapi/networktunnel.bin" network:0 code:200 tunnel:0 requestBytes:1 responseBytes:1 responseTime:100 ip:nil]; 
 
接口和参数说明：  

	/**
	 * API访问的PV日志
	 *
	 * @param command
	 *            标示符，一般用url中"域名/path"表示，如“mapi.dianping.com/mapi/networktunnel.bin|networktunnel.bin”
	 * @param network
	 *            网络类型，1=Wifi，2=2G，3=3G，4=4G。传0表示自动检测当前网络状态
	 * @param code
	 *            状态码，>1000表示业务错误码，<0表示自定义错误码，其余使用HTTP状态码
	 * @param tunnel
	 *            连接通道，0为短连，1为点评自研长连，2为UDP，4为WNS长连通道，8为HTTPS通道
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
	 */
	- (void)pvWithCommand:(NSString *)cmd network:(int)network code:(int)code tunnel:(int)tunnel requestBytes:(int)reqBytes responseBytes:(int)respBytes responseTime:(int)respTime ip:(NSString *)ip uploadPercent:(int)uploadPercent;
 

## NVSpeedMonitor

**文件说明**  

- MonitorDemo.xcworkspace：demo工程。
- Monitor文件夹：NVSpeedMonitor的主要代码。
- MonitorDemo/SpeedMonitorViewController.m：测试代码位于ViewDidLoad方法中。
**使用说明**  

NVSpeedMonitor使用前需要先进行配置页面名称。(可以手动设置上报开始时间，默认类初始化时时间戳)
配置代码如下：(初始化代码位于MonitorDemo/SpeedMonitorViewController/ViewDidLoad)  

```
// NVSpeedMonitor配置参数
-(void)viewDidLoad{
    [super viewDidLoad];
    //服务器地址将自动从NVMonitorCenter中抓取
    self.speedMonitor = [[NVSpeedMonitor alloc] initWithPageName:@"shopinfo"];
}
//可以在某些特定时刻打点，设置超时时间
-(void)viewDidAppear:(BOOL)animated{
    [self.speedMonitor catRecord:1 maxInterval:30];
}
//页面退出时上报
-(void)dealloc{
    [self.speedMonitor catEnd];
}    
```
 
初始化代码中必须设置

   * 使用前需确保NVMonitorCenter已创建，NVSpeedMonitor从NVMonitorCenter获取配置信息，包括host，dpid等
接口和参数说明：  

```
/**
 *  初始化monitor，获取当前时间为starttime
 *
 *  @param page 设置pagename
 *
 *  @return NVSpeedMonitor
 */
- (instancetype)initWithPageName:(NSString *)page;

/**
 *  初始化monitor
 *
 *  @param page 设置pagename
 *
 * @param time 设置手动指定时间
 *
 *  @return NVSpeedMonitor
 */
- (instancetype)initWithPageName:(NSString *)page time:(NSInteger)time;

/**
 *  上报特殊时间点，与初始化时间拼接上传
 *
 *  @param modelIndex 约定每个时间点的index
 */
- (void)catRecord:(NSInteger)modelIndex;

/**
 *  同上
 *  @param maxInterval 超时，超过该时间不上报
 */
- (void)catRecord:(NSInteger)modelIndex maxInterval:(NSTimeInterval)maxInterval;

/**
 *  上报
 */
- (void)catEnd;    
```

## NVMetricsMonitor
自定义字段的上报，参见http://wiki.sankuai.com/pages/viewpage.action?pageId=531467789 
Metrics日志收集的说明，参见http://wiki.sankuai.com/pages/viewpage.action?pageId=227147888
**文件说明**  
- MonitorDemo.xcworkspace：demo工程。
- Monitor文件夹：NVMetricsMonitor的主要代码。
- MonitorDemo/MetricsMonitorViewController.m：测试代码位于ViewDidLoad方法中。

**使用说明**  
NVMetricsMonitor使用前不需要进行任何设置。  
可以填加两类数据：kvs和tags，kvs是NSNumber型的键值对，tags是NSString型的键值对。
kvs提供了单个数值和多个数值的添加方法。

接口和参数说明： 

```
/**
 * 添加kvs字段，必须为NSNumber型的数据
 */
- (void)addValue:(NSNumber *)value forKey:(NSString *)key;
/**
 * 添加一组kvs字段，必须为NSNumber型的数组数据
 */
- (void)addValues:(NSArray<NSNumber *> *)values forKey:(NSString *)key;

/**
 * 添加tag字段，tag必须为NSString类型
 */
- (void)addTag:(NSString *)tag forKey:(NSString *)key;

/**
 * 上报数据.
 * 上报的服务器地址配置于NVMonitorCenter中(setServerHost:).
 * NVMetricsMonitor为一次性上报的对象，不建议复用
 */
- (void)send;
```

## NVDNSMonitor
被劫持的ip上报，需要在    NVMonitorCenter 中设置时间限制，控制每个url上报间隔，默认5分钟

**文件说明**
NVDNSMonitor.m

```
//域名和iplist
- (void)sendHiJackedUrl:(NSString *)hiJackedUrl WithIpList:(NSString *)host;

```

## 更新说明
**2.3.25,2.3.26** 替换sharedsession

**2.3.24** 自定义监控增加appid及extra设置

**2.3.23** hasprefix crash修复

**2.3.22** 野指针保护

**2.3.21** dnsmonitor初始化时间bugfix

**2.3.20** 自定义增加unionid，dns增加采样

**2.3.17,2.3.18,2.3.19** dns劫持解控增加pagename

**2.3.16** 添加天网监控

**2.3.13** 修改cat，增加本地记录

**2.3.4** cmd读配置时，强转为小写

**2.3.3** 修复采样上报bug.

**2.3.1** add beta api

**2.2.3**添加底层开关拉取配置的支持

**2.2.1**上报请求禁用cookies

**2.2.0**修改Logan日志，增加LoganCrash

**2.1.6,2.1.7**update plantform version to 8.0

**2.1.4,2.1.5**add logan

**2.1.3**逻辑优化

**2.1.2.2**NVSpeedMonitor增加线程安全保护

**2.1.2.1**NVSpeedMonitor更改参数类型

**2.1.2**将DNS劫持上报改成批量上报

**2.1.1.21**修复随机数的生成，补充注释

**2.1.1.20**实时读取sampleconfig

**2.1.1.19**sampleconfig

**2.1.1.18**多线程加锁

**2.1.1.17**堆栈上报新增category字段

**2.1.1.15,2.1.1.16**pass lint

**2.1.1.14**开关接口变更

**2.1.1.13**多线程处理

** 2.1.1.12**crash修复

**2.1.1.11**移除speedconfig

**2.1.1.10**customdata部分增加系统版本

**2.1.1.9**https支持

**2.1.1.7****2.1.1.8**logswitch 初始化

**2.1.1.6**移除配置拉取请求

**2.1.1.5** add appid & unionid  assert

**2.1.1.4**failovermonitor 问题修复

**2.1.1.2,2.1.1.3** fix crash

**2.1.1.1** 暴露crashlimit

**2.1.1**增加堆栈上报查询当前上报次数

**2.1.0.9**新增测速config拉取，冷启动拉取一次

**2.1.0.8**端到端增加content-encoding gzip

**2.1.0.7**取消设置host功能，直接内置

**2.1.0.6**修复upload线程问题

**2.1.0.5**host bug fix

**2.1.0.4**remove observer to pass lint

**2.1.0.3** serverUrl初始化时机

**2.1.0.2**配送事业部，多线程时序修改

**2.1.0.1**bug修复

**2.1.0**测试，demo完善

**2.0.16、17、18**解决合并代码问题

**2.0.15**增加crash频次限制
新增dns劫持监控

**2.0.14**
自定义上报重新设计接口
页面测速支持自定义时间

**2.0.13**删除测试代码

**2.0.12**端到端增加gzip，页面测速增加2个字段，新增crash堆栈上报

**2.0.11**- 去掉上报失败重试。
- 增加log开关，`+ (void)isDebug:(BOOL)isDebug;`默认不开启

**2.0.10**
- 调试Metrics数据，2.0.9版本上报的数据不对

**2.0.9**
- 增加NVMetricsMonitor，提供自定义上报
- 修正端到端、测速和自定义上报的Header字段ContentType，之前键值对写反了

**2.0.8**
- merge代码

**2.0.7**
- interface changed:接口定义规范化。

**2.0.6**
- bugfix：reportSwitcher = NO，清除buffer里的数据。

**2.0.5**
- 引入LogReportSwitcher库，对cat上报可动态线上配置

**2.0.4**
- 修改commandWithUrl:方法，获取URLString中的Command，比如http://m.api.dianping.com/shop.bin?id=1234的Command=m.api.dianping.com/shop.bin

**2.0.2**
- 升级上报版本号，v=3升级为v=4

**2.0.1**
- 修改版本号获取方式，之前获取的是build号，改成Short Version
- 版本号算法的修改，为兼容更多位数的版本号
	- 类似`6.15.8`这样的版本号之前会返回`658`,更改后会返回`6158`

**2.0.0**   
- 上报字段中增加extend自定义字段，便于个案查询

**0.1.8** 
- bugfix：如果修改serverHost，可能会导致url没有发生变化。

**0.1.5** 
- 程序退出时立即上报一次

**0.1.4**
- 增加NVSpeedMonitor
- 修改接口，配置serverhost
- 修改demo



[1]:	http://
[2]:	http://

