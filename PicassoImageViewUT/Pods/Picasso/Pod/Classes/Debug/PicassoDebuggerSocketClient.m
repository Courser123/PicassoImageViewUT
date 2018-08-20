//
//  PicassoDebuggerSocketClient.m
//  Picasso playground
//
//  Created by Zhidi Xia on 2018/3/26.
//  Copyright © 2018年 纪鹏. All rights reserved.
//

#import "PicassoDebuggerSocketClient.h"
#import "SocketRocket.h"
#import "NSObject+JSON.h"
#import "NSString+JSON.h"
#import "PicassoDebuggerInvokeBlock.h"
#import "PicassoDebuggerSelectHelper.h"

typedef void (^PicassoWebSocketCallbackBlock)(id result, NSError *error);

@interface PicassoDebuggerSocketClient () <SRWebSocketDelegate>

@property (nonatomic, strong) SRWebSocket *socket;
@property (nonatomic, strong) NSMutableDictionary <NSNumber *, PicassoWebSocketCallbackBlock> *callbacks;

@property (nonatomic, strong) dispatch_queue_t jsQueue;

@end

@implementation PicassoDebuggerSocketClient

- (instancetype)init
{
    self = [super init];
    if (self) {
        _callbacks = [NSMutableDictionary dictionary];
        [self setup];
    }
    return self;
}

- (void)setup
{
    _jsQueue = dispatch_queue_create("com.dianping.picasso.WebSocketExecutor", DISPATCH_QUEUE_SERIAL);
    NSString *ip = [PicassoDebuggerSelectHelper helper].serverIP;
    if (ip.length > 0) {
        NSString *urlString = [NSString stringWithFormat:@"ws://%@:8880/app", ip];
        _socket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
    }
    else {
        _socket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"ws://localhost:8880/app"]]];
    }
    
    _socket.delegate = self;   //SRWebSocketDelegate 协议
    _socket.delegateDispatchQueue = self.jsQueue;
    
    [_socket open];     //开始连接
}

- (void)sendMessage:(NSDictionary<NSString *, id> *)message callbackBlock:(PicassoWebSocketCallbackBlock)callbackBlock
{
    static NSUInteger lastID = 100000;
    dispatch_async(_jsQueue, ^{

        NSString *currentID = [NSString stringWithFormat:@"%@", @(lastID++)];
        if (callbackBlock) {
            self.callbacks[currentID] = [callbackBlock copy];
        }

        NSMutableDictionary<NSString *, id> *messageWithID = [message mutableCopy];
        messageWithID[@"id"] = currentID;
        [self.socket sendString:[messageWithID JSONRepresentation] error:nil];
        
    });
}

/**
 发送单程消息，不需要回复

 */
- (void)sendOneWayMessage:(NSDictionary<NSString *, id> *)message
{
//    [self.socket sendString:[message JSONRepresentation] error:nil];
    [self sendMessage:message callbackBlock:NULL];
}

#pragma mark - Picasso Protocal

- (void)executeScript:(nonnull NSString *)script
                 name:(nonnull NSString *)name
        completeBlock:(PicassoJavaScriptCompleteBlock)completeBlock
{
//    dispatch_semaphore_t scriptSem = dispatch_semaphore_create(0);
    
    NSDictionary<NSString *, id> *message = @{
                                              @"method": @"executeScript",
                                              @"content": script,
                                              @"name": name
                                              };
    
    [self sendMessage:message callbackBlock:^(id result, NSError *error) {
//        NSLog(@"Websocket :收到Mess回复 %@", result);
        completeBlock(error);
//        dispatch_semaphore_signal(scriptSem);
    }];
//    dispatch_semaphore_wait(scriptSem, DISPATCH_TIME_FOREVER);
}

- (void)executeJSCall:(NSString *)method arguments:(NSArray *)arguments callback:(PicassoJavaScriptCallbackBlock)callbackBlock
{
    NSDictionary<NSString *, id> *message = @{
                                              @"method": method,
                                              @"arguments": arguments
                                              };
    [self sendMessage:message
        callbackBlock:^(id result, NSError *error) {
            NSLog(@"Websocket :收到方法执行回复 %@", result);
            callbackBlock(result, error);
        }];
}

- (void)injectJSFunction:(NSString *)function withBlock:(id)block
{
    
    [self sendMessage:@{
                        @"method": @"injectFunction",
                        @"injectFunction": @{function: @""}
                        }
        callbackBlock:^(id result, NSError *error) {
            NSLog(@"Websocket :收到bindJSFunction回复 %@", result);
            NSArray *arguments = result[@"arguments"];
            id blockResult = invokeBlock(block, arguments);
            
            NSLog(@"Websocket : block执行结果：%@", blockResult);
            [self sendOneWayMessage:@{@"injectId": result[@"injectId"] ?: @"",
                                      @"method": @"injectFunctionResult",
                                      @"result": blockResult ?: @""
                                      }];
        }];
}

- (void)injectJSConstWithDictionary:(NSDictionary *)dictionory
{
    NSDictionary<NSString *, id> *message = @{
                                              @"method": @"injectConst",
                                              @"inject": dictionory
                                              };
    
    [self sendMessage:message callbackBlock:^(id result, NSError *error) {
        NSLog(@"Websocket : injectJSConst %@", result);
    }];
}

#pragma mark - SRWebSocket Delegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
    NSLog(@"Websocket :Websocket Connected");
    
    NSDictionary *message1 = @{@"method" : @"prepareJSRuntime"
                               };
    [self sendMessage:message1 callbackBlock:^(id result, NSError *error) {
        NSLog(@"Websocket :开启调试模式成功");
    }];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
    NSLog(@"Websocket :( Websocket Failed With Error %@", error);
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessageWithString:(nonnull NSString *)string
{
    NSLog(@"Websocket Received \"%@\"", string);
    NSDictionary *receive = string.JSONValue;
    
    NSNumber *messageID = receive[@"id"];
    PicassoWebSocketCallbackBlock callback = self.callbacks[messageID];
    if (callback) {
        callback(receive[@"result"] ?: @"", receive[@"error"] ?: @"");
        
        NSDictionary *result = receive[@"result"];
        
//        如果不是inject的function回调，那么不能从block数组中移除对应block。因为inject的function回调可能会有N次。
        if (![result isKindOfClass:[NSDictionary class]] || ![[result objectForKey:@"type"] isEqual:@"inject"]) {
            [self.callbacks removeObjectForKey:messageID];
        }
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
    NSLog(@"Websocket WebSocket closed");
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload;
{
    NSLog(@"WebSocket received pong");
}


@end
