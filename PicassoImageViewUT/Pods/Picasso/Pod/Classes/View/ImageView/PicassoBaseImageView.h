//
//  PicassoBaseImageView.h
//  Pods
//
//  Created by Johnny on 15/12/29.
//
//
#import "PicassoFetchImageSignal.h"
#import "EXTScope.h"
@class PicassoBaseImageView;

typedef enum : NSInteger {
    PicassoBaseImageViewStateNoPic = 0,
    PicassoBaseImageViewStateLoading,
    PicassoBaseImageViewStateLoadSuccess,
    PicassoBaseImageViewStateLoadFailed
} PicassoImageViewState;

@protocol PicassoImageViewDelegate <NSObject>

@optional

- (void)imageViewDidBeginLoading:(PicassoBaseImageView *)imageView;
- (void)imageViewDidFinishLoading:(PicassoBaseImageView *)imageView;
- (void)imageViewDidCancelLoading:(PicassoBaseImageView *)imageView;
- (void)imageViewDidLoadFailed:(PicassoBaseImageView *)imageView;

- (void)imageView:(PicassoBaseImageView *)imageView gifImagePlayedWithCount:(NSUInteger)count;

/*
 If This method is invoked, "imageViewDidFinishLoading:" and "imageViewDidLoadFailed:" will never be called
 */
- (void)imageViewDidHitTheCache:(PicassoBaseImageView *)imageView;

@end

@interface PicassoBaseImageView : UIImageView

@property (nonatomic, assign) BOOL enableMemCache;
@property (nonatomic, assign) BOOL enableDiskCache;
@property (nonatomic, assign) BOOL syncReadFromDisk;

@property (nonatomic, assign) BOOL enableRetry;

@property (nonatomic, strong) UIImage *loadingImage;
@property (nonatomic, strong) UIImage *emptyImage;
@property (nonatomic, strong) UIImage *errorImage;
@property (nonatomic, assign) UIViewContentMode statusContentMode;

@property (nonatomic, strong) NSURL    *imageURL;
@property (nonatomic)         NSString *imageURLString;

@property (nonatomic, assign) BOOL autoPlayImages;

@property (nonatomic, weak) id<PicassoImageViewDelegate> delegate;

@property (nonatomic, assign) BOOL fadeEffect;
@property (nonatomic, assign, readonly) BOOL isPlaying;
@property (nonatomic, assign) CGFloat blurRadius; // 设置大于0出现高斯模糊效果,默认为0

- (void)startPlaying;
- (void)stopPlaying;
- (void)pausePlaying;

- (void)setImageURL:(NSURL *)imageURL withBusiness:(NSString *)business;
- (void)setImageURLString:(NSString *)imageURLString withBusiness:(NSString *)business;

- (void)setImageURL:(NSURL *)imageURL withBusiness:(NSString *)business cacheType:(CRPicassoImageCache)cacheType;
- (void)setImageURLString:(NSString *)imageURLString withBusiness:(NSString *)business cacheType:(CRPicassoImageCache)cacheType;

- (void)setImageData:(NSData *)imagedata;
- (void)reloadURLWhenFailed;

@end
