//
//  PicassoNormalImage.m
//  ImageViewBase
//
//  Created by welson on 2018/3/6.
//

#import "PicassoNormalImage.h"
#import "PicassoPerformanceKey.h"
#import "PicassoImageDecoder.h"

@interface PicassoNormalImage()

@property (nonatomic, strong) UIImage *posterImage;
@property (nonatomic, strong) UIImage *decodedImage;

@end

@implementation PicassoNormalImage

- (instancetype)initWithImage:(UIImage *)decodedImage {
    if (self = [super init]) {
        _posterImage = _decodedImage = decodedImage;
    }
    return self;
}

- (instancetype)initWithAnimatedImageData:(NSData *)data {
    if (self = [super init]) {
        _posterImage = [[UIImage alloc] initWithData:data];
    }
    return self;
}

- (NSUInteger)frameCount {
    return 1;
}

- (NSDictionary<NSNumber *,NSNumber *> *)frameDuration {
    return nil;
}

- (UIImage *)windowFrame {
    if (self.decodedImage) return self.decodedImage;
    return self.posterImage;
}

- (UIImage *)decodeFrameAtIndex:(NSUInteger)idx {
    if (!self.decodedImage) self.decodedImage = [PicassoImageDecoder decodeImageWithOriginImage:self.posterImage];
    return self.decodedImage;
}

- (void)asyncDecodeFramesWithCompleteHandler:(void (^)(NSDictionary<NSNumber *, UIImage *> *result, NSArray<NSNumber *> *failedIdxes, id userinfo))handler {
    [self asyncDecodeCertainFrames:@[@(0)] WithCompleteHandler:handler];
}

- (void)asyncDecodeCertainFrames:(NSArray<NSNumber *> *)idxes
             WithCompleteHandler:(void (^)(NSDictionary<NSNumber *, UIImage *> *result, NSArray<NSNumber *> *failedIdxes, id userinfo))handler {
    if (self.decodedImage && handler) handler(@{@(0):self.decodedImage}, nil, nil);
    NSTimeInterval st = CACurrentMediaTime();
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        UIImage *image = [self decodeFrameAtIndex:0];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSTimeInterval ed = CACurrentMediaTime();
            if (!self.decodedImage) self.decodedImage = image;
            if (handler) handler(image?@{@(0):image}:nil, image?nil:@[@(0)], @{PIVExecuteTime:@(ed - st)});
        });
    });
}

@end
