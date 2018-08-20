//
//  SharkPushLinkerProtocol.h
//  Pods
//
//  Created by JiangTeng on 2018/2/28.
//

#ifndef SharkPushLinkerProtocol_h
#define SharkPushLinkerProtocol_h

#define SharkPushLinkerCalssString @"SharkPushManager"

/**
 SharkPush解藕协议，该协议只是简单的发送请求，更多功能的请使用sharkpush。
 */
@protocol SharkPushLinkerProtocol <NSObject>

/**
 
 @param cmd 注册命令字
 @param queue 回调queue
 @param callBack 回调
 */
- (void)registerCmd:(NSString *)cmd
      callBackQueue:(dispatch_queue_t)queue
           callBack:(void(^)(NSData *data))callBack;

@end
#endif /* SharkPushLinkerProtocol_h */
