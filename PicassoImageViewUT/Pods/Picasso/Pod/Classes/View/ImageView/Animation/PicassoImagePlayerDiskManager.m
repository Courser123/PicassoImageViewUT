//
//  PicassoImagePlayerDiskManager.m
//  ImageViewBase
//
//  Created by 薛琳 on 2018/3/7.
//

#import "PicassoImagePlayerDiskManager.h"
#import <CommonCrypto/CommonDigest.h>

@interface PicassoImagePlayerDiskManager()

@property (nonatomic, strong) dispatch_queue_t ioQueue;

@end

@implementation PicassoImagePlayerDiskManager

+ (PicassoImagePlayerDiskManager *)shareInstance {
    static PicassoImagePlayerDiskManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [PicassoImagePlayerDiskManager new];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
         _ioQueue = dispatch_queue_create("com.picasso.animated.ioQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)savePhoto:(UIImage *)image
          withKey:(NSString *)identifier
              idx:(NSUInteger)idx {
    if (!identifier.length || !image) return;
    NSString *encryptedKey = [[self class] md5:identifier];
    NSString *fileDirectoryPath = [[self directoryPath] stringByAppendingPathComponent:encryptedKey];
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:fileDirectoryPath]) {
        [manager createDirectoryAtPath:fileDirectoryPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    dispatch_async(self.ioQueue, ^{
        NSString *framePath = [fileDirectoryPath stringByAppendingPathComponent:[@(idx) stringValue]];
        [NSKeyedArchiver archiveRootObject:image toFile:framePath];
        NSLog(@"%@", framePath);
    });
}

- (UIImage *)imageWithKey:(NSString *)identifier
                      idx:(NSUInteger)idx {
    NSString *fileDirectoryPath = [[self directoryPath] stringByAppendingPathComponent:[[self class] md5:identifier]];
    NSString *framePath = [fileDirectoryPath stringByAppendingPathComponent:[@(idx) stringValue]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:framePath]) return nil;
    return [NSKeyedUnarchiver unarchiveObjectWithFile:framePath];
}

- (NSString *)directoryPath {
    NSString *rootPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *fileDirectory = [rootPath stringByAppendingPathComponent:@"com.picasso.animated.photo"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileDirectory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:fileDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return fileDirectory;
}

+ (NSString *)md5:(NSString *)string{
    const char *cStr = [string UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);
    
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02X", digest[i]];
    }
    
    return result;
}

@end
