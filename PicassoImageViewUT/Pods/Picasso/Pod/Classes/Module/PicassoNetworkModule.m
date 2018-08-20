//
//  PicassoNetworkModule.m
//  Pods
//
//  Created by 纪鹏 on 2017/6/4.
//
//

#import "PicassoNetworkModule.h"
#import "PicassoDefine.h"
#import "NSString+JSON.h"
#import "PicassoThreadManager.h"

@implementation PicassoNetworkModule

PCS_EXPORT_METHOD(@selector(fetch:callback:))

- (void)fetch:(NSDictionary *)params callback:(PicassoCallBack *)callback{
    if (![params isKindOfClass:[NSDictionary class]]) return;
    PCSRunOnMainThread(^{
        NSString *url = [params objectForKey:@"url"];
        NSString *method = params[@"method"];
        if (![method isKindOfClass:[NSString class]]) {
            method = @"GET";
        }
        
        NSDictionary *headerDic = params[@"headers"];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
        request.HTTPMethod = method;
        if ([headerDic isKindOfClass:[NSDictionary class]]) {
            for (NSString *header in headerDic.allKeys) {
                id value = [headerDic objectForKey:header];
                if ([value isKindOfClass:[NSNumber class]]) {
                    value = ((NSNumber *)value).stringValue;
                }
                if (![value isKindOfClass:[NSString class]]) {
                    continue;
                }
                [request setValue:value forHTTPHeaderField:header];
            }
        }
        NSString *bodyStr = params[@"body"];
        if ([bodyStr isKindOfClass:[NSString class]]) {
            NSData *body = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
            [request setHTTPBody:body];
        }
        
        [[[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (!error) {
                NSString *resString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSDictionary *resDic = @{
                                          @"data":(resString?:@""),
                                          @"status":@"success",
                                          @"statusCode":@(((NSHTTPURLResponse *)response).statusCode)
                                          };
                [callback sendSuccess:resDic];
            } else {
                [callback sendError:[PicassoError errorWithCode:0 msg:error.description customInfo:nil]];
            }
        }] resume];
    });
}

@end
