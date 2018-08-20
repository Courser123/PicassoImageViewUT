//
//  PicassoHostManager.h
//  Pods
//
//  Created by 纪鹏 on 2017/5/26.
//
//

#import <Foundation/Foundation.h>
#import "PicassoHost.h"

@interface PicassoHostManager : NSObject

+ (void)saveHost:(PicassoHost *)host forHostId:(NSString *)hId;
+ (PicassoHost *)hostForId:(NSString *)hId;
+ (void)removeHostFotId:(NSString *)hId;
@end
