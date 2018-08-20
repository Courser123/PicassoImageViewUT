//
//  PicassoCoreResourceManager.m
//  Pods
//
//  Created by 纪鹏 on 2017/1/18.
//
//

#import "PicassoCoreResourceManager.h"
#import <CommonCrypto/CommonDigest.h>

@implementation PicassoCoreResourceManager

+ (instancetype)instance {
    static PicassoCoreResourceManager *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[PicassoCoreResourceManager alloc] init];
    });
    return _instance;
}

- (void)updatePicassoWithUrlStr:(NSString *)urlStr {
    NSURL *url = [NSURL URLWithString:urlStr];
    if (!url) {
        return;
    }
    if (url.lastPathComponent.length < 16) {
        return;
    }
    NSString *fileMd5 = [url.lastPathComponent substringWithRange:NSMakeRange(0, 16)];
    if ([fileMd5 isEqualToString:[self curCoreJSmd5]]) {
        return;
    }
    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error && [[[self md5ForData:data] substringToIndex:16] isEqualToString:fileMd5]) {
            [self saveData:data];
        }
    }] resume];
}

- (void)saveData:(NSData *)data {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *deleteError = nil;
    if ([fileManager fileExistsAtPath:[self.class pathForCoreJS]]) {
        [fileManager removeItemAtPath:[self.class pathForCoreJS] error:&deleteError];
    }
    if (![fileManager fileExistsAtPath:[self.class directoryForCoreJS]]) {
        [fileManager createDirectoryAtPath:[self.class directoryForCoreJS] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if (!deleteError) {
        [data writeToFile:[self.class pathForCoreJS] atomically:YES];
    }
}

+ (NSString *)pathForCoreJS {
    return [[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"picassofile"] stringByAppendingPathComponent:@"main.js"];
}

+ (NSString *)directoryForCoreJS {
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"picassofile"];
}

- (NSString *)curCoreJSmd5 {
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self.class pathForCoreJS]]) {
        NSData *data = [NSData dataWithContentsOfFile:[self.class pathForCoreJS]];
        return [[self md5ForData:data] substringToIndex:16];
    } else {
        return nil;
    }
}

- (NSString *)md5ForData:(NSData *)data {
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( data.bytes, (CC_LONG)data.length, digest );
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;

}

@end
