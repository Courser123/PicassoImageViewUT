//
//  PicassoVCModule.m
//  CocoaAsyncSocket
//
//  Created by 纪鹏 on 2017/8/17.
//

#import "PicassoVCModule.h"
#import "PicassoVCHost.h"
#import "PicassoViewMethod.h"
#import "PicassoThreadManager.h"
#import "PicassoVCHost+VCView.h"
#import "PicassoHost+Private.h"
#import "PicassoVCHost+Private.h"

@implementation PicassoVCModule

PCS_EXPORT_METHOD(@selector(needLayout))
PCS_EXPORT_METHOD(@selector(commandNative:))
PCS_EXPORT_METHOD(@selector(sendMsg:))
PCS_EXPORT_METHOD(@selector(needChildLayout:))

- (void)needLayout {
    if ([self.host isKindOfClass:[PicassoVCHost class]]) {
        PicassoVCHost *vcHost = (PicassoVCHost *)self.host;
        [vcHost layout];
    }
}

- (void)commandNative:(NSDictionary *)params {
    NSString *viewId = params[@"id"];
    NSString *methodName = params[@"method"];
    NSDictionary *args = params[@"args"];
    PicassoViewMethod *viewMethod = [[PicassoViewMethod alloc] initWithHostId:self.host.hostId viewId:viewId method:methodName arguments:args];
    PCSRunOnMainThread(^{
        [viewMethod invoke];
    });
}

- (void)sendMsg:(NSDictionary *)params {
    if (![params isKindOfClass:[NSDictionary class]]) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    PCSRunOnMainThread(^{
        PicassoVCHost *vcHost = (PicassoVCHost *)weakSelf.host;
        if (vcHost.msgBlock) {
            vcHost.msgBlock(params);
        }
    });
}

- (void)needChildLayout:(NSDictionary *)params
{
    if (![params isKindOfClass:[NSDictionary class]] || ![self.host isKindOfClass:[PicassoVCHost class]]) {
        return;
    }
    PCSRunOnMainThread(^{
        PicassoVCHost *vcHost = (PicassoVCHost *)self.host;
        NSInteger vcId = [params[@"vcId"] integerValue];
        PicassoView *pcsView = [vcHost picassoViewWithChildVCId:vcId];
        [vcHost layoutChildPicassoView:pcsView withId:vcId didPaintBlock:nil];
    });
}

@end
