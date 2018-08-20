//
//  PicassoThreadManager.h
//  Picasso
//
//  Created by 纪鹏 on 2017/12/6.
//

#import <Foundation/Foundation.h>

extern void PCSRunOnMainThread(void (^ _Nonnull block)(void));

extern void PCSRunOnBridgeThread(void(^ _Nonnull block)(void));

extern void PCSRunOnViewComputeThread(void(^ _Nonnull block)(void));

@interface PicassoThreadManager : NSObject

@end
