//
//  PicassoDecodedImage.m
//  ImageViewBase
//
//  Created by welson on 2018/3/6.
//

#import "PicassoDecodedImage.h"
#import "PicassoGifImage.h"
#import "PicassoWebpImage.h"
#import "PicassoNormalImage.h"

@interface PicassoDecodedImage()

@property (nonatomic, strong) id<PicassoImageProtocol> imageObj;
@property (nonatomic, assign) PicassoImageType imageType;

@end

@implementation PicassoDecodedImage

- (instancetype)initWithData:(NSData *)imageData {
    if (self = [super init]) {
        _imageData = imageData;
        _imageObj = [self setupWithImageData:imageData];
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image
                    imageType:(PicassoImageType)type {
    if (self = [super init]) {
        _imageType = type;
        _imageObj = [self setUpWithImage:image];
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image imageType:(PicassoImageType)type imageData:(NSData *)imageData {
    if (self = [super init]) {
        _imageData = imageData;
        _imageType = type;
        if (_imageType == PicassoImageTypeNone && imageData) {
            _imageType = [NSData picassoContentTypeForImageData:imageData];
        }
        if (image) {
            _imageObj = [self setUpWithImage:image];
        }else {
            _imageObj = [self setupWithImageData:imageData];
        }
    }
    return self;
}

- (id<PicassoImageProtocol>)setUpWithImage:(UIImage *)image {
    if (!image) return nil;
    id<PicassoImageProtocol> obj = nil;
    switch (self.imageType) {
        case PicassoImageTypeWebp:
        {
            if ([PicassoWebpImage instancesRespondToSelector:@selector(initWithImage:)]) {
                obj = [[PicassoWebpImage alloc] initWithImage:image];
            }
        }
            break;
        case PicassoImageTypeGif:
        {}
            break;
            
        default:
        {
            if ([PicassoNormalImage instancesRespondToSelector:@selector(initWithImage:)]) {
                obj = [[PicassoNormalImage alloc] initWithImage:image];
            }
        }
            break;
    }
    return obj;
}

- (id<PicassoImageProtocol>)setupWithImageData:(NSData *)data {
    if (!data || !data.length) return nil;
    PicassoImageType type = [NSData picassoContentTypeForImageData:data];
    id<PicassoImageProtocol> obj = nil;
    
    switch (type) {
        case PicassoImageTypeGif:
        {
            obj = [[PicassoGifImage alloc] initWithAnimatedImageData:data];
        }
            break;
        case PicassoImageTypeWebp:
        {
            obj = [[PicassoWebpImage alloc] initWithAnimatedImageData:data];
        }
            break;
        default:
        {
            obj = [[PicassoNormalImage alloc] initWithAnimatedImageData:data];
        }
            break;
    }
    self.imageType = type;
    return obj;
}

- (BOOL)canPlay {
    return self.imageObj.frameCount > 1;
}

@end
