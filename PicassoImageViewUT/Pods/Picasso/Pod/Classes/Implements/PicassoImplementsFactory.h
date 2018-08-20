//
//  PicassoImplementsFactory.h
//  clogan
//
//  Created by 纪鹏 on 2017/11/23.
//

#import <Foundation/Foundation.h>

@interface PicassoImplementsFactory : NSObject

+ (Class)implementForProtocol:(Protocol *)protocol;

@end
