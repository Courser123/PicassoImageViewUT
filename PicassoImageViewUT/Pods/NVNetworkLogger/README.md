# NVNetworkLogger

[![CI Status](http://img.shields.io/travis/xiangnan.yang/NVNetworkLogger.svg?style=flat)](https://travis-ci.org/xiangnan.yang/NVNetworkLogger)
[![Version](https://img.shields.io/cocoapods/v/NVNetworkLogger.svg?style=flat)](http://cocoapods.org/pods/NVNetworkLogger)
[![License](https://img.shields.io/cocoapods/l/NVNetworkLogger.svg?style=flat)](http://cocoapods.org/pods/NVNetworkLogger)
[![Platform](https://img.shields.io/cocoapods/p/NVNetworkLogger.svg?style=flat)](http://cocoapods.org/pods/NVNetworkLogger)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

NVNetworkLogger is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "NVNetworkLogger"
```

## Author

xiangnan.yang, xiangnan.yang@dianping.com

## License

NVNetworkLogger is available under the DP license. See the LICENSE file for more info.

##Versions
**5.5.4** 支持linker
**5.5.3** 支持qb
**5.5.1 5.5.2**解决编译警告
**5.5.0**日志的写入增加tags
**5.4.23** 增大七天内日志大小精度，保留至小数点后二位。
**5.4.20 21 22** 北京侧发版本
**5.4.19** 添加大象SDK日志类型
**5.4.18** 日志中增加文件大小，buildID
**5.4.17** 处理内存泄漏
**5.4.16** 删除上报域名为beta环境
**5.4.15** 判空处理
**5.4.14** 处理了主动上报接口后端返回的返回码
**5.4.13** fix bug
**5.4.11** 优化了减少上报次数的逻辑，调整了主动上报的接口
**5.4.10** logan上报新增参数appVersion
**5.4.9** 完善了减少主动上报次数的逻辑
**5.4.6** 完成了logan减少上报次数的逻辑
**5.4.5** 修改了主动上报新接口的参数，声明其他接口为准备废弃状态
**5.4.4** fix bug
**5.4.3** 新增了logan的环境变量规范
**5.4.2** 修改接口，美团app引用了下掉的接口

**5.3.41**删除了logan环境变量的代码
**5.3.40**调整了主动上报环境变量的格式
**5.3.9**升级clogan加密

**5.3.8**修复了app跨天存活后日志会被写入前一天日志文件，当天日志为空的问题。

**5.3.3**修复了app跨天存活后日志会被写入前一天日志文件，当天日志为空的问题。

**5.2.7**修改检查剩余空间的方式

**5.2.6**修改配置拉取方式。静态检查修复

**5.2.3**增加CLogan库。

**5.0.16**每条日志增加本地时间。去除主动上报前的状态上报。

**5.0.14 5.0.15**正式发版。从Shark日志升级为Logan，参见wiki：https://wiki.sankuai.com/pages/viewpage.action?pageId=842132382

**3.1.6**发版

**3.1.5.3**移除nnlog

**3.1.5.2**静态检查修复

**3.1.5**logan提测版本

**3.1.4**升级版本号，通过检查

**3.1.3.1****3.1.3.2**测试版本

**3.1.3**版本适配，临时版本

**3.1.2**https

**3.1.1** 版本对齐

**0.1.5**bug fix

**0.1.4**pass lint

**0.1.3**nova测试

**0.1.2**新增log的宏定义

**0.1.1**测试


