//
//  PicassoDownloadImageSignal.m
//  Pods
//
//  Created by Courser on 18/09/2017.
//
//

#import "PicassoDownloadImageSignal.h"
#import "PicassoDownLoadHelper.h"
#import <objc/runtime.h>
#import "PicassoFetchOperationProtocol.h"
#import "NVCodeLogger.h"
#import "PicassoFetchImageSignal.h"
#import "PicassoWebpImageDecoder.h"
#import "PicassoImageDecoder.h"
#import "PicassoBaseHelper.h"
#import "PicassoSaveCacheHelper.h"
#import <pthread.h>
#import "NVMonitorCenter.h"

#define kDefaultUploadPercent       10
NSString *const CRPicassoImageCacheErrorDomain = @"PicassoImageCacheErrorDomain";

static dispatch_queue_t downloadQueue;
static dispatch_queue_t serialQueue;
static dispatch_semaphore_t semaphore;
static pthread_mutex_t _downloadLock;

@interface PicassoDownloadImageSignal () <PicassoFetchOperationProtocol>

@property (nonatomic, weak) NSURLSessionTask *task;  // 网络请求 weak
@property (nonatomic, strong) NSString *identifier;  // 请求的唯一标识
@property (nonatomic, copy) NSString *internalIdentifier;
@property (nonatomic, assign, readwrite) NSTimeInterval downloadTimeForImage;
@property (nonatomic, assign) NSTimeInterval startTime;  // 请求开始时间
@property (nonatomic, strong) PicassoSaveCacheHelper *cacheHelper;
@property (nonatomic, strong) RACDisposable *downloadDisposable;
@property (nonatomic, assign) BOOL isDisposed;
@property (nonatomic, strong) RACSubject *subject;

@end

@implementation PicassoDownloadImageSignal

- (instancetype)init {
    if (self = [super init]) {
        _isDisposed = NO;
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            downloadQueue = dispatch_queue_create("downloadQueue", DISPATCH_QUEUE_CONCURRENT);
            serialQueue = dispatch_queue_create("serialQueue",DISPATCH_QUEUE_SERIAL);
            semaphore = dispatch_semaphore_create(6);
            pthread_mutex_init(&_downloadLock, NULL);
        });
        
        _subject = [RACSubject subject];
        self.enableMemCache = YES;
        self.enableDiskCache = YES;
    }
    return self;
}

- (RACSignal *)downloadSignalWithIndentifier:(NSString *)identifier {
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        self.identifier = identifier;
        self.internalIdentifier = [PicassoBaseHelper translatedUrlString:identifier];
        if (!self.timeoutIntervalForRequest) {
            self.timeoutIntervalForRequest = 15.0;
        }
        self.cacheHelper = [PicassoSaveCacheHelper sharedCacheHelper];
        
        dispatch_async(serialQueue, ^{
            NSTimeInterval st = CACurrentMediaTime();
//            NVLog(@"picasso enter manage queue ,url: %@ , currentTime: %@",self.identifier, [self convertDateToString:[NSDate date]]);
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            self.log.waitToDownloadTime = CACurrentMediaTime() - st;
            pthread_mutex_lock(&_downloadLock);
            if (!self.isCanceled) {
                self.isExecuting = YES;
                dispatch_async(downloadQueue, ^{
//                    NVLog(@"picasso enter download queue ,url: %@ , currentTime: %@",self.identifier, [self convertDateToString:[NSDate date]]);
                    self.downloadDisposable = [self.subject subscribeNext:^(id x) {
                        
                        if ([NSThread isMainThread]) {
                            [subscriber sendNext:x];
                            [subscriber sendCompleted];
                        }else {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [subscriber sendNext:x];
                                [subscriber sendCompleted];
                            });
                        }
                        
                    }];
                    [self downloadImage];
                });
            }else {
                dispatch_semaphore_signal(semaphore);
            }
            pthread_mutex_unlock(&_downloadLock);
        });
        
        return [RACDisposable disposableWithBlock:^{
            self.isDisposed = YES;
        }];
    }];
}

