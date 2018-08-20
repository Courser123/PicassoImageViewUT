//
//  NVSkyNetTransaction.h
//  NVMonitorCenter
//
//  Created by David on 2018/3/7.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, NVTransactionType){
    NVTransactionTypeSuceess = 1,
    NVTransactionTypeFail = 2,
};

@interface NVSkyNetTransaction : NSObject
/*
 * 初始化一个NVSkyNetTransaction对象
 * key为Transaction过程的指标
 */
- (instancetype _Nonnull)initTransactionWithKey:(nonnull NSString *)key;
/*
 * 开始Transaction过程
 */
- (void)start;
/*
 * 结束Transaction过程
 */
- (void)end;

@end
