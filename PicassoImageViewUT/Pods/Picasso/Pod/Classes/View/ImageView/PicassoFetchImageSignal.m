//
//  PicassoFetchImageSignal.m
//  Pods
//
//  Created by Courser on 08/09/2017.
//
//

#import "PicassoFetchImageSignal.h"
#import "PicassoBaseHelper.h"
#import "PicassoWebpImageDecoder.h"
#import "PicassoImageDecoder.h"
#import <objc/runtime.h>
#import "PicassoDownloadImageSignal.h"
#import "PicassoSaveCacheHelper.h"
#import "PicassoBaseImageLubanConfig.h"

static dispatch_queue_t ioQueue;

@interface PicassoFetchImageSignal ()

@property (nonatomic, strong)   NSString *identifier;  // 请求的唯一标识
@property (nonatomic, assign, readwrite) NSTimeInterval decodeTimeForJPG;
@property (nonatomic, assign, readwrite) NSTimeInterval decodeTimeForWEBP;
@property (nonatomic, assign, readwrite) NSTimeInterval downloadTimeForImage;

@property (nonatomic, copy) NSString *internalIdentifier;
@property (nonatomic, strong) PicassoSaveCacheHelper *cacheHelper;
@property (nonatomic, strong) PicassoDownloadImageSignal *downloadSignal;
@property (nonatomic, assign) BOOL isDisposed;
@property (nonatomic, strong) RACSubject *fetchSubject;
@property (nonatomic, strong) RACDisposable *remoteDisposable;
@property (nonatomic, strong) RACDisposable *downloadDisposable;

@end

@implementation PicassoFetchImageSignal

- (RACSignal *)fetchSignalWithIdentifier:(NSString *)identifier {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ioQueue = dispatch_queue_create("ioQueue", DISPATCH_QUEUE_SERIAL);
    });
    
    _isDisposed = NO;
    _identifier = identifier;
    _internalIdentifier = [PicassoBaseHelper translatedUrlString:identifier];
    _timeoutIntervalForRequest = [PicassoBaseImageLubanConfig sharedInstance].timeoutIntervalForRequest;
    _cacheHelper = [PicassoSaveCacheHelper sharedCacheHelper];
    _fetchSubject = [RACSubject subject];
    
    // 返回的是RACSignal不是PicassoFetchImageSignal,所以无法直接订阅PicassoFetchImageSignal
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @weakify(self)
        self.disposable = [self.fetchSubject subscribeNext:^(RACTuple *x) {
            @strongify(self)
            RACTuple *tuple = [RACTuple tupleWithObjects:self, x.first, x.second, x.third, x.fourth, nil];
            
            if ([NSThread isMainThread]) {
                [subscriber sendNext:tuple];
                [subscriber sendCompleted];
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [subscriber sendNext:tuple];
                    [subscriber sendCompleted];
                });
            }
        }];
        [self fetch];
        
        return [RACDisposable disposableWithBlock:^{
            self.isDisposed = YES;
        }];
        
        return nil;
    }];
}

- (void)cancel {
    [super cancel];
    [self.disposable dispose];
    [self.remoteDisposable dispose];
    [self.downloadDisposable dispose];
    [self.downloadSignal cancel];
}

