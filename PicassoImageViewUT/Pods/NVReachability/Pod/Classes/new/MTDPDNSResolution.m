//
//  MTDPDNSResolution.m
//  NVReachability
//
//  Created by xiangnan.yang on 2017/12/19.
//

#import "MTDPDNSResolution.h"
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#import "MTDPPing.h"
#import "NSThread+Reachability.h"

@interface MTDPDNSResolution ()

@property (nonatomic, copy, readwrite, nullable) NSString *IPAddress;
@property (nonatomic, copy) NSString * hostName;
@property (nonatomic, strong) NSMutableArray * blockArray;

@end

@implementation MTDPDNSResolution

- (instancetype)init{
    if (self = [super init]) {
    }
    return self;
}

#pragma mark sync

+ (NSArray *)syncResoluteWithHost:(NSString *)hostName{
    if (!hostName){
        return nil;
    }
    CFHostRef hostRef = CFHostCreateWithName(kCFAllocatorDefault, (__bridge CFStringRef)hostName);
    CFHostStartInfoResolution(hostRef, kCFHostAddresses, NULL);
    NSArray *array    = [self hostResolution:hostRef];
    CFRelease(hostRef);
    return array;
}

+ (NSArray *)hostResolution:(CFHostRef)hostRef{
    Boolean resolved;
    NSArray *addresses = (__bridge NSArray *)CFHostGetAddressing(hostRef, &resolved);
    __block NSMutableArray *ret = [[NSMutableArray alloc] init];
    if (resolved && (addresses != nil))
    {
        for (NSData *address in addresses)
        {
            const struct sockaddr *addrPtr;
            addrPtr = (const struct sockaddr *)address.bytes;
            if (address.length >= sizeof(struct sockaddr))
            {
                char *s = NULL;
                switch (addrPtr->sa_family)
                {
                    case AF_INET:
                    {
                        struct sockaddr_in *addr_in = (struct sockaddr_in *)addrPtr;
                        s = malloc(INET_ADDRSTRLEN);
                        inet_ntop(AF_INET, &(addr_in->sin_addr), s, INET_ADDRSTRLEN);
                        if (s != NULL)
                        {
                            [ret addObject:[NSString stringWithUTF8String:s]];
                        }
                    }
                        break;
                    case AF_INET6:
                    {
                        struct sockaddr_in6 *addr_in6 = (struct sockaddr_in6 *)addrPtr;
                        s = malloc(INET6_ADDRSTRLEN);
                        inet_ntop(AF_INET6, &(addr_in6->sin6_addr), s, INET6_ADDRSTRLEN);
                        if (s != NULL)
                        {
                            [ret addObject:[NSString stringWithUTF8String:s]];
                        }
                    }
                        break;
                }
            }
        }
    }
    return ret.copy;
}

#pragma mark async

//- (void)asyncResoluteWithHost:(NSString *)hostName callBack:(void (^)(NSString *result))block{
//    @synchronized(self.blockArray){
//        [self.blockArray addObject:block];
//    }
//    [[NSThread threadForReachability] performRBBlock:^{
//        Boolean             success;
//        CFHostClientContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
//        CFStreamError       streamError;
//        CFHostRef host =  (CFHostRef) CFAutorelease( CFHostCreateWithName(NULL, (__bridge CFStringRef) hostName));
//        if (host == NULL) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                block(nil);
//            });
//            return;
//        }
//        CFHostSetClient(host, MTDPHostResolveCallback, &context);
//        CFHostScheduleWithRunLoop(host, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
//        success = CFHostStartInfoResolution(host, kCFHostAddresses, &streamError);
//        if ( !success ) {
//            CFHostSetClient(host, NULL, NULL);
//            CFHostUnscheduleFromRunLoop(host, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
//            host = NULL;
//        }
//    }];
//
//}

//static void MTDPHostResolveCallback(CFHostRef theHost, CFHostInfoType typeInfo, const CFStreamError *error, void *info) {
//    MTDPDNSResolution *    self;
//    self = (__bridge MTDPDNSResolution *) info;
//    assert([self isKindOfClass:[MTDPDNSResolution class]]);
//#pragma unused(typeInfo)
//    assert(typeInfo == kCFHostAddresses);
//    if ( ((error != NULL) && (error->domain != 0)) || !self) {
//
//    } else {
//        NSArray *array = [self hostResolution:theHost];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            @synchronized(self.blockArray){
//                NSArray *array = [NSArray arrayWithArray:self.blockArray];
//
////                [self.blockArray addObject:block];
//            }
////            block(nil);
//        });
//    }
//}



//- (void)stopHostResolution {
//    if (self.host != NULL) {
//        NSLog(@"stopHostResolution");
//        CFHostSetClient(self.host, NULL, NULL);
//        CFHostUnscheduleFromRunLoop(self.host, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
//        self.host = NULL;
//    }
//}

//- (NSMutableArray *)blockArray{
//    static dispatch_once_t once;
//    dispatch_once(&once, ^{
//        _blockArray = [NSMutableArray new];
//    });
//    return _blockArray;
//}

- (void)dealloc{
//    [self stopHostResolution];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
//    [NSThread releaseReachabilityThread];
    NSLog(@"%s dealloc",__func__);
}



@end
