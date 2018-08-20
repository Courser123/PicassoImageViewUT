//
//  PicassoInput.m
//  Pods
//
//  Created by Stephen Zhang on 16/9/22.
//
//

#import "PicassoInput.h"
#import "PicassoJSContext.h"
#import "PicassoModel.h"
#import "RACSignal.h"
#import "RACSubscriber.h"
#import "PicassoViewModel.h"
#import "PicassoDebugMode.h"
#import "NVCodeLogger.h"
#import "PicassoThreadManager.h"
#import "PicassoUtility.h"
#import "PicassoDefine.h"

@interface PicassoJSContext (private)

@property (nonatomic, strong) NSMutableDictionary * evaluatedJsDic;

@end

@interface PicassoInput ()

@property (nonatomic, strong) PicassoViewModel *model;

@end

@implementation PicassoInput

- (void)preCompute {
    PCSAssertViewComputeThread();
    if (self.width && self.jsName.length) {
        PicassoJSContext *jsContext = [PicassoJSContext defaultJSContext];
        NSString *evaluatedJs = [jsContext.evaluatedJsDic objectForKey:self.jsName];
        
        if (self.jsContent.length && ![evaluatedJs isEqualToString:self.jsContent]) {
            NSString *js = self.jsContent;
            [jsContext.evaluatedJsDic setObject:self.jsContent forKey:self.jsName];
            
            if (self.jsContextInject) {
                NSString *injectJs = [NSString stringWithFormat:@"%@.context=%@", self.jsName, [self jsonStrFromDic:self.jsContextInject]];
                js = [NSString stringWithFormat:@"%@\n%@",self.jsContent, injectJs];
            }
            [jsContext evaluateScript:js withSourceURL:[NSURL URLWithString:self.jsName]];
        }
        NSString *jsString = [NSString stringWithFormat:@"%@.layout(%@,%@,%@).info();", self.jsName, [self getArgs], self.jsonData?:@"{}", [self jsonStrFromDic:self.jsContextInject]];
        self.isComputeSuccess = true;
        __weak typeof(self) weakself = self;
        jsContext.exceptionHandler = ^(JSContext *context, JSValue *exception) {
            context.exception = exception;
            weakself.isComputeSuccess = false;
            NSString *errorStr = [PicassoUtility errorStringWithException:exception];
            weakself.error = [[NSError alloc] initWithDomain:@"jsExcuteError" code:-101 userInfo:@{@"errorInfo":errorStr}];
            NVAssert(false, @"PicassoInput jsname:%@ error, %@", weakself.jsName, errorStr);
            [[PicassoDebugMode instance] logToPicassoServerWithType:PicassoLogTagError content:errorStr];
        };
        JSValue *value = [jsContext evaluateScript:jsString];
        NSDictionary *dic = [value toDictionary];
        self.model = [PicassoViewModel modelWithDictionary:dic];
    }
}

- (NSString *)jsonStrFromDic:(NSDictionary *)dic {
    if (![dic isKindOfClass:[NSDictionary class]]) {
        return @"{}";
    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

- (NSString *)getArgs {
    return [NSString stringWithFormat:@"{\"width\":%@,\"height\":%@}",@(self.width),@(self.height)];
}

- (RACSignal *)computeSignal {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        PCSRunOnViewComputeThread(^{
            [self preCompute];
            PCSRunOnMainThread(^{
                [subscriber sendNext:self];
                [subscriber sendCompleted];
            });
        });
        return nil;
    }];
}

+ (RACSignal *)computeWithInputArray:(NSArray<PicassoInput *> *)inputArray {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        PCSRunOnViewComputeThread(^{
            for (PicassoInput * input in inputArray) {
                [input preCompute];
            }
            PCSRunOnMainThread(^{
                [subscriber sendNext:inputArray];
                [subscriber sendCompleted];
            });
        });
        return nil;
    }];
}

- (PicassoModel *)getPModel {
    return self.model;
}

@end

