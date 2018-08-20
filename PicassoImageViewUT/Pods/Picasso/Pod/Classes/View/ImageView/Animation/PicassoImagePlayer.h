//
//  PicassoImagePlayer.h
//  ImageViewBase
//
//  Created by welson on 2018/3/6.
//

#import <Foundation/Foundation.h>
#import "PicassoDecodedImage.h"

@class PicassoImagePlayer;

@protocol PicassoImagePlayerProtocol <NSObject>

- (void)picassoImagePlayer:(PicassoImagePlayer *)player
        shouldDisplayImage:(UIImage *)givenImage
                       idx:(NSUInteger)currentIdx;
- (void)picassoImagePlayer:(PicassoImagePlayer *)player
                 loopCount:(NSUInteger)count;

@end

@interface PicassoImagePlayer : NSObject

@property (nonatomic, readonly) PicassoDecodedImage *decodeImageObj;
@property (nonatomic, weak) id<PicassoImagePlayerProtocol> delegate;
@property (nonatomic, assign) BOOL isPlaying;

@property (nonatomic, assign) BOOL diskAssistant;
@property (nonatomic, copy) NSString *identifier;

- (instancetype)initWithImageData:(NSData *)imageData;
- (instancetype)initWithDecodedObj:(PicassoDecodedImage *)decodeObj;
- (UIImage *)posterImage;
/**
 *  play with the delegate. Should set the given image at appropriate time.
 *
 */
- (void)play;
- (void)resume;
- (void)pause;
- (void)stop;

@end
