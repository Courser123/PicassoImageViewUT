//
//  PicassoWebpImage.m
//  ImageViewBase
//
//  Created by welson on 2018/3/5.
//

#import "PicassoWebpImage.h"
#import "PicassoWebpImageDecoder.h"
#import "PicassoPerformanceKey.h"

@interface PicassoWebpImage()

@property (nonatomic, strong) UIImage *posterImage;
@property (nonatomic, strong) NSDictionary<NSNumber *, NSNumber *> *frameDuration;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSNumber *> *originalDuration;

@property (nonatomic, strong) UIImage *windowFrame;
@property (nonatomic, strong) PicassoWebpImageDecoder *decoder;
@property (nonatomic, assign) BOOL createByImage;

@end

@implementation PicassoWebpImage

- (instancetype)initWithImage:(UIImage *)decodedImage {
    if (self = [super init]) {
        _posterImage = _windowFrame = decodedImage;
        _createByImage = YES;
    }
    return self;
}

- (instancetype)initWithAnimatedImageData:(NSData *)data {
    if (self = [super init]) {
        _decoder = [PicassoWebpImageDecoder decoderWithData:data scale:[UIScreen mainScreen].scale];
        _posterImage = _windowFrame = [_decoder frameAtIndex:0 decodeForDisplay:YES].image;
        _frameDuration = [self calculateFrameDurationWithDecoder:_decoder];
    }
    return self;
}

- (NSDictionary<NSNumber *, NSNumber *> *)calculateFrameDurationWithDecoder:(PicassoWebpImageDecoder *)decoder {
    if (!decoder.frameCount) return nil;
    NSMutableDictionary<NSNumber *, NSNumber *> *tmp = [NSMutableDictionary new];
    self.originalDuration = [NSMutableDictionary new];
    for (int i = 0; i < decoder.frameCount; i++) {
        if (i >= decoder.durations.count) break;
        if (decoder.durations[i]) {
            if ([decoder.durations[i] floatValue]) {
                [tmp setObject:decoder.durations[i] forKey:@(i)];
            }else {
                [tmp setObject:@(0.1) forKey:@(i)];
            }
            [self.originalDuration setObject:decoder.durations[i] forKey:@(i)];
        }
    }
    return tmp.copy;
}

- (NSUInteger)frameCount {
    if (self.createByImage) return 1;
    return self.decoder.frameCount;
}

- (UIImage *)decodeFrameAtIndex:(NSUInteger)idx {
    if (self.createByImage) return self.windowFrame;
    if (idx >= self.decoder.frameCount) return nil;
    return [self.decoder frameAtIndex:idx decodeForDisplay:YES].image;
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
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
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

@end
