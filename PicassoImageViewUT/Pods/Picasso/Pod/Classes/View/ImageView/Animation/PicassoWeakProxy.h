//
//  PicassoWeakProxy.h
//  ImageViewBase
//
//  Created by welson on 2018/3/6.
//

#import <Foundation/Foundation.h>

@interface PicassoWeakProxy : NSProxy

+ (instancetype)weakProxyForObject:(id)targetObject;

@end
