//
//  PicassoHost.m
//  Pods
//
//  Created by 纪鹏 on 2017/5/26.
//
//

#import "PicassoHost.h"
#import "PicassoBridgeContext.h"
#import "PicassoHostManager.h"
#import "PicassoBridgeModule.h"
#import "PicassoThreadManager.h"
#import "PicassoMonitorEntity.h"
#import "PicassoHost+Private.h"

@interface PicassoHost ()
@property (nonatomic, copy) NSString *jsContent;
@end

@implementation PicassoHost

- (instancetype)init {
    self = [super init];
    if (self) {
        NSInteger pId = 0;
        @synchronized(self){
            static NSInteger __pId = 0;
            pId = __pId % (1024*1024);
            __pId++;
        }
        _hostId = [NSString stringWithFormat:@"%ld", (long)pId];
        [PicassoHostManager saveHost:self forHostId:_hostId];
        _moduleInstanceMapper = [NSMutableDictionary new];
        _monitorEntity = [PicassoMonitorEntity new];
    }
    return self;
}

+ (instancetype)hostWithScript:(NSString *)script options:(NSDictionary *)options data:(NSDictionary *)intentData {
    PicassoHost *host = [[self alloc] init];
    [host createControllerWithScript:script options:options data:intentData];
    return host;
}

- (void)createControllerWithScript:(NSString *)script options:(NSDictionary *)options stringData:(NSString *)strData {
    if (script.length == 0) {
        NSAssert(false, @"empty script for jsname:%@", self.alias);
        return;
    }
    self.jsContent = script;
    self.intentData = strData;
    [[PicassoBridgeContext sharedInstance] createPCWithHostId:self.hostId jsScript:script options:options stringData:strData];
}

- (void)createControllerWithScript:(NSString *)script options:(NSDictionary *)options data:(NSDictionary *)intentData {
    if (script.length == 0) {
        NSAssert(false, @"empty script for jsname:%@", self.alias);
        return;
    }
    self.jsContent = script;
    self.intentData = intentData;
    [[PicassoBridgeContext sharedInstance] createPCWithHostId:self.hostId jsScript:script options:options data:intentData];
}

- (void)callControllerMethod:(NSString *)method argument:(NSDictionary *)args {
    [[PicassoBridgeContext sharedInstance] updatePCWithHostId:self.hostId method:method argument:args];
}

- (JSValue *)syncCallControllerMethod:(NSString *)method argument:(NSDictionary *)args {
    return [[PicassoBridgeContext sharedInstance] syncCallPCWithHostId:self.hostId method:method argument:args];
}

- (void)destroyHost {
    [self callControllerMethod:@"onDestroy" argument:nil];
    [[PicassoBridgeContext sharedInstance] destroyPCWithHostId:self.hostId];
    PCSRunOnBridgeThread(^{
        [PicassoHostManager removeHostFotId:self.hostId];
    });
}

- (void)dealloc {
    NSLog(@"picasso host:%@ dealloc",_hostId);
}

@end
