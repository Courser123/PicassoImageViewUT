//
//  PicassoModuleFactory.h
//  Pods
//
//  Created by 纪鹏 on 2017/5/11.
//
//

#import <Foundation/Foundation.h>

@interface PicassoModuleFactory : NSObject

+ (NSDictionary *)loadedModules;

+ (SEL)selectorWithModule:(NSString *)module method:(NSString *)method;

+ (Class)classForModuleName:(NSString *)name;

@end
