//
//  PicassoReadWriteLock.h
//  clogan
//
//  Created by 纪鹏 on 2017/9/26.
//

#import <Foundation/Foundation.h>

@interface PicassoLock:NSObject

- (void)lock;
- (void)unlock;

@end


@interface PicassoReadWriteLock : NSObject

- (void)lockRead;

- (void)unLockRead;

- (void)lockWrite;

- (void)unLockWrite;
@end
