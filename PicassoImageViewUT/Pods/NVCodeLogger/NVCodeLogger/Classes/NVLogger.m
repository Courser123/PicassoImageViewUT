//
//  NVLogger.m
//  Pods
//
//  Created by MengWang on 16/5/11.
//
//
#import "NVLogDiskManager.h"
#import "NVLogger.h"
#import "NVCodeLogger.h"

@interface NVLogger()
@end

@implementation NVLogger

+ (void)installWithAppID:(NSString*)appID LoggerParams:(LoggerParams)loggerParams {
    if ([NVLogDiskManager sharedInstance].appID.length != 0) {
        NVLog(@"NVLogger已经初始化过，appID=%@,不要重复多次初始化...",[NVLogDiskManager sharedInstance].appID);
        return;
    }
    
    [NVLogDiskManager sharedInstance].loggerParams = loggerParams;
    [NVLogDiskManager sharedInstance].appID = appID;
}

+ (void)queryLogs:(NSUInteger)count withBlock:(void(^)(NSArray *))block {
    [[NVLogDiskManager sharedInstance] queryLogs:count withBlock:block];
}

+ (NSArray *)querySyncLogs:(NSUInteger)count {
    return [[NVLogDiskManager sharedInstance] querySyncLogs:count];
}

#pragma mark - NvLog

void __cacheNvLog(const char * file, NSInteger line, const char * func, NSString * format, ...) {
    va_list args;
    va_start(args, format);
    NSString *formatStr = [[NSString alloc] initWithFormat:format arguments:args];
    
    __cacheNvLoggers(file, line, func, nil, formatStr);
    
    va_end(args);
}

void __cacheNvLogWithTags(const char * file, NSInteger line, const char * func, NSArray<NSString *> *tags, NSString * format, ...) {
    va_list args;
    va_start(args, format);
    NSString *formatStr = [[NSString alloc] initWithFormat:format arguments:args];
    
    __cacheNvLoggers(file, line, func, tags, formatStr);
    
    va_end(args);
}

void __cacheNvLoggers(const char * file, NSInteger line, const char * func, NSArray<NSString *> *tags, NSString * formatStr) {
    NSLog(@"<%s : line %@> %@", [[[NSString stringWithUTF8String:file] lastPathComponent] UTF8String], @(line), formatStr);
    
    NSString *category = [NSString stringWithFormat:@"%s %@",[[[NSString stringWithUTF8String:file] lastPathComponent] UTF8String], @(line)];
    formatStr = [NSString stringWithFormat:@"<%s : line %@> func:%@ log:%@\n",[[[NSString stringWithUTF8String:file] lastPathComponent] UTF8String], @(line), [NSString stringWithUTF8String:func] , formatStr];
    
    //write cache
    [NVLogDiskManager cachePrintLog:formatStr withCategory:category andTags:tags];
}

#pragma mark - NvAssert

extern void __cacheNvAssert(const char * file, NSInteger line, const char * func, NSString * desc, ...) {
    va_list args;
    va_start(args, desc);
    NSString *formatStr = [[NSString alloc] initWithFormat:desc arguments:args];
    
    __cacheNvAssertLogger(file, line, func, ^NSString *() {
        return @"";
    }, false, desc, formatStr);
    
    va_end(args);
}

void __cacheNvAssertModule(const char * file, NSInteger line, const char * func, NVAssertModuleBlock moduleBlock, NSString * desc, ...) {
    va_list args;
    va_start(args, desc);
    NSString *formatStr = [[NSString alloc] initWithFormat:desc arguments:args];
    
    __cacheNvAssertLogger(file, line, func, moduleBlock, false, desc, formatStr);
    
    va_end(args);
}

void __cacheNvAssertModuleWithoutStack(const char * file, NSInteger line, const char * func, NSString * desc, ...) {
    va_list args;
    va_start(args, desc);
    NSString *formatStr = [[NSString alloc] initWithFormat:desc arguments:args];
    
    __cacheNvAssertLogger(file, line, func, nil, false, desc, formatStr);
    
    va_end(args);
}

extern void __cacheNvAssertCustomPartCategory(const char * file, NSInteger line, const char * func, NVAssertModuleBlock moduleBlock, NSString * categoryDesc, NSString * logDesc) {
    
    __cacheNvAssertLogger(file, line, func, moduleBlock, false, categoryDesc, logDesc);
}

void __cacheNvAssertLogger(const char * file, NSInteger line, const char * func, NVAssertModuleBlock moduleBlock, bool isShowLogInCategory, NSString * desc, NSString * formatStr) {
    
    NSString *classStr = [NSString stringWithFormat:@"%s",[[[NSString stringWithUTF8String:file] lastPathComponent] UTF8String]];
    NSString *moduleStr = @"";
    
    if (moduleBlock) {
        moduleStr = moduleBlock();
        
        if (moduleStr.length == 0 || !NSClassFromString(moduleStr)) {
            moduleStr = nil;
        }
        
        if (moduleStr.length == 0) {
            if ([classStr hasSuffix:@".h"]) {
                moduleStr = [classStr stringByReplacingOccurrencesOfString:@".h" withString:@""];
            }else if ([classStr hasSuffix:@".m"]) {
                moduleStr = [classStr stringByReplacingOccurrencesOfString:@".m" withString:@""];
            }
        }
        
    }else {
        // get caller
        NSArray *callStack = [NSThread callStackSymbols];
        do {
            if (callStack.count < 2) {
                break;
            }
            
            NSString *caller;
            NSString *orgStack = callStack[2];
            NSArray *components = [orgStack componentsSeparatedByString:@"0x"];
            do {
                if (components.count <= 1) {
                    break;
                }
                
                caller = components[1];
                if (caller.length == 0 || [caller rangeOfString:@"["].location == NSNotFound) {
                    break;
                }
                
                components = [caller componentsSeparatedByString:@"["];
                if (components.count <= 1) {
                    break;
                }
                
                caller = components[1];
                caller = [caller stringByReplacingOccurrencesOfString:@"(" withString:@"+"];
                caller = [caller stringByReplacingOccurrencesOfString:@")" withString:@""];
                
                
            }while(0);
            
            moduleStr = caller;
            
        }while(0);
    }
    
    NSString *logStr = [NSString stringWithFormat:@"<%@ : line %@> func:%s log:%@\n",classStr, @(line), func , formatStr];
    NSString *categoryStr = [NSString stringWithFormat:@"%@ %@",classStr, @(line)];
    if (isShowLogInCategory) {
        categoryStr = [NSString stringWithFormat:@"%@ %@", categoryStr, formatStr];
    }else {
        categoryStr = [NSString stringWithFormat:@"%@ %@", categoryStr, desc];
    }
    NSString *keyStr = [NSString stringWithFormat:@"%@ %@",classStr, @(line)];
    
    if (logStr.length) {
        NSLog(@"%@",logStr);
    }
    
    // write assert cache
    [NVLogDiskManager cacheAssertLog:logStr withCategory:categoryStr withModuleClass:moduleStr withKey:keyStr];
    
}

@end
