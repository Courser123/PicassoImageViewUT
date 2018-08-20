//
//  NSData+pcs_md5.m
//  Picasso
//
//  Created by 纪鹏 on 2018/4/17.
//

#import "NSString+pcs_md5.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (pcs_md5)

- (NSString *)pcs_md5{
    const char* input = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(input, (CC_LONG)strlen(input), result);
    
    NSMutableString *digest = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [digest appendFormat:@"%02x", result[i]];
    }
    
    return digest;
}

@end
