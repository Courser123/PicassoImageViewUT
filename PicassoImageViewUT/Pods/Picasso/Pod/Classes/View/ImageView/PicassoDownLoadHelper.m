//
//  PicassoDownLoadHelper.m
//  Pods
//
//  Created by Johnny on 15/12/29.
//
//
#import "PicassoDownLoadHelper.h"
#import "PicassoFetchOperationProtocol.h"
#import <objc/runtime.h>
#import "NVCodeLogger.h"
#import "PicassoBaseHelper.h"

static PicassoDownLoadHelper *__downloadHelper;
static dispatch_once_t initHelperTag;

@interface PicassoDownLoadHelper ()<NSURLSessionDownloadDelegate, NSURLSessionDelegate>

@property (nonatomic, readwrite, strong) NSURLSession *downloadImageSession;
@property (nonatomic, assign) NSInteger sessionTaskCount;

@end

@implementation PicassoDownLoadHelper

- (instancetype)init{
    if (self = [super init]) {
        _downloadImageSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
    }
    return self;
}

+ (PicassoDownLoadHelper *)shareInstance{
    dispatch_once(&initHelperTag, ^{
        __downloadHelper = [[self alloc] init];
    });
    return __downloadHelper;
}

- (NSURLSession *)downloadImageSession  {
    @synchronized(__downloadHelper) {
        if (__downloadHelper.sessionTaskCount < 30) {
            __downloadHelper.sessionTaskCount ++;
            return _downloadImageSession;
        }else {
            [_downloadImageSession finishTasksAndInvalidate];
            _downloadImageSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
            __downloadHelper.sessionTaskCount = 1;
            return _downloadImageSession;
        }
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(nonnull NSURL *)location{
    NSData *data = [NSData dataWithContentsOfURL:location];
    
    NSInteger code = [downloadTask.response isKindOfClass:[NSHTTPURLResponse class]] ? [(NSHTTPURLResponse *)downloadTask.response statusCode] : 200;
    
    id <PicassoFetchOperationProtocol> signal = objc_getAssociatedObject(downloadTask, "signal");
    
    [signal downloadTaskHaveFinished:data andError:nil code:code];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    
    id <PicassoFetchOperationProtocol> signal = objc_getAssociatedObject(downloadTask, "signal");
    [signal downloadTaskProgressChanged:(NSUInteger)(100 * totalBytesWritten / totalBytesExpectedToWrite)];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if (!error) return;
    NSInteger code = [task.response isKindOfClass:[NSHTTPURLResponse class]] ? [(NSHTTPURLResponse *)task.response statusCode] : error.code;
    
    id <PicassoFetchOperationProtocol> signal = objc_getAssociatedObject(task, "signal");
    [signal downloadTaskHaveFinished:nil andError:error code:code];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler {
    
    if ([request.URL.scheme isEqualToString:@"http"]) {
        UIResponder *mark = objc_getAssociatedObject(task, "mark");
        UIResponder *tempMark = mark;
        NSMutableString *nmStr = [NSMutableString string];
        while (![[tempMark nextResponder] isKindOfClass:[UIViewController class]]) {
            [tempMark nextResponder];
            [nmStr appendString:[NSString stringWithFormat:@"%@",[tempMark nextResponder]]];
        }
        NVLog(@"redirect to a http request, originURL: %@, redirectURL:%@", task.currentRequest.URL.absoluteString, request.URL.absoluteString);
        NVAssert(NO, @"redirect to a http request, originURL: %@, redirectURL:%@ , responderChain:%@", task.currentRequest.URL.absoluteString, request.URL.absoluteString,nmStr);
    }
    
    NSURL *url = [PicassoBaseHelper translatedUrl:request.URL];
    if (!url) {
        completionHandler(nil);
        return;
    }
    NSMutableURLRequest *newRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:request.timeoutInterval];
    newRequest.allHTTPHeaderFields = request.allHTTPHeaderFields;
    completionHandler(newRequest.copy);
}


@end