- (void)cancel {
    pthread_mutex_lock(&_downloadLock);
    [super cancel];
    [_downloadDisposable dispose];
    _isDisposed = YES;
    objc_setAssociatedObject(self.task, "signal", nil, OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(self.task, "mark", nil, OBJC_ASSOCIATION_RETAIN);
    [self.task cancel];
    if (self.isExecuting) {
        dispatch_semaphore_signal(semaphore);
    }
    pthread_mutex_unlock(&_downloadLock);
}

- (void)downloadImage {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.internalIdentifier] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:self.timeoutIntervalForRequest];
    request.allHTTPHeaderFields = self.HTTPAdditionalHeaders;
    self.task = [[PicassoDownLoadHelper shareInstance].downloadImageSession downloadTaskWithRequest:request];
    objc_setAssociatedObject(self.task, "signal", self, OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(self.task, "mark", self.mark, OBJC_ASSOCIATION_RETAIN);
    [self.task resume];
    self.startTime = CACurrentMediaTime();
    //    self.isExecuting = YES;
}

+ (UIImage *)decodeImageWithOriginImage:(UIImage *)originImage {
    if (!originImage) return nil;
    return [PicassoImageDecoder decodeImageWithOriginImage:originImage];
}

#pragma mark protocol
- (void)downloadTaskProgressChanged:(NSUInteger)progress {
    
}

- (void)downloadTaskHaveFinished:(NSData *)data andError:(NSError *)error code:(NSInteger)code {
    [[self processDataToImageWithData:data andError:error code:code] subscribeNext:^(RACTuple *tuple) {
        [self.subject sendNext:tuple];
        [self.subject sendCompleted];
    }];
}

