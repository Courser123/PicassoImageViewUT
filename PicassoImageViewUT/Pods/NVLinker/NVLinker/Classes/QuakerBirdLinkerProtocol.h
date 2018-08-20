//
//  QuakerBirdLinkerProtocol.h
//  NVLinker
//
//  Created by game3108 on 2018/6/27.
//

#import <Foundation/Foundation.h>

#define QuakerBirdLinkerCalssString @"QuakerBirdLinkerManager"

@protocol QuakerBirdLinkerProtocol <NSObject>

- (void)qbWriteLog:(nonnull NSString *)log
              type:(NSUInteger)type
              time:(NSTimeInterval)time
         localTime:(NSTimeInterval)localTime
        threadName:(nullable NSString *)threadName
         threadNum:(NSInteger)threadNum
      threadIsMain:(BOOL)threadIsMain
               tag:(nullable NSArray<NSString *> *)tag;

@end
