//
//  SharkLinkerProtocol.h
//  Pods
//
//  Created by JiangTeng on 2018/2/28.
//

#ifndef SharkLinkerProtocol_h
#define SharkLinkerProtocol_h

#define SharkLinkerCalssString @"NVSharkManager"

@class SharkLinkerTask;

/**
 shark解藕协议，更多丰富功能请使用Shark。
 */
@protocol SharkLinkerProtocol <NSObject>

/**
 返回一个task，通过task 发起请求。

 @return task
 */
- (SharkLinkerTask *)sharkTask;
@end

#endif /* SharkLinkerProtocol_h */
