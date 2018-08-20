//
//  PicassoDownLoadHelper.h
//  Pods
//
//  Created by Johnny on 15/12/29.
//
//
@class PicassoDownLoadHelper;

@interface PicassoDownLoadHelper : NSObject

@property (nonatomic, readonly) NSURLSession *downloadImageSession;

+ (PicassoDownLoadHelper *)shareInstance;

@end
