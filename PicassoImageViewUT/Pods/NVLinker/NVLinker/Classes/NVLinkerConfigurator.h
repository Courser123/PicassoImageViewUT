//
//  NVLinkerConfigurator.h
//  NVLinker
//
//  Created by JiangTeng on 2018/2/27.
//

#import <Foundation/Foundation.h>

@interface NVLinkerConfigurator : NSObject
// 以下参数,请不要重复设置,避免多线程隐患
/**
 appid 区分不同app,必须设置，否则将会命中断言。
 首次接入请联系hui.zhou申请。
 */
@property (nonatomic, assign) NSInteger appID;

/**
 设备唯一标识，必须设置，否则将会命中断言。
 */
@property (nonatomic, copy, nullable) NSString * _Nullable (^unionIDBlock)(void);

+ (NVLinkerConfigurator *_Nonnull)configurator;

/**
 设备唯一标识
 */
- (NSString *_Nullable)unionID;
@end
