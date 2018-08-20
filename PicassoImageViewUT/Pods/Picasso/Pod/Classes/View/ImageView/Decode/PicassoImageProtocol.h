//
//  PicassoImageProtocol.h
//  ImageViewBase
//
//  Created by welson on 2018/3/5.
//

#import <Foundation/Foundation.h>

@protocol PicassoImageProtocol <NSObject>

@property (nonatomic, assign, readonly) NSUInteger frameCount;
@property (nonatomic, readonly) NSDictionary<NSNumber *, NSNumber *> *frameDuration;
@property (nonatomic, readonly) UIImage *windowFrame; // 图片(如果是动图则为首帧图)

- (instancetype)initWithAnimatedImageData:(NSData *)data;
- (UIImage *)decodeFrameAtIndex:(NSUInteger)idx;
- (void)asyncDecodeFramesWithCompleteHandler:(void (^)(NSDictionary<NSNumber *, UIImage *> *result, NSArray<NSNumber *> *failedIdxes, id userinfo))handler;
- (void)asyncDecodeCertainFrames:(NSArray<NSNumber *> *)idxes
             WithCompleteHandler:(void (^)(NSDictionary<NSNumber *, UIImage *> *result, NSArray<NSNumber *> *failedIdxes, id userinfo))handler;

@optional

- (instancetype)initWithImage:(UIImage *)decodedImage;

@end
