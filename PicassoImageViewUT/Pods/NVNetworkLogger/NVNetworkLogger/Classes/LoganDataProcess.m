//
//  LoganDataProcess.m
//  Pods
//
//  Created by yxn on 2017/5/23.
//
//

#import "LoganDataProcess.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonKeyDerivation.h>
#include <CommonCrypto/CommonDigest.h>
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import <zlib.h>
#import "aes_util.h"
#import "LoganUtils.h"
#include "clogan_core.h"
#import "Logan.h"

@interface LoganDataProcess ()

@end

@implementation LoganDataProcess{
    CCCryptorRef _encryptCryptor;
    CCCryptorStatus _encryptResult;
    z_stream _strm;
    
    NSString *_key;
    NSString *_iv;
}

+ (instancetype)sharedInstance {
    static id gInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gInstance = [self new];
    });
    return gInstance;
}

- (instancetype)init{
    if (self = [super init]) {
        _encryptCryptor = NULL;
        [self reset];
        _key = [self cryptKey];
        _iv = @"55C930D827BDABFD";
    }
    return self;
}

- (void)initAndOpenCLib {
    clogan_setCatUpload(&log2Cat);
    int max_file = [[LoganUtils sharedInstance] maxLogFile]*1024*1024;
    const char *path = [LoganUtils loganLogDirectory].UTF8String;
    char *key = (char *)_key.UTF8String;
    clogan_init(path,path, max_file, key,(int)strlen(key));
    NSString *today = [LoganUtils currentDate];
    clogan_open((char *)today.UTF8String);
}

- (NSString *)cryptKey
{
#if TARGET_IPHONE_SIMULATOR
    return @"1234567812345678";
#else
    NSString *deviceKey = [self deviceKey];
    NSData *keyData = [deviceKey dataUsingEncoding:NSUTF8StringEncoding];
    NSString *key = [self md5:keyData];
    return key;
#endif
}

- (NSString *)deviceKey
{
    NSString *deviceId = [self GRUDID];
    if (!deviceId || deviceId.length == 0) {
        deviceId = [self keyForPasswordEncrypt];
    }
    NSData *deviceData = [[deviceId stringByAppendingString:[self keyForPasswordEncrypt]] dataUsingEncoding:NSUTF8StringEncoding];
    NSString *deviceKey = [self md5:deviceData];
    return deviceKey;
}

- (NSString *)keyForPasswordEncrypt
{
    NSString * ss = @"$*^%&[]_+";
    return [NSString stringWithFormat:@"ZhJtTxn%@", ss];
}

- (NSString*)md5:(NSData*)data
{
    NSString *md5Str = [self data_md5:data];
    return [md5Str substringToIndex:16];
}

- (NSString*)data_md5:(NSData*)data
{
    if (data.length == 0) {
        return @"";
    }
    
    CC_MD5_CTX md5_ctx;
    CC_MD5_Init(&md5_ctx);
    
    CC_MD5_Update(&md5_ctx, [data bytes], (unsigned int)[data length]);
    
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(result, &md5_ctx);
    
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[10], result[13], result[7], result[5],
            result[12], result[9], result[8], result[14],
            result[6], result[3], result[15], result[11],
            result[1], result[4], result[2], result[0]
            ];
}

- (NSString *)GRUDID
{
    return [[UIDevice currentDevice].identifierForVendor UUIDString];
}


- (NSData *)processData:(NSString *)data {
    if (data.length == 0) {
        return nil;
    }
    
    NSData *compressData = [self compressData:data isProcessEnd:YES];
    if (!compressData) {
        return nil;
    }
    NSData *encryptData = [self encryptData:compressData streamEnd:YES];
    if (!encryptData) {
        return nil;
    }
    
    [self reset];
    
    // 转换为待写入数据
    Byte start = '\3';
    Byte end = '\0';
    NSMutableData *rData = [NSMutableData data];
    [rData appendBytes:&start length:1];
    NSUInteger length = encryptData.length;
    Byte l = (Byte)(length>>24);
    [rData appendBytes:&l length:1];
    l = (Byte)(length>>16);
    [rData appendBytes:&l length:1];
    l = (Byte)(length>>8);
    [rData appendBytes:&l length:1];
    l = (Byte)length;
    [rData appendBytes:&l length:1];
    [rData appendData:encryptData];
    [rData appendBytes:&end length:1];
    return rData;
}

