//
//  NSData+PicassoImageType.m
//  Pods
//
//  Created by 薛琳 on 16/1/20.
//
//

#import "NSData+PicassoImageType.h"

@implementation NSData (PicassoImageType)

+ (PicassoImageType)picassoContentTypeForImageData:(NSData *)data
{
    uint8_t c;
    [data getBytes:&c length:1];
    switch (c) {
        case 0xFF:
            return PicassoImageTypeJPEG;
        case 0x89:
            return PicassoImageTypePNG;
        case 0x47:
            return PicassoImageTypeGif;
        case 0x52:
            // R as RIFF for WEBP
            if ([data length] < 12) {
                return PicassoImageTypeNone;
            }
            
            NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, 12)] encoding:NSASCIIStringEncoding];
            if ([testString hasPrefix:@"RIFF"] && [testString hasSuffix:@"WEBP"]) {
                return PicassoImageTypeWebp;
            }
            
            return PicassoImageTypeNone;
    }
    return PicassoImageTypeNone;
}

@end
