//
//  PicassoDownloadImageSignal.h
//  Pods
//
//  Created by Courser on 18/09/2017.
//
//

#import <Foundation/Foundation.h>
#import "PicassoBaseFetchSignal.h"
#import <ReactiveCocoa.h>
#import "NSData+PicassoImageType.h"
#import "PicassoBaseImageLog.h"
#import "PicassoFetchImageSignal.h"
#import "PicassoDecodedImage.h"

@interface PicassoDownloadImageSignal : PicassoBaseFetchSignal

@property (nonatomic, assign) BOOL enableMemCache;  // 内存缓存
@property (nonatomic, assign) BOOL enableDiskCache;  // 磁盘缓存
@property (nonatomic, assign) CRPicassoImageCache cacheType;  // 缓存类型
@property (nonatomic, copy) NSDictionary *HTTPAdditionalHeaders;
@property (nonatomic, assign) NSTimeInterval timeoutIntervalForRequest;  // 超时时间
@property (nonatomic, assign, readonly) NSTimeInterval downloadTimeForImage;
@property (nonatomic, strong) UIResponder *mark;
@property (nonatomic, strong) PicassoBaseImageLog *log;

@property (nonatomic, strong) UIImage *resultImage;  // decoded image
@property (nonatomic, strong, readonly) NSData *imageData;  //undecode data
@property (nonatomic, assign) PicassoImageType imageType;  // 图片类型

/**
 结果以RACTuple的形式传出
 tuple.first为PicassoDownloadImageSignal对象
 tuple.second为布尔值,标志请求是否成功
 tuple.third为PicassoDecodedImage对象,可以获取imageObj,imageData,imageType
 */
- (RACSignal *)downloadSignalWithIndentifier:(NSString *)identifier;

@end
