//
//  PicassoModuleMethod.h
//  Pods
//
//  Created by 纪鹏 on 2017/5/11.
//
//
#import <JavaScriptCore/JavaScriptCore.h>

@interface PicassoModuleMethod : NSObject

- (instancetype)initWithHost:(NSString *)hostId module:(NSString *)moduleName method:(NSString *)methodName arguments:(NSDictionary *)args callback:(NSString *)callbackId;
- (JSValue *)invoke;
@end
