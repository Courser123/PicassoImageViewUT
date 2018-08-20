//
//  NVNetworkMD5File.m
//  NVNetworkLogger
//
//  Created by yxn on 2017/4/11.
//  Copyright © 2017年 xiangnan.yang. All rights reserved.
//

#import "NVNetworkMD5File.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonKeyDerivation.h>

@implementation NVNetworkMD5File


+(NSString*)fileMD5:(NSString*)path
{
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:path];
    if( handle== nil ) return @"ERROR GETTING FILE MD5"; // file didnt exist
    
    CC_MD5_CTX md5;
    CC_MD5_Init(&md5);
    
    BOOL done = NO;
    
    @autoreleasepool{
        while(!done)
        {
            NSData* fileData = [handle readDataOfLength: CC_MD5_BLOCK_BYTES];
            CC_MD5_Update(&md5, [fileData bytes], (CC_LONG)[fileData length]);
            if( [fileData length] == 0 ) done = YES;
        }
    }
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &md5);
    NSString* s = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                   digest[0], digest[1],
                   digest[2], digest[3],
                   digest[4], digest[5],
                   digest[6], digest[7],
                   digest[8], digest[9],
                   digest[10], digest[11],
                   digest[12], digest[13],
                   digest[14], digest[15]];
    return s;
}

@end
