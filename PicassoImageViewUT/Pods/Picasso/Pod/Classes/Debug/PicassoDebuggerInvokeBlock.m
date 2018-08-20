//
//  PicassoDebuggerInvokeBlock.m
//  Picasso playground
//
//  Created by Zhidi Xia on 2018/4/3.
//  Copyright © 2018年 纪鹏. All rights reserved.
//

#import "PicassoDebuggerInvokeBlock.h"
#import "CTBlockDescription.h"
#import <JavaScriptCore/JSValue.h>
#import <JavaScriptCore/JSContext.h>

id invokeBlock(id block, NSArray *arguments) {
    CTBlockDescription *ct = [[CTBlockDescription alloc] initWithBlock:block];
    NSMethodSignature *methodSignature = ct.blockSignature;
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    
    [invocation setTarget:[block copy]];
    NSUInteger argsCount = methodSignature.numberOfArguments - 1;
    if (argsCount == arguments.count) {
        for (NSInteger i = 0; i < arguments.count; ++i) {
            id argu = arguments[i];
            [invocation setArgument:&argu atIndex:i + 1];
        }
        
        [invocation invoke];
        
        id returnVal;
        const char *type = methodSignature.methodReturnType;
        NSString *returnType = [NSString stringWithUTF8String:type];
        if ([returnType containsString:@"\""]) {
            type = [returnType substringToIndex:1].UTF8String;
        }
        if (strcmp(type, "@") == 0) {
            [invocation getReturnValue:&returnVal];
            NSLog(@"Websocket : 有返回值 %@", returnVal);
            if ([returnVal isKindOfClass:[JSValue class]]) {
                return [(JSValue *)returnVal description];
            }
            return returnVal;
        }
    }
    else {
        NSCAssert(NO, @"block要求参数数量与js传来参数数量不一致！");
    }
    return nil;
}