- (NSData *)compressData:(NSString *)data isProcessEnd:(BOOL)isEnd{
    NSData *inputData = [data dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger inputDataLength = inputData.length;
    uLong prevTotalOut = _strm.total_out;
    
    _strm.next_in = (Bytef *)[inputData bytes];//被压缩字符串
    _strm.avail_in = (uInt)inputDataLength;//被压缩字符串长度
    NSMutableData *compressedData = [NSMutableData dataWithLength:(inputDataLength + 16)];

    do {
        if ((_strm.total_out - prevTotalOut) >= [compressedData length])
            [compressedData increaseLengthBy: inputDataLength];
        
        _strm.next_out = [compressedData mutableBytes] + (_strm.total_out - prevTotalOut);
        _strm.avail_out = (uInt)([compressedData length] - (_strm.total_out - prevTotalOut));
        deflate(&_strm, isEnd?Z_FINISH:Z_NO_FLUSH);
    } while (_strm.avail_out == 0);
    if (isEnd) {
        if (deflateEnd (&_strm) != Z_OK)
            return nil;
    }
    if (compressedData.length > (_strm.total_out - prevTotalOut)) {
        [compressedData setLength: (_strm.total_out - prevTotalOut)];
    }
    return compressedData;
}

- (NSData *)encryptData:(NSData *)data streamEnd:(BOOL)isStreamEnd{
    if (_encryptCryptor == NULL) {
        NSData *iv = [self randomDataOfLength:kCCBlockSizeAES128];
        NSData *key = [self AESKeyForPassword:_key];
        _encryptResult = CCCryptorCreate(kCCEncrypt,             // operation
                                         kCCAlgorithmAES128,            // algorithim
                                         kCCOptionPKCS7Padding, // options
                                         key.bytes,             // key
                                         key.length,            // keylength
                                         iv.bytes,              // IV
                                         &_encryptCryptor);
        
        if (_encryptResult != kCCSuccess || _encryptCryptor == NULL) {
            return nil;
        }
    }
    
    size_t dstBufferSize = data.length + kCCKeySizeAES128;
    NSMutableData *dstData = [NSMutableData dataWithLength:dstBufferSize];
    uint8_t *dstBytes = dstData.mutableBytes;
    size_t dstLength = 0; 
    _encryptResult = CCCryptorUpdate(_encryptCryptor,
                                     [data bytes],      // dataIn
                                     (size_t)data.length,     // dataInLength
                                     dstBytes,      // dataOut
                                     dstBufferSize, // dataOutAvailable
                                     &dstLength);   // dataOutMoved
    
    if (_encryptResult != kCCSuccess) {
        return nil;
    }
    if (isStreamEnd) {
        NSMutableData *finalData =[dstData subdataWithRange:NSMakeRange(0, dstLength)].mutableCopy;
        _encryptResult = CCCryptorFinal(_encryptCryptor,        // cryptor
                                        dstBytes,       // dataOut
                                        dstBufferSize,  // dataOutAvailable
                                        &dstLength);    // dataOutMoved
        if (_encryptResult != kCCSuccess) {
            return nil;
        }
        [finalData appendData:[NSData dataWithBytes:dstBytes length:dstLength]];
        return finalData;
    }
    return [dstData subdataWithRange:NSMakeRange(0, dstLength)];
}

- (NSData *)randomDataOfLength:(size_t)length {
    char ivPtr[length + 1];
    bzero( ivPtr, sizeof(ivPtr) );
    [_iv getCString: ivPtr maxLength:sizeof(ivPtr) encoding: NSUTF8StringEncoding];
    return [NSMutableData dataWithBytes:ivPtr length:length];
}

- (NSData *)AESKeyForPassword:(NSString *)password{
    char keyPtr[kCCKeySizeAES128 + 1]; // room for terminator (unused)
    bzero( keyPtr, sizeof(keyPtr) ); // fill with zeroes (for padding)
    [password getCString: keyPtr maxLength: sizeof(keyPtr) encoding: NSUTF8StringEncoding];
    return [NSMutableData dataWithBytes:keyPtr length:(kCCKeySizeAES128)];
}

- (void)reset{
    if (_encryptCryptor) {
        CCCryptorRelease(_encryptCryptor);
        _encryptCryptor = NULL;
    }
    
    bzero(&_strm, sizeof(_strm));
    _strm.zalloc = Z_NULL;
    _strm.zfree = Z_NULL;
    _strm.opaque = Z_NULL;
    _strm.total_out = 0;
    deflateInit2(&_strm, Z_DEFAULT_COMPRESSION, Z_DEFLATED, (15+16), 8, Z_DEFAULT_STRATEGY);//压缩
}

@end
