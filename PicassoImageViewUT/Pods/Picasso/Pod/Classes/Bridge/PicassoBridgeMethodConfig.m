//
//  PicassoModuleConfig.m
//  Pods
//
//  Created by 纪鹏 on 2017/5/19.
//
//

#import "PicassoBridgeMethodConfig.h"
#import <objc/runtime.h>

@interface PicassoBridgeMethodConfig ()
@property (atomic, strong) NSDictionary * methodsMap;
@property (nonatomic, strong) NSString *clz;
@end

@implementation PicassoBridgeMethodConfig

- (instancetype)initWithBridgeClazz:(NSString *)clz {
    if (self = [super init]) {
        _clz = clz;
        _methodsMap = [self loadMethods];
    }
    return self;
}

- (NSDictionary *)loadMethods {
    Class currentClass = NSClassFromString(self.clz);
    if (!currentClass) {
        return @{};
    }
    NSMutableDictionary *methodDic = [NSMutableDictionary new];
    while (currentClass != [NSObject class]) {
        unsigned int methodNumber = 0;
        Method *methodList = class_copyMethodList(object_getClass(currentClass), &methodNumber);
        for (unsigned int i = 0; i < methodNumber; i++) {
            NSString *selectorStr = [NSString stringWithCString:sel_getName(method_getName(methodList[i])) encoding:NSUTF8StringEncoding];
            if (![selectorStr hasPrefix:@"pcs_export_method_"]) {
                continue;
            }
            
            NSString *method = nil, *name = nil;
            SEL selector = NSSelectorFromString(selectorStr);
            if ([currentClass respondsToSelector:selector]) {
                method = ((NSString* (*)(id, SEL))[currentClass methodForSelector:selector])(currentClass, selector);
            }
            if (method.length == 0) {
                continue;
            }
            NSRange range = [method rangeOfString:@":"];
            if (range.location == NSNotFound) {
                name = method;
            } else {
                name = [method substringToIndex:range.location];
            }
            [methodDic setObject:method forKey:name];
        }
        free(methodList);
        currentClass = class_getSuperclass(currentClass);
    }
    return [methodDic copy];
}

- (SEL)selectorWithMethodName:(NSString *)name {
    if(name.length == 0) {
        return nil;
    }
    NSString *selStr = [self.methodsMap objectForKey:name];
    return NSSelectorFromString(selStr);
}

- (NSArray<NSString *> *)moduleMethods {
    return self.methodsMap.allKeys;
}

- (Class)getClass {
    return NSClassFromString(self.clz);
}

@end
