//
//  PicassoImageDecoder.m
//  Pods
//
//  Created by Johnny on 15/12/29.
//
//
#import "PicassoImageDecoder.h"
#import <ImageIO/ImageIO.h>

CGImageRef PCSImageCreateWithDecodePic(CGImageRef image, CGSize targetSize);

@implementation PicassoImageDecoder

+ (UIImage *)decodeImageWithOriginImage:(UIImage *)image{
    @autoreleasepool {
        if (!image) return nil;
        CGImageRef originCGImage = image.CGImage;
        CGImageAlphaInfo alphainfo = CGImageGetAlphaInfo(originCGImage);
        BOOL haveAlpha = (alphainfo == kCGImageAlphaFirst ||
                          alphainfo == kCGImageAlphaLast ||
                          alphainfo == kCGImageAlphaPremultipliedFirst ||
                          alphainfo == kCGImageAlphaPremultipliedLast);
        if (haveAlpha) return image;
        
        CGSize originSize = image.size;
        size_t width = originSize.width / 8;
        width *= 8;
        size_t height = width * originSize.height / originSize.width;
        //        CGRect newRect = CGRectMake(floor((originSize.width - width)/2), floor((originSize.height - height)/2), width, height);
        //        CGImageRef newImageRef = CGImageCreateWithImageInRect(originCGImage, newRect);
        //        CGImageRef decodeImage = PCSImageCreateWithDecodePic(newImageRef, newRect.size);
        CGImageRef decodeImage = PCSImageCreateWithDecodePic(originCGImage, CGSizeMake(width, height));
        UIImage *resultImage = [UIImage imageWithCGImage:decodeImage];
        CGImageRelease(decodeImage);
        //        CGImageRelease(newImageRef);
        return resultImage;
    }
}

@end

CGImageRef PCSImageCreateWithDecodePic(CGImageRef image, CGSize targetSize){
    CGColorSpaceRef spaceRef = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(NULL, targetSize.width, targetSize.height, 5, 0, spaceRef, kCGBitmapByteOrder16Little|kCGImageAlphaNoneSkipFirst);
    CGContextDrawImage(ctx, CGRectMake(0, 0, targetSize.width, targetSize.height), image);
    CGImageRef result = CGBitmapContextCreateImage(ctx);
    CGContextRelease(ctx);
    if (spaceRef) {
        CFRelease(spaceRef);
    }
    return result;
}
