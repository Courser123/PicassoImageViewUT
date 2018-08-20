//
//  PicassoGifImage.m
//  ImageViewBase
//
//  Created by welson on 2018/3/5.
//

#import "PicassoGifImage.h"
#import <QuartzCore/QuartzCore.h>
#import "PicassoPerformanceKey.h"

@interface PicassoGifImage()

@property (nonatomic, strong) UIImage *posterImage;
@property (nonatomic, assign) NSUInteger frameCount;
@property (nonatomic, strong) NSDictionary<NSNumber *, NSNumber *> *frameDuration;

@property (nonatomic, strong) UIImage *windowFrame;

@property (nonatomic, strong) __attribute__((NSObject)) CGImageSourceRef imageSource;

@end

@implementation PicassoGifImage

- (instancetype)initWithAnimatedImageData:(NSData *)data {
    if (self = [super init]) {
        _imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
        if (_imageSource) _frameCount = CGImageSourceGetCount(_imageSource);
        _frameDuration = [self calculateFrameDurationWithImageSource:_imageSource];
        _posterImage = _windowFrame = [self decodeFrameAtIndex:0];
    }
    return self;
}

- (void)dealloc {
    if (self.imageSource) CFRelease(self.imageSource);
}

- (UIImage *)decodeFrameAtIndex:(NSUInteger)idx {
    if (!self.imageSource || idx >= self.frameCount) return nil;
    CGImageRef imageRef = CGImageSourceCreateImageAtIndex(self.imageSource, idx, NULL);
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    if (imageRef) CFRelease(imageRef);
    return image;
}

- (void)asyncDecodeFramesWithCompleteHandler:(void (^)(NSDictionary<NSNumber *, UIImage *> *result, NSArray<NSNumber *> *failedIdxes, id userinfo))handler {
    NSMutableArray *indxes = [NSMutableArray new];
    for (int i = 0; i < self.frameCount; i++) [indxes addObject:@(i)];
    [self asyncDecodeCertainFrames:indxes WithCompleteHandler:handler];
}

- (void)asyncDecodeCertainFrames:(NSArray<NSNumber *> *)idxes
             WithCompleteHandler:(void (^)(NSDictionary<NSNumber *, UIImage *> *result, NSArray<NSNumber *> *failedIdxes, id userinfo))handler {
    if (!idxes.count && handler) handler(nil, nil, nil);
    __block NSMutableDictionary<NSNumber *, UIImage *> *frames = [NSMutableDictionary new];
    __block NSMutableArray<NSNumber *> *failedFrames = [NSMutableArray new];
    
    NSTimeInterval st = CACurrentMediaTime();

    /**
     *  后台线程串行解码
     *
     */
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        for (int i = 0; i < idxes.count; i++) {
            UIImage *image = [self decodeFrameAtIndex:idxes[i].integerValue];
            if (!image) [failedFrames addObject:idxes[i]];
            else [frames setObject:image forKey:idxes[i]];
            if (frames.count + failedFrames.count == idxes.count) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSTimeInterval ed = CACurrentMediaTime();
                    if (handler) handler(frames, failedFrames, @{PIVExecuteTime:@(ed - st)});
                });
            }
        }
    });
}

- (NSDictionary<NSNumber *, NSNumber *> *)calculateFrameDurationWithImageSource:(CGImageSourceRef)sourceRef {
    if (!sourceRef) return nil;
    NSMutableDictionary<NSNumber *, NSNumber *> *tmp = [NSMutableDictionary new];
    size_t frameCount = CGImageSourceGetCount(sourceRef);
    for (int i = 0; i < frameCount; i++) [tmp setObject:@([self frameDurationWithGifAtIndex:i source:sourceRef]) forKey:@(i)];
    return tmp.copy;
}

- (float)frameDurationWithGifAtIndex:(NSUInteger)idx source:(CGImageSourceRef)sourceRef {
    float frameDuration = 0.1;
    if (!sourceRef) return frameDuration;
    CFDictionaryRef cfProperty = CGImageSourceCopyPropertiesAtIndex(sourceRef, idx, NULL);
    if (!cfProperty) return frameDuration;
    NSDictionary *property = (__bridge NSDictionary *)cfProperty;
    NSDictionary *gifProperty = property[(__bridge NSString *)kCGImagePropertyGIFDictionary];
    NSNumber *delayTime = gifProperty[(__bridge NSString *)kCGImagePropertyGIFUnclampedDelayTime];
    if (delayTime) frameDuration = [delayTime floatValue];
    else {
        NSNumber *delayTimeProp = gifProperty[(__bridge NSString *)kCGImagePropertyGIFDelayTime];
        if (delayTimeProp) frameDuration = [delayTimeProp floatValue];
    }
    if (frameDuration < 0.011) frameDuration = 0.100;
    CFRelease(cfProperty);
    return frameDuration;
}

@end
