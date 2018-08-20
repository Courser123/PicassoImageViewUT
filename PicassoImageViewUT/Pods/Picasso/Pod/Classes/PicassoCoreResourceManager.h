//
//  PicassoCoreResourceManager.h
//  Pods
//
//  Created by 纪鹏 on 2017/1/18.
//
//

#import <Foundation/Foundation.h>

@interface PicassoCoreResourceManager : NSObject
+ (instancetype)instance;
- (void)updatePicassoWithUrlStr:(NSString *)urlStr;
+ (NSString *)pathForCoreJS;
@end
