//
//  PicassoDecodedImage.h
//  ImageViewBase
//
//  Created by welson on 2018/3/6.
//

#import <Foundation/Foundation.h>
#import "PicassoImageProtocol.h"
#import "NSData+PicassoImageType.h"

@interface PicassoDecodedImage : NSObject

@property (nonatomic, readonly) id<PicassoImageProtocol> imageObj;
@property (nonatomic, readonly) PicassoImageType imageType;
@property (nonatomic, readonly) NSData *imageData;

- (BOOL)canPlay;// if frameCount > 1
- (instancetype)initWithData:(NSData *)imageData;
- (instancetype)initWithImage:(UIImage *)image
                    imageType:(PicassoImageType)type;
- (instancetype)initWithImage:(UIImage *)image
                    imageType:(PicassoImageType)type
                    imageData:(NSData *)imageData;

@end
