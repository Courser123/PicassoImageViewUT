//
//  PicassoDebugMode.m
//  Pods
//
//  Created by Stephen Zhang on 16/6/27.
//
//

#import "NSString+JSON.h"
#import "PicassoDebugMode.h"
#import "RACDisposable.h"
#import "RACSignal.h"
#import "RACSubscriber.h"
#import "RACSignal+Operations.h"
#import "NSString+pcs_md5.h"
#import "NVNetherSwapHelper.h"
#import "NSObject+JSON.h"
#import "PicassoUtility.h"

@interface PicassoDebugMode()

@property (nonatomic, strong) RACDisposable *disposable;
@property (nonatomic, strong) NSString *cachedJsonResult;
@property (nonatomic, assign) BOOL debugModel;
@property (nonatomic, assign) BOOL mockServerEnable;
@property (nonatomic, copy) NSString *serverIP;
@property (nonatomic, strong) NSMutableArray <NSString *> *messageCacheArr;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) BOOL isRequesting;
@property (nonatomic, assign) BOOL onLiveLoad;

@end

@implementation PicassoDebugMode

+(PicassoDebugMode *)instance {
    if (![PicassoUtility isDebug]) {
        return nil;
    }
    static PicassoDebugMode * me = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        me = [PicassoDebugMode new];
    });
    return me;
}

- (instancetype)init {
    if (self = [super init]) {
        _messageCacheArr = [NSMutableArray new];
        _timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(printLog) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appResignActive) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}

- (void)appResignActive {
    [self.timer invalidate];
}

- (void)appEnterForeground {
    if (!self.timer.isValid) {
        self.timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(printLog) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    }
}

- (RACSignal *)fetchFile {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@:7777?md5=%@", self.serverIP?:@"127.0.0.1", [self.cachedJsonResult pcs_md5]]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:NSIntegerMax];
        NSURLSession *session =  [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:theRequest
                                                completionHandler:
                                      ^(NSData *data, NSURLResponse *response, NSError *error) {
                                          if (!error) {
                                              [subscriber sendNext:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
                                              [subscriber sendCompleted];

                                          } else {
                                              [subscriber sendError:error];
                                          }
                                      }];
        [task resume];
        return nil;
    }];
}

- (void)startMonitorWithIp:(NSString *)serverIp {
    self.onLiveLoad = YES;
    self.serverIP = serverIp;
    [self loadFile];
}

- (void)startMonitorWithToken:(NSString *)token {
    self.onLiveLoad = YES;
    self.debugModel = YES;
    self.mockServerEnable = YES;
    NVNetherSwapHelper  * swapHelper = [NVNetherSwapHelper instance];
    swapHelper.swapToken = token;
    [swapHelper swapDataFetched:^(NSString *swapData, NSError *error) {
        if (swapData.length > 0 && error == nil) {
            NSDictionary * resultDic = [swapData JSONValue];
            [[NSNotificationCenter defaultCenter] postNotificationName:PicassoDebugFileChangeNotification object:resultDic];
        }
    }];
}

- (void)loadFileAfter:(NSTimeInterval)interval {
    [[[RACSignal empty] delay:interval] subscribeCompleted:^{
        [self loadFile];
    }];
}

- (void)loadFile {
//    [self.disposable dispose];
    self.debugModel = YES;
    
    self.disposable = [[self fetchFile] subscribeNext:^(NSString *jsonResult) {
        if ([self.cachedJsonResult isEqualToString:jsonResult]) {
            [self loadFileAfter:0];
            return;
        }
        self.cachedJsonResult = jsonResult;
        NSDictionary *resultDic = [jsonResult JSONValue];
        [[NSNotificationCenter defaultCenter] postNotificationName:PicassoDebugFileChangeNotification object:resultDic];
        [self loadFileAfter:0];
        
    } error:^(NSError *error) {
        [self loadFileAfter:5];
    } completed:^{
        
    }];
}

- (void)closeFile {
    [self.disposable dispose];
    self.debugModel = NO;
}

- (void)printLog {
    if (self.isRequesting) {
        return;
    }
    if (self.messageCacheArr.count == 0) {
        return;
    }
    self.isRequesting = YES;
    NSMutableString *logStr = [NSMutableString new];
    for (NSString *log in self.messageCacheArr) {
        [logStr appendString:log];
        [logStr appendString:@"\n"];
    }
    [self.messageCacheArr removeAllObjects];
    [self sendRequestWithLogType:PicassoLogTagInfo content:logStr];
}

- (void)sendRequestWithLogType:(PicassoLogTag)type content:(NSString *)content {
    NSString * mockServerString = [NSString stringWithFormat:@"https://appmock.sankuai.com/appmockapi/netherswap/putback.api"];
    NSString * localServerString = [NSString stringWithFormat:@"http://%@:7776", self.serverIP ? : @"127.0.0.1"];
    NSURL * url = [NSURL URLWithString:self.mockServerEnable ? mockServerString : localServerString];
    NSMutableURLRequest * theRequest = [NSMutableURLRequest requestWithURL:url
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:NSIntegerMax];
    [theRequest setHTTPMethod:@"POST"];
    if (self.mockServerEnable) {
        NSString * data = [@{@"type":@(type).stringValue, @"message":content} JSONRepresentation];
        NSString * param = [NSString stringWithFormat:@"token=%@&data=%@", [NVNetherSwapHelper instance].swapToken, data];
        [theRequest setHTTPBody:[param dataUsingEncoding:NSUTF8StringEncoding]];
    } else {
        NSMutableDictionary *headers = [[NSMutableDictionary alloc] init];
        [headers setValue:[@(2) stringValue] forKey:@"type"];
        [theRequest setAllHTTPHeaderFields:headers];
        [theRequest setHTTPBody:[content dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [[[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]] dataTaskWithRequest:theRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        self.isRequesting = NO;
    }] resume];

}

- (void)logToPicassoServerWithType:(PicassoLogTag)type content:(NSString *)msg {
    if ([PicassoUtility isDebug]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (type == PicassoLogTagError) {
                [self sendRequestWithLogType:PicassoLogTagError content:msg];
            } else {
                [self.messageCacheArr addObject:(msg?:@"")];
                [self printLog];
            }
        });
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
