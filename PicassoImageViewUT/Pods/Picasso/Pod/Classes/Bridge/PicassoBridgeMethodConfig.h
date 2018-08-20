//
//  PicassoModuleConfig.h
//  Pods
//
//  Created by 纪鹏 on 2017/5/19.
//
//

#import <Foundation/Foundation.h>

@interface PicassoBridgeMethodConfig : NSObject
- (instancetype)initWithBridgeClazz:(NSString *)clz;
- (SEL)selectorWithMethodName:(NSString *)name;
- (NSArray<NSString *> *)moduleMethods;
- (Class)getClass;

@end
