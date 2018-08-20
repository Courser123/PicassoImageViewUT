//
//  PicassoBaseFetchSignal.h
//  Pods
//
//  Created by Courser on 11/09/2017.
//
//

#import <Foundation/Foundation.h>
#import "ReactiveCocoa.h"
#import "NVCodeLogger.h"

@interface PicassoBaseFetchSignal : NSObject

@property (nonatomic, strong) RACDisposable *disposable;
@property (nonatomic, assign) BOOL isExecuting;
@property (nonatomic, assign) BOOL isFinished;
@property (nonatomic, assign) BOOL isCanceled;

- (void)cancel;
- (NSString *)convertDateToString:(NSDate *)date;

@end
