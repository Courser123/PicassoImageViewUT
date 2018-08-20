//
//  NSData+PicassoImageType.h
//  Pods
//
//  Created by 薛琳 on 16/1/20.
//
//


typedef NS_ENUM(NSInteger, PicassoImageType)
{
    PicassoImageTypeNone = 0,
    PicassoImageTypeJPEG,
    PicassoImageTypePNG,
    PicassoImageTypeWebp,
    PicassoImageTypeGif,
    PicassoImageTypeBitmap,
    PicassoImageTypeWebpAnimated,
    PicassoImageTypeWebpStatic
};

@interface NSData (PicassoImageType)

+ (PicassoImageType)picassoContentTypeForImageData:(NSData *)data;

@end