- (RACSignal *)processDataToImageWithData:(NSData *)data andError:(NSError *)error code:(NSInteger)code {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        if (self.isDisposed) return nil;
        dispatch_semaphore_signal(semaphore);
        self.isExecuting = NO;
        self.isFinished = YES;
        if (!self.subject) return nil;
        NSTimeInterval ed = CACurrentMediaTime();
        self.downloadTimeForImage = ed - self.startTime;
        self.log.downloadTime = self.downloadTimeForImage;
        self.log.fetchSource = PicassoLogFetchSourceRemote;
        self.log.byteLength = data.length;
        
        int millis = self.downloadTimeForImage * 1000;
        [[NVMonitorCenter defaultCenter] pvWithCommand:[NSString stringWithFormat:@"_pic_%@",self.internalIdentifier] network:0 code:(int)code tunnel:0 requestBytes:0 responseBytes:(int)data.length responseTime:millis ip:nil uploadPercent:kDefaultUploadPercent];
        
        if (error) {
            [[NVMonitorCenter defaultCenter] pvWithCommand:@"downloadphotoerror" network:0 code:(int)(error.code<0?error.code-20000:error.code+20000) tunnel:0 requestBytes:0 responseBytes:(int)data.length responseTime:millis ip:nil uploadPercent:100 extend:self.internalIdentifier];
            self.log.error = error;
            RACTupleNil *tupleNil = [RACTupleNil tupleNil];
            RACTuple *tuple = [RACTuple tupleWithObjects:tupleNil,@(NO),tupleNil,@(CRPicassoImageCacheTypeNone),error, nil];
            [subscriber sendNext:tuple];
            [subscriber sendCompleted];
//            NVLog(@"download photo error, url:%@, error code: %@", self.internalIdentifier, @(error.code));
            
            //ATS错误
            if (error.code == -1022) {
                NVAssert(NO, [self atsErrorDescription]);
            }
            
        } else if (data == nil || data.length == 0) {
            NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
            [errorDetail setValue:@"Image data is nil." forKey:NSLocalizedDescriptionKey];
            [errorDetail setValue:[NSString stringWithFormat:@"Error url: %@",self.internalIdentifier] forKey:NSLocalizedFailureReasonErrorKey];
            NSError *error = [NSError errorWithDomain:CRPicassoImageCacheErrorDomain code:CRPicassoImageErrorCodeEmptyData userInfo:errorDetail];
            [[NVMonitorCenter defaultCenter] pvWithCommand:@"downloadphotoerror" network:0 code:(CRPicassoImageErrorCodeEmptyData + 11000) tunnel:0 requestBytes:0 responseBytes:(int)data.length responseTime:0 ip:nil uploadPercent:100 extend:self.internalIdentifier];
            self.log.error = error;
            RACTupleNil *tupleNil = [RACTupleNil tupleNil];
            RACTuple *tuple = [RACTuple tupleWithObjects:tupleNil,@(NO),tupleNil,@(CRPicassoImageCacheTypeNone),error, nil];
            [subscriber sendNext:tuple];
            [subscriber sendCompleted];
//            NVLog(@"download photo data is nil, url:%@", self.internalIdentifier);
        } else {
            NSError *error = nil;
            PicassoDecodedImage *decodedImage = [[PicassoDecodedImage alloc] initWithData:data];
            if (decodedImage.imageType == PicassoImageTypeWebp) {
                if (decodedImage.imageObj.frameCount == 1) {
                    if (self.enableMemCache) {
                        [self.cacheHelper saveToMemoryCacheWithImage:decodedImage.imageObj.windowFrame WithIdentifier:self.identifier cacheType:self.cacheType];
                    }
                }
            }
            if (!decodedImage.imageObj.windowFrame) {
                NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
                [errorDetail setValue:@"Failed to create an image from remote data." forKey:NSLocalizedDescriptionKey];
                [errorDetail setValue:[NSString stringWithFormat:@"Error url: %@",self.internalIdentifier] forKey:NSLocalizedFailureReasonErrorKey];
                error = [NSError errorWithDomain:CRPicassoImageCacheErrorDomain code:CRPicassoImageErrorCodeIncompleteData userInfo:errorDetail];
                [[NVMonitorCenter defaultCenter] pvWithCommand:@"downloadphotoerror" network:0 code:(CRPicassoImageErrorCodeIncompleteData + 11000) tunnel:0 requestBytes:0 responseBytes:(int)data.length responseTime:0 ip:nil uploadPercent:100 extend:self.internalIdentifier];
                RACTupleNil *tupleNil = [RACTupleNil tupleNil];
                RACTuple *tuple = [RACTuple tupleWithObjects:tupleNil,@(NO),tupleNil,@(CRPicassoImageCacheTypeNone),error, nil];
                [subscriber sendNext:tuple];
                [subscriber sendCompleted];
//                NVLog(@"failed to create an image from remote data, url:%@", self.internalIdentifier);
                return nil;
            }
            if (decodedImage.imageData) {
                if (self.enableDiskCache) {
                    [self.cacheHelper saveToDiskWithImageData:decodedImage.imageData WithIdentifier:self.identifier cacheType:self.cacheType];
                }
            }
            if (decodedImage.imageType != PicassoImageTypeGif && decodedImage.imageType != PicassoImageTypeWebp) {
                if (self.enableMemCache) {
                    [self.cacheHelper saveToMemoryCacheWithImage:decodedImage.imageObj.windowFrame WithIdentifier:self.identifier cacheType:self.cacheType];
                }
            }
            self.log.error = error;
            RACTuple *tuple = [RACTuple tupleWithObjects:self,@(YES),decodedImage,@(CRPicassoImageCacheTypeNone),error, nil];
            [subscriber sendNext:tuple];
            [subscriber sendCompleted];
        }
        return nil;
    }];
}

- (NSString *)atsErrorDescription {
    NSMutableString *string = [NSMutableString new];
    [string appendFormat:@"OriginUrl:%@|", self.identifier?:@""];
    [string appendFormat:@"InternalUrl:%@|", self.internalIdentifier?:@""];
    BOOL needChange = [PicassoBaseHelper needChangeHTTP2HTTPS];
    [string appendFormat:@"Need Transform:%@|", @(needChange)];
    if (!needChange) return string.copy;
    
    NSRange schemeRange = [self.internalIdentifier rangeOfString:@"://"];
    if (schemeRange.location == NSNotFound) {
        [string appendFormat:@"Cannot find scheme"];
        return string.copy;
    }
    NSString *scheme = [self.internalIdentifier substringWithRange:NSMakeRange(0, schemeRange.location)];
    [string appendFormat:@"Scheme:%@|", scheme];
    if (!([scheme compare:@"http" options:NSCaseInsensitiveSearch] == NSOrderedSame)) {
        [string appendFormat:@"Scheme is not http"];
        return string.copy;
    }
    [string appendFormat:@"TranslatedUrl:%@", [self.internalIdentifier stringByReplacingCharactersInRange:NSMakeRange(0, schemeRange.location) withString:@"https"]];
    return string.copy;
}

- (void)dealloc {
    
}

@end
