//
//  SwitcherTask.m
//  Pods
//
//  Created by lmc on 2017/1/10.
//
//

#import "SwitcherTask.h"

@interface SwitcherTask () <NSURLSessionDataDelegate, NSURLSessionTaskDelegate>

@property (nonatomic, strong) NSMutableData *mutableData;

@end

@implementation SwitcherTask

+ (id)task {
    return [[self alloc] init];
}

- (id)init{
    self = [super init];
    if (self) {
        _mutableData = [NSMutableData data];
    }
    return self;
}

- (void)startRequest {
    [self request];
}

- (void)request {
    NSURL *url = [NSURL URLWithString:self.url];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:20];
    [request setHTTPMethod:@"GET"];
    if (self.parameters.allKeys.count > 0) {
        for (NSString *keyStr in self.parameters.allKeys) {
            NSString *value = [self.parameters objectForKey:keyStr];
            [request addValue:value forHTTPHeaderField:keyStr];
        }
    }
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
    [task resume];
}

#pragma mark - NSURLSessionDataDelegate && NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [self.mutableData appendData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error) {
        if (self.fail) {
            self.fail(self, error);
        }
    }else {
        
        NSData *data = nil;
        if (self.mutableData) {
            data = [NSData dataWithData:self.mutableData];
            self.mutableData = [NSMutableData data];
        }
        
        if (self.success) {
            self.success(self, data);
        }
    }
}

- (BOOL)isDebug {
    BOOL isdebug;
#ifdef DEBUG
    isdebug = YES;
#else
    isdebug = NO;
#endif
    
    return isdebug;
}

@end
