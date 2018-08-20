//
//  PicassoWebpImageDecoder.h
//  Pods
//
//  Created by Courser on 18/08/2017.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, PicassoWebPImageType) {
    PicassoWebPImageTypeUnknown = 0, ///< unknown
    PicassoWebPImageTypeJPEG,        ///< jpeg, jpg
    PicassoWebPImageTypeJPEG2000,    ///< jp2
    PicassoWebPImageTypeTIFF,        ///< tiff, tif
    PicassoWebPImageTypeBMP,         ///< bmp
    PicassoWebPImageTypeICO,         ///< ico
    PicassoWebPImageTypeICNS,        ///< icns
    PicassoWebPImageTypeGIF,         ///< gif
    PicassoWebPImageTypePNG,         ///< png
    PicassoWebPImageTypeWebP,        ///< webp
    PicassoWebPImageTypeOther,       ///< other image format
};


typedef NS_ENUM(NSUInteger, PicassoImageDisposeMethod) {
    
    /**
     No disposal is done on this frame before rendering the next; the contents
     of the canvas are left as is.
     */
    PicassoImageDisposeNone = 0,
    
    /**
     The frame's region of the canvas is to be cleared to fully transparent black
     before rendering the next frame.
     */
    PicassoImageDisposeBackground,
    
    /**
     The frame's region of the canvas is to be reverted to the previous contents
     before rendering the next frame.
     */
    PicassoImageDisposePrevious,
};

/**
 Blend operation specifies how transparent pixels of the current frame are
 blended with those of the previous canvas.
 */
typedef NS_ENUM(NSUInteger, PicassoImageBlendOperation) {
    
    /**
     All color components of the frame, including alpha, overwrite the current
     contents of the frame's canvas region.
     */
    PicassoImageBlendNone = 0,
    
    /**
     The frame should be composited onto the output buffer based on its alpha.
     */
    PicassoImageBlendOver,
};

#pragma mark - PicassoImageFrame

@interface PicassoImageFrame : NSObject <NSCopying>
@property (nonatomic) NSUInteger index;    ///< Frame index (zero based)
@property (nonatomic) NSUInteger width;    ///< Frame width
@property (nonatomic) NSUInteger height;   ///< Frame height
@property (nonatomic) NSUInteger offsetX;  ///< Frame origin.x in canvas (left-bottom based)
@property (nonatomic) NSUInteger offsetY;  ///< Frame origin.y in canvas (left-bottom based)
@property (nonatomic) NSTimeInterval duration;          ///< Frame duration in seconds
@property (nonatomic) PicassoImageDisposeMethod dispose;     ///< Frame dispose method.
@property (nonatomic) PicassoImageBlendOperation blend;      ///< Frame blend operation.
@property (nullable, nonatomic, strong) UIImage *image; ///< The image.

+ (instancetype _Nullable )frameWithImage:(UIImage *_Nullable)image;

@end


#pragma mark - PicassoWebpImageDecoder

@interface PicassoWebpImageDecoder : NSObject

@property (nullable, nonatomic, readonly) NSData *data;    ///< Image data.
@property (nonatomic, readonly) PicassoWebPImageType type;          ///< Image data type.
@property (nonatomic, readonly) CGFloat scale;             ///< Image scale.
@property (nonatomic, readonly) NSUInteger frameCount;     ///< Image frame count.
@property (nonatomic, readonly) NSUInteger loopCount;      ///< Image loop count, 0 means infinite.
@property (nonatomic, readonly) NSUInteger width;          ///< Image canvas width.
@property (nonatomic, readonly) NSUInteger height;         ///< Image canvas height.
@property (nonatomic, readonly, getter=isFinalized) BOOL finalized;
@property (nonatomic,copy) NSArray * _Nullable durations;
@property (nonatomic,strong) PicassoImageFrame * _Nullable bufferFrame;

/**
 Convenience method to create a decoder with specified data.
 @param data  Image data.
 @param scale Image's scale.
 @return A new decoder, or nil if an error occurs.
 */
+ (nullable instancetype)decoderWithData:(NSData *_Nullable)data scale:(CGFloat)scale;

/**
 Decodes and returns a frame from a specified index.
 @param index  Frame image index (zero-based).
 @param decodeForDisplay Whether decode the image to memory bitmap for display.
 If NO, it will try to returns the original frame data without blend.
 @return A new frame with image, or nil if an error occurs.
 */
- (nullable PicassoImageFrame *)frameAtIndex:(NSUInteger)index decodeForDisplay:(BOOL)decodeForDisplay;

/**
 Asynchronize Decodes and returns a frame from a specified index.
 */
- (void)multiThreadGetFrameAtIndex:(NSUInteger)index completedHandle:(void (^_Nullable)(PicassoImageFrame *_Nullable))completed;

@end


#pragma mark - UIImage (PicassoImageCoder)

@interface UIImage (PicassoImageCoder)

/**
 Decompress this image to bitmap, so when the image is displayed on screen,
 the main thread won't be blocked by additional decode. If the image has already
 been decoded or unable to decode, it just returns itself.
 
 @return an image decoded, or just return itself if no needed.
 @see isDecodedForDisplay
 */
- (instancetype _Nullable )pcs_imageByDecoded;

/**
 Wherher the image can be display on screen without additional decoding.
 @warning It just a hint for your code, change it has no other effect.
 */
@property (nonatomic) BOOL pcs_isDecodedForDisplay;

@end
