//
//  PicassoBaseImageLog.h
//  Picasso
//
//  Created by welson on 2018/5/29.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, PicassoLogFetchSource) {
    PicassoLogFetchSourceMemory,
    PicassoLogFetchSourceDisk,
    PicassoLogFetchSourceRemote,
    PicassoLogFetchSourceCancelled
};

@interface PicassoBaseImageLog : NSObject

@property (nonatomic, assign) NSTimeInterval st;

@property (nonatomic, copy) NSString *requestURL;

@property (nonatomic, assign) PicassoLogFetchSource fetchSource;

@property (nonatomic, assign) NSTimeInterval diskFetchedTime;
@property (nonatomic, assign) NSTimeInterval waitToDownloadTime;
@property (nonatomic, assign) NSTimeInterval downloadTime;
@property (nonatomic, assign) NSTimeInterval finishedTime;

@property (nonatomic, assign) NSInteger byteLength;

@property (nonatomic, strong) NSError *error;

- (void)printMethod;
- (void)addLog;

@end
