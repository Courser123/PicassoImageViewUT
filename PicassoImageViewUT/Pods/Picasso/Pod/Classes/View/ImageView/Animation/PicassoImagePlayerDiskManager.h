//
//  PicassoImagePlayerDiskManager.h
//  ImageViewBase
//
//  Created by 薛琳 on 2018/3/7.
//

#import <Foundation/Foundation.h>

@interface PicassoImagePlayerDiskManager : NSObject

+ (PicassoImagePlayerDiskManager *)shareInstance;

- (void)savePhoto:(UIImage *)image
          withKey:(NSString *)identifier
              idx:(NSUInteger)idx;

- (UIImage *)imageWithKey:(NSString *)identifier
                      idx:(NSUInteger)idx;

@end
