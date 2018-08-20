//
//  PicassoBaseImageLog.m
//  Picasso
//
//  Created by welson on 2018/5/29.
//

#import "PicassoBaseImageLog.h"
#import "NVCodeLogger.h"
#import "PicassoImageCompat.h"

@implementation PicassoBaseImageLog

- (void)printMethod {
    NSLog(@"+++ -----------------------------------");
    NSLog(@"+++ URL: %@", self.requestURL);
    NSLog(@"+++ DisplayTime: %@", @(self.finishedTime));
    NSLog(@"+++ SourceType: %@", [self fetchSourceWithType:self.fetchSource]);
    NSLog(@"+++ DiskTime: %@", @(self.diskFetchedTime));
    NSLog(@"+++ Wait To Remote: %@", @(self.waitToDownloadTime));
    NSLog(@"+++ RemoteTime: %@", @(self.downloadTime));
    NSLog(@"+++ Data Length: %@k", @(self.byteLength / 1024.0));
    if (self.error) NSLog(@"+++ %@", self.error.localizedDescription);
    NSLog(@"+++ -----------------------------------");
}

- (void)addLog {
    if (self.requestURL.length == 0) return;
    pcs_log_dispatch_async_safe(^{
        NSString *prefix = self.error?@"PicassoBaseImageError":(self.finishedTime > 10?@"PicassoBaseImageLogException":@"PicassoBaseImageLog");
        NVLog(@"%@: URL = %@, displayTotalTime = %@, fetchSource = %@, diskVisitedTime = %@, remoteQueueWaitingTime = %@, remoteFetchTime = %@, dataLength = %@k, error = %@", prefix, self.requestURL, @(self.finishedTime), [self fetchSourceWithType:self.fetchSource], @(self.diskFetchedTime), @(self.waitToDownloadTime), @(self.downloadTime), @(self.byteLength/1024.0), self.error);
    });
}

- (NSString *)fetchSourceWithType:(PicassoLogFetchSource)source {
    switch (source) {
        case PicassoLogFetchSourceDisk:
            return @"Disk";
        case PicassoLogFetchSourceMemory:
            return @"Memory";
        case PicassoLogFetchSourceRemote:
            return @"Remote";
        case PicassoLogFetchSourceCancelled:
            return @"Cancelled";
        default:
            break;
    }
    return @"";
}

@end
