//
//  PicassoVCHost.m
//  CocoaAsyncSocket
//
//  Created by 纪鹏 on 2017/7/14.
//

#import "PicassoVCHost.h"
#import "PicassoBridgeContext.h"
#import "PicassoDebugMode.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "PicassoModelHelper.h"
#import "PicassoView.h"
#import "PicassoThreadManager.h"
#import "PicassoRenderUtils.h"
#import "PicassoHostManager.h"
#import "PicassoModel.h"
#import "PicassoViewWrapperFactory.h"
#import "PicassoRenderUtils.h"
#import "PicassoThreadSafeMutableDictionary.h"
#import "PicassoMonitorEntity.h"
#import "EXTScope.h"
#import "PicassoDefine.h"
#import "PicassoVCHost+Private.h"
#import "PicassoHost+Private.h"
#import "PicassoVCHost+LayoutFinished.h"
#import "PicassoSizeToFitProtocol.h"

@interface PicassoView (Private)
@property (nonatomic, weak) PicassoVCHost *host;
@end

@interface PicassoVCHost ()
@property (nonatomic, strong) NSMapTable *viewMap;
@property (nonatomic, strong) NSMutableDictionary *keyModelMap;
@property (nonatomic, strong) PicassoThreadSafeMutableDictionary *sizeCache;
@property (nonatomic, assign) BOOL loadTimeMarked;
@property (nonatomic, strong) PicassoThreadSafeMutableDictionary *childPicassoViewMap;
@property (nonatomic, strong) PicassoThreadSafeMutableDictionary *childVCDismissMap;
@end

@implementation PicassoVCHost

- (instancetype)init {
    if (self = [super init]) {
        _viewMap = [NSMapTable strongToWeakObjectsMapTable];
        _keyModelMap = [NSMutableDictionary new];
        _sizeCache = [PicassoThreadSafeMutableDictionary new];
        _childPicassoViewMap = [PicassoThreadSafeMutableDictionary new];
        _childVCDismissMap = [PicassoThreadSafeMutableDictionary new];
        _loadTimeMarked = NO;
        [self.monitorEntity start:PicassoMonitorEntity.VC_LOAD];
    }
    return self;
}

- (void)destroyHost
{
    NSArray *keys = [self.childVCDismissMap.allKeys copy];
    for (NSNumber *vcId in keys) {
        [self dismissChildVC:vcId.integerValue];
    }
    [super destroyHost];
}

- (void)updateVCState:(PicassoVCState)state {
    NSString *methodName = @"";
    switch (state) {
        case PicassoVCStateLoad:
            methodName = @"onLoad";
            break;
        case PicassoVCStateAppear:
            methodName = @"onAppear";
            break;
        case PicassoVCStateDisappear:
            methodName = @"onDisappear";
            break;
        case PicassoVCStateDistroy:
            methodName = @"onDestroy";
            break;
        default:
            break;
    }
    [self callControllerMethod:methodName argument:nil];
}

- (void)notifyViewFrameChanged:(NSDictionary *)options {
    [self callControllerMethod:@"onFrameChanged" argument:options];
}

- (void)keybordWillChangeToHeight:(CGFloat)height
{
    [self callControllerMethod:@"onKeyboardStatusChanged" argument:@{@"height" : @(height)}];
}

- (void)setPcsView:(PicassoView *)pcsView {
    if (pcsView != _pcsView) {
        _pcsView.host = nil;
    }
    _pcsView = pcsView;
    if (pcsView.host != self) {
        pcsView.host.pcsView = nil;
    }
    _pcsView.host = self;
}

#pragma mark - {viewId =>view} map
- (void)storeView:(UIView *)view withId:(NSString *)viewId {
    if (!view || viewId.length == 0) {
        return;
    }
    [self.viewMap setObject:view forKey:viewId];
}

- (UIView *)viewForId:(NSString *)viewId {
    if (viewId.length == 0) {
        return nil;
    }
    return [self.viewMap objectForKey:viewId];
}

- (void)removeViewForId:(NSString *)viewId {
    if (viewId.length == 0) {
        return;
    }
    [self.viewMap removeObjectForKey:viewId];
}

#pragma mark - sizeCache
- (void)addSizeCacheForKey:(NSString *)sizeKey size:(NSDictionary *)sizeDic {
    if (!sizeDic || sizeKey.length == 0) {
        NSLog(@"addSizeCacheForKey fail");
        return;
    }
    [self.sizeCache setObject:sizeDic forKey:sizeKey];
}

- (void)flushSizeCache {
    NSDictionary *sizeCacheDic = [self.sizeCache copy];
    [self syncCallControllerMethod:@"updateSizeCache" argument:sizeCacheDic];
    [self.sizeCache removeAllObjects];
}

- (BOOL)needRelayout {
    return self.sizeCache.allKeys.count > 0;
}

- (void)checkRelayoutForModel:(PicassoModel *)model {
    if ([model conformsToProtocol:@protocol(PicassoSizeToFitProtocol)]) {
        id<PicassoSizeToFitProtocol> sizeModel = (id<PicassoSizeToFitProtocol>)model;
        if (sizeModel.needSizeToFit) {
            CGSize size = [sizeModel calculateSize];
            [self addSizeCacheForKey:sizeModel.sizeKey size:@{@"width":@(size.width), @"height":@(size.height)}];
        }
    } else {
        for (PicassoModel *submodel in [model subModels]) {
            [self checkRelayoutForModel:submodel];
        }
    }
}

