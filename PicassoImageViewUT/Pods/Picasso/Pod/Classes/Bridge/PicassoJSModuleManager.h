//
//  PicassoJSModuleManager.h
//  CocoaAsyncSocket
//
//  Created by 纪鹏 on 2017/8/21.
//

#import <Foundation/Foundation.h>

@interface PicassoJSModuleManager : NSObject

+ (void)registerJSModuleWithName:(NSString *)name jsScript:(NSString *)script;

+ (NSString *)jsScriptForModuleName:(NSString *)name;

@end
