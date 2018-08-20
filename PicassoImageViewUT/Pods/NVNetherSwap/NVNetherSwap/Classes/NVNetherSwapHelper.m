//
//  NVNetherSwapHelper.m
//  Pods
//
//  Created by David on 2017/6/23.
//
//
//#ifdef DEBUG

#import "NVNetherSwapHelper.h"
#import "ReactiveCocoa.h"
#import "NSString+JSON.h"

@interface NVNetherSwapHelper()
@property (nonatomic, strong) RACDisposable *disposable;
@property (nonatomic, strong) NSString *uuid;
@end

@implementation NVNetherSwapHelper

+ (NVNetherSwapHelper *)instance {
    static NVNetherSwapHelper * helper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[NVNetherSwapHelper alloc] init];
    });
    return helper;
}

- (NSString *)uuid {
    if (!_uuid) {
        _uuid = [NSUUID UUID].UUIDString;
    }
    return _uuid;
}

- (RACSignal *)fetchSignalWithToken {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSURLSession * session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        NSString * paramter = [NSString stringWithFormat:@"token=%@&uuid=%@", self.swapToken, self.uuid];
        NSString * urlString = [@"https://appmock.sankuai.com/appmockapi/netherswap/get.api?" stringByAppendingString:paramter];
        [[session dataTaskWithURL:[NSURL URLWithString:urlString] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{//回调至主线程
                if (error == nil) {
                    NSString * result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    NSString * dataString = [result.JSONValue objectForKey:@"data"];
                    if (dataString.length > 0) {
                        [subscriber sendNext:dataString];
                    }
                }
                [subscriber sendCompleted];
            });
        }] resume];
        return nil;
    }];
}

- (void)swapDataFetched:(SwapDataFetched)swapDataFetched {
#if DEBUG || TEST
    [self.disposable dispose];
    self.disposable = [[[[self fetchSignalWithToken] repeat] doNext:^(NSString *result) {
        @try {
            if (result.length > 0) {
                swapDataFetched(result, nil);
            }else {
                swapDataFetched(result, [NSError errorWithDomain:@"fail with empty data" code:0 userInfo:nil]);
            }
        }
        @catch (NSException *exception) {
            swapDataFetched(nil, [NSError errorWithDomain:@"fail with exception" code:0 userInfo:nil]);
            NSLog(@"%@",exception);
        }
        @finally {
        }
    }] subscribeCompleted:^{
    }];
#endif
}

@end

//#endif