- (void)fetch {
//    NVLog(@"picasso start fetch image ,url: %@ , currentTime: %@",self.identifier, [self convertDateToString:[NSDate date]]);
    RACTuple *memTuple = [self readFromMemory];
    if (memTuple) {
        self.log.fetchSource = PicassoLogFetchSourceMemory;
        self.log.finishedTime = CACurrentMediaTime() - self.log.st;
        [_fetchSubject sendNext:memTuple];
        [_fetchSubject sendCompleted];
        return ;
    }
    
    if (self.syncReadFromDisk) {
        NSTimeInterval st = CACurrentMediaTime();
//        NVLog(@"picasso read from disk synchronously ,url: %@ , currentTime: %@",self.identifier, [self convertDateToString:[NSDate date]]);
        NSData *data = [_cacheHelper imageDataFromDiskCacheForKey:self.identifier cacheType:self.cacheType];
        RACTuple *tuple = [self readDiskCacheWithData:data];
        if (tuple) {
//            NVLog(@"picasso success in reading from disk synchronously ,url: %@ , currentTime: %@",self.identifier, [self convertDateToString:[NSDate date]]);
            self.log.byteLength = data.length;
            self.log.fetchSource = PicassoLogFetchSourceDisk;
            self.log.finishedTime = self.log.diskFetchedTime = CACurrentMediaTime() - st;
            [_fetchSubject sendNext:tuple];
            [_fetchSubject sendCompleted];
            return;
        }else {
            @weakify(self)
            self.remoteDisposable = [[self readFromRemote] subscribeNext:^(RACTuple *x) {
                @strongify(self)
                [self.fetchSubject sendNext:x];
                [self.fetchSubject sendCompleted];
            }];
        }
    }else {
        [[self readDiskCacheAsyncCompleted] subscribeNext:^(RACTuple *tuple) {
            if (tuple) {
                [self.fetchSubject sendNext:tuple];
                [self.fetchSubject sendCompleted];
            }else {
                @weakify(self)
                self.remoteDisposable = [[self readFromRemote] subscribeNext:^(RACTuple *x) {
                    @strongify(self)
                    [self.fetchSubject sendNext:x];
                    [self.fetchSubject sendCompleted];
                }];
            }
        }];
    }
}

- (RACTuple *)readFromMemory {
    
//    NVLog(@"picasso readFromMemory ,url: %@ , currentTime: %@",self.identifier, [self convertDateToString:[NSDate date]]);
    UIImage *resultImage = [_cacheHelper imageFromMemoryCacheForKey:self.identifier cacheType:self.cacheType];
    PicassoImageType imageType;
    NSData *imageData;
    if (resultImage) {
        imageType = PicassoImageTypeBitmap;
        if (self.needImageData) {
            imageType = PicassoImageTypePNG;
            imageData = UIImagePNGRepresentation(resultImage);
        }else {
            imageType = PicassoImageTypeWebp;
        }
        PicassoDecodedImage *decodedImage = [[PicassoDecodedImage alloc] initWithImage:resultImage imageType:imageType imageData:imageData];
        RACTuple *tuple = [RACTuple tupleWithObjects:@(YES),decodedImage,@(CRPicassoImageCacheTypeMemory),nil, nil];
        return tuple;
    }
    
    return nil;
}

- (RACSignal *)readDiskCacheAsyncCompleted {
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        dispatch_async(ioQueue, ^{
            if (self.isCanceled) return;
            @autoreleasepool {
//                NVLog(@"picasso read disk cache asynchronously ,url: %@ , currentTime: %@",self.identifier, [self convertDateToString:[NSDate date]]);
                NSTimeInterval st = CACurrentMediaTime();
                NSData *data = [self.cacheHelper imageDataFromDiskCacheForKey:self.identifier cacheType:self.cacheType];
                self.log.byteLength = data.length;
                self.log.fetchSource = PicassoLogFetchSourceDisk;
                self.log.finishedTime = self.log.diskFetchedTime = CACurrentMediaTime() - st;
                RACTuple *tuple = [self readDiskCacheWithData:data];
                [subscriber sendNext:tuple];
                [subscriber sendCompleted];
            }
        });
        
        return nil;
    }];
}