#pragma mark - keyModelCache
- (void)setModel:(PicassoModel *)model forKey:(NSNumber *)key {
    if (model && key) {
        [self.keyModelMap setObject:model forKey:key];
    }
}

- (PicassoModel *)modelForKey:(NSNumber *)key {
    if (!key) {
        return nil;
    }
    return [self.keyModelMap objectForKey:key];
}

- (void)twiceLayout {
    self.model = [self getModelWithLayoutMethod:@"dispatchLayoutByNative" params:nil];
}

- (PicassoModel *)getModelWithLayoutMethod:(NSString *)method params:(NSDictionary *)params
{
    PCSAssertBridgeThread();
    JSValue *value = [self syncCallControllerMethod:method argument:params];
    NSString *anchorModel = [self.monitorEntity wrapUniqued:PicassoMonitorEntity.VC_PMODEL];
    [self.monitorEntity start:anchorModel];
    PicassoModel *model = [PicassoModelHelper modelWithDictionary:[value toDictionary]];
    [self.monitorEntity end:anchorModel];
    [self checkRelayoutForModel:model];
    if ([self needRelayout]) {
        [self flushSizeCache];
        return [self getModelWithLayoutMethod:method params:params];
    } else {
        return model;
    }
}

- (void)layout {
    NSString *anchorName = [self.monitorEntity wrapUniqued:PicassoMonitorEntity.VC_LAYOUT];
    [self.monitorEntity prepare:anchorName];
    @weakify(self);
    PCSRunOnBridgeThread(^{
        @strongify(self);
        [self.monitorEntity start:[anchorName copy]];
        [self twiceLayout];
        PCSRunOnMainThread(^{
            @strongify(self);
            [self.pcsView modelPainting:self.model];
            [self notifyLayoutFinished];
            if (self.layoutFinishBlock) {
                self.layoutFinishBlock();
            }
            [self.monitorEntity end:[anchorName copy]];
            if (!self.loadTimeMarked) {
                self.monitorEntity.name = self.alias;
                [self.monitorEntity end:PicassoMonitorEntity.VC_LOAD reportSuccess:YES];
                self.loadTimeMarked = YES;
            }
        });
    });
}

- (PicassoView *)picassoViewWithChildVCId:(NSInteger)vcId {
    return [self.childPicassoViewMap objectForKey:@(vcId)];
}

- (void)layoutChildPicassoView:(PicassoView *)view withId:(NSInteger)vcId didPaintBlock:(dispatch_block_t)block {
    if (![view isKindOfClass:[PicassoView class]]) return;
    
    [self.childPicassoViewMap setObject:view forKey:@(vcId)];
    
    NSString *anchorName = [self.monitorEntity wrapUniqued:[PicassoMonitorEntity.VC_LAYOUT_CHILD stringByAppendingFormat:@"%@", @(vcId)]];
    [self.monitorEntity prepare:anchorName];
    @weakify(self);
    PCSRunOnBridgeThread(^{
        @strongify(self);
        [self.monitorEntity start:anchorName];
        PicassoModel *picassoModel = [self getModelWithLayoutMethod:@"dispatchChildLayoutByNative" params:@{@"vcId" : @(vcId)}];
        PCSRunOnMainThread(^{
            @strongify(self);
            [view modelPainting:picassoModel];
            [self callChildVCWithId:vcId method:@"onLayoutFinished" params:nil];
            [self.monitorEntity end:[anchorName copy]];
            if (block) {
                block();
            }
        });
    });
}

- (void)callChildVCWithId:(NSInteger)vcId method:(NSString *)method params:(NSDictionary *)params
{
    [self callControllerMethod:@"callChildVCByNative" argument:@{
                                                                 @"__vcid__"    :@(vcId),
                                                                 @"__method__"  :(method?:@""),
                                                                 @"params"      :([params isKindOfClass:[NSDictionary class]] ? params : @{})
                                                                 }];
}

- (void)addDismissBlock:(PicassoChildVCDismissBlock)block withChildVC:(NSInteger)vcId
{
    if (block) {
        [self.childVCDismissMap setObject:block forKey:@(vcId)];
    }
}

- (void)dismissChildVC:(NSInteger)vcId
{
    PicassoChildVCDismissBlock block = [self.childVCDismissMap objectForKey:@(vcId)];
    PicassoView *view = [self.childPicassoViewMap objectForKey:@(vcId)];
    if (block) {
        block(view);
    }
    [self.childVCDismissMap removeObjectForKey:@(vcId)];
    [self.childPicassoViewMap removeObjectForKey:@(vcId)];
}

- (void)notifyLayoutFinished {
    [self callControllerMethod:@"onLayoutFinished" argument:nil];
}

- (void)dispatchViewEventWithViewId:(NSString *)viewId action:(NSString *)action params:(NSDictionary *)params {
    [self callControllerMethod:@"dispatchActionByNative" argument:@{@"id"       :(viewId?:@""),
                                                                    @"action"   :(action?:@""),
                                                                    @"param"   :([params isKindOfClass:[NSDictionary class]] ? params : @{})
                                                                    }];
}

- (JSValue *)syncDispatchViewEventWithViewId:(NSString *)viewId action:(NSString *)action params:(NSDictionary *)params {
    return [self syncCallControllerMethod:@"dispatchActionByNative" argument:@{@"id"       :(viewId?:@""),
                                                                               @"action"   :(action?:@""),
                                                                               @"param"   :([params isKindOfClass:[NSDictionary class]] ? params : @{})
                                                                               }];
}

@end
