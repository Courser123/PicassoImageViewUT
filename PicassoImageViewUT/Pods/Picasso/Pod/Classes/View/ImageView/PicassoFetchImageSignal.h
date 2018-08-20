//
//  PicassoFetchImageSignal.h
//  Pods
//
//  Created by Courser on 08/09/2017.
//
//

#import "PicassoBaseFetchSignal.h"
#import <ReactiveCocoa.h>
#import "NSData+PicassoImageType.h"
#import "PicassoBaseImageLog.h"
#import "PicassoDecodedImage.h"

typedef NS_ENUM(NSInteger, CRPicassoImageErrorCode)
{
    CRPicassoImageErrorCodeEmptyData = 1,
    CRPicassoImageErrorCodeInvalidTypeData,
    CRPicassoImageErrorCodeIncompleteData
};


typedef NS_ENUM(NSInteger, CRPicassoImageCache)
{
    CRPicassoImageCacheDefault,
    CRPicassoImageCachePermanentIcons
};

typedef NS_ENUM(NSInteger, CRPicassoImageCacheType)
{
    CRPicassoImageCacheTypeNone = 0,
    CRPicassoImageCacheTypeDisk,
    CRPicassoImageCacheTypeMemory
};

@interface PicassoFetchImageSignal : PicassoBaseFetchSignal

@property (nonatomic, assign) BOOL enableMemCache;  // 内存缓存
@property (nonatomic, assign) BOOL enableDiskCache;  // 磁盘缓存
@property (nonatomic, assign) BOOL syncReadFromDisk;  // 同步从磁盘读取
@property (nonatomic, assign) BOOL needImageData;
@property (nonatomic, strong) NSString *businessName;
@property (nonatomic, assign) CRPicassoImageCache cacheType;  // 缓存类型
@property (nonatomic, assign) NSTimeInterval timeoutIntervalForRequest;  // 超时时间

@property (nonatomic, strong) UIImage *resultImage;  // decoded image
@property (nonatomic, strong, readonly) NSData *imageData;  //undecode data
@property (nonatomic, assign) PicassoImageType imageType;  // 图片类型

@property (nonatomic, assign, readonly) NSTimeInterval decodeTimeForJPG;
@property (nonatomic, assign, readonly) NSTimeInterval decodeTimeForWEBP;
@property (nonatomic, assign, readonly) NSTimeInterval downloadTimeForImage;

@property (nonatomic, copy) NSDictionary *HTTPAdditionalHeaders;
@property (nonatomic, strong) UIResponder *mark;  // 标记重定向URL响应者链的初始控件
@property (nonatomic, strong) PicassoBaseImageLog *log;

/**
 结果以RACTuple的形式传出
 tuple.first为PicassoFetchImageSignal对象
 tuple.second为布尔值,标志请求是否成功
 tuple.third为PicassoDecodedImage对象,可以获取imageObj,imageData,imageType
 */
- (RACSignal *)fetchSignalWithIdentifier:(NSString *)identifier;

// 获取结果以PicassoDecodedImage的形式传出,可以获取imageObj,imageData,imageType
+ (RACSignal *)setImageData:(NSData *)data;

+ (UIImage *)imageWithData:(NSData *)data;

@end