- (RACTuple *)readDiskCacheWithData:(NSData *)data {
    
    NSError *error;
    PicassoDecodedImage *decodedImage = [[PicassoDecodedImage alloc] initWithData:data];
    if (decodedImage.imageType == PicassoImageTypeWebp) {
        if (decodedImage.imageObj.frameCount == 1) {
            if (self.enableMemCache && !_isDisposed) {
                [_cacheHelper saveToMemoryCacheWithImage:decodedImage.imageObj.windowFrame WithIdentifier:self.identifier cacheType:self.cacheType];
            }
        }
    }
    if (decodedImage.imageObj.windowFrame) {
//        NVLog(@"picasso decode successfully ,url: %@ , currentTime: %@",self.identifier, [self convertDateToString:[NSDate date]]);
        if (decodedImage.imageType != PicassoImageTypeGif && decodedImage.imageType != PicassoImageTypeWebp) {
            if (self.enableMemCache && !_isDisposed) {
                [_cacheHelper saveToMemoryCacheWithImage:decodedImage.imageObj.windowFrame WithIdentifier:self.identifier cacheType:self.cacheType];
            }
        }
        RACTuple *tuple = [RACTuple tupleWithObjects:@(YES),decodedImage,@(CRPicassoImageCacheTypeDisk),error, nil];
        return tuple;
    }
    
//    NVLog(@"picasso decode unsuccessfully ,url: %@ , currentTime: %@",self.identifier, [self convertDateToString:[NSDate date]]);
    return nil;
    
}

- (RACSignal *)readFromRemote {
    // 网络下载图片
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @autoreleasepool {
//            NVLog(@"picasso download image ,url: %@ , currentTime: %@",self.identifier, [self convertDateToString:[NSDate date]]);
            PicassoDownloadImageSignal *signal = [[PicassoDownloadImageSignal alloc] init];
            self.downloadSignal = signal;
            signal.mark = self.mark;
            signal.enableMemCache = self.enableMemCache;
            signal.enableDiskCache = self.enableDiskCache;
            signal.HTTPAdditionalHeaders = self.HTTPAdditionalHeaders;
            signal.cacheType = self.cacheType;
            signal.timeoutIntervalForRequest = self.timeoutIntervalForRequest;
            signal.log = self.log;
            self.downloadDisposable = [[signal downloadSignalWithIndentifier:self.identifier] subscribeNext:^(RACTuple *x) {
                self.log.finishedTime = CACurrentMediaTime() - self.log.st;
                RACTuple *tuple = [RACTuple tupleWithObjects:x.second,x.third,x.fourth,x.fifth,nil];
                [subscriber sendNext:tuple];
                [subscriber sendCompleted];
            }];
        }
        
        return [RACDisposable disposableWithBlock:^{
            self.isDisposed = YES;
        }];
    }];
    
}

#pragma mark 同步获取图片
+ (UIImage *)imageWithData:(NSData *)data {
    if (!data.length) {
        return nil;
    }else {
        PicassoImageType type = [NSData picassoContentTypeForImageData:data];
        UIImage *image = nil;
        if (type == PicassoImageTypeWebp) {
            PicassoWebpImageDecoder *decoder = [PicassoWebpImageDecoder decoderWithData:data scale:[UIScreen mainScreen].scale];
            image = [decoder frameAtIndex:0 decodeForDisplay:YES].image;
        }else if (type == PicassoImageTypeGif) {
            image = [UIImage imageWithData:data];
        }else {
            UIImage *originImage = [UIImage imageWithData:data];
            image = [self decodeImageWithOriginImage:originImage];
        }
        
        return image;
    }
}

+ (RACSignal *)setImageData:(NSData *)data {
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        if (!data.length) {
            if ([NSThread isMainThread]) {
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
            }else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [subscriber sendNext:nil];
                    [subscriber sendCompleted];
                });
            }
        }else {
            
            PicassoDecodedImage *decodedImage = [[PicassoDecodedImage alloc] initWithData:data];
            if ([NSThread isMainThread]) {
                [subscriber sendNext:decodedImage];
                [subscriber sendCompleted];
            }else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [subscriber sendNext:decodedImage];
                    [subscriber sendCompleted];
                });
            }
        }
        return nil;
    }];
}

+ (UIImage *)decodeImageWithOriginImage:(UIImage *)originImage {
    if (!originImage) return nil;
    return [PicassoImageDecoder decodeImageWithOriginImage:originImage];
}

-(void)dealloc {
    [self cancel];
}

@end
