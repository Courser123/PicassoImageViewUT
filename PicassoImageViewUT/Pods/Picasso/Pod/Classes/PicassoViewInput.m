//
//  PicassoViewInput.m
//  AFNetworking
//
//  Created by 纪鹏 on 2017/11/29.
//

#import "PicassoViewInput.h"
#import "PicassoVCHost.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "PicassoRenderUtils.h"
#import "PicassoModelHelper.h"
#import "RACSignal.h"
#import "RACSubscriber.h"
#import "PicassoThreadManager.h"
#import "NSString+JSON.h"
#import "PicassoView.h"
#import "PicassoMonitorEntity.h"
#import "PicassoModel.h"
#import "PicassoVCHost+Private.h"
#import "PicassoHost+Private.h"

@interface PicassoViewInput ()
@property (nonatomic, strong) PicassoVCHost *host;
@property (nonatomic, strong) PicassoMonitorEntity *monitorEntity;
@property (nonatomic, strong) PicassoModel *cachedModel;
@end

@implementation PicassoViewInput

- (instancetype)init {
    if (self = [super init]) {
        _monitorEntity = [[PicassoMonitorEntity alloc] init];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _width = [aDecoder decodeDoubleForKey:@"width"];
        _height = [aDecoder decodeDoubleForKey:@"height"];
        _jsonData = [aDecoder decodeObjectForKey:@"jsonData"];
        _extraData = [aDecoder decodeObjectForKey:@"extraData"];
        _jsName = [aDecoder decodeObjectForKey:@"jsName"];
        _jsContent = [aDecoder decodeObjectForKey:@"jsContent"];
        NSDictionary *modelDic = [aDecoder decodeObjectForKey:@"modelDic"];
        _cachedModel = [PicassoModelHelper modelWithDictionary:modelDic];
        [self resetHostIdForCacheModel:_cachedModel];
    }
    return self;
}

- (void)resetHostIdForCacheModel:(PicassoModel *)pmodel {
    pmodel.hostId = [NSString stringWithFormat:@"__Cached__%@", pmodel.hostId];
    for (PicassoModel *subModel in pmodel.subModels) {
        [self resetHostIdForCacheModel:subModel];
    }
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeDouble:self.width forKey:@"width"];
    [aCoder encodeDouble:self.height forKey:@"height"];
    [aCoder encodeObject:self.jsonData forKey:@"jsonData"];
    [aCoder encodeObject:self.extraData forKey:@"extraData"];
    [aCoder encodeObject:self.jsName forKey:@"jsName"];
    [aCoder encodeObject:self.jsContent forKey:@"jsContent"];
    PicassoModel *model = [self getPModel];
    if (model && model.dictionaryValue) {
        [aCoder encodeObject:model.dictionaryValue forKey:@"modelDic"];
    }
}

- (void)preCompute {
    [self.monitorEntity start:PicassoMonitorEntity.PRECOMPUTE];
    [self.host destroyHost];
    [self.monitorEntity start:PicassoMonitorEntity.CONTROLLER_CREATE];
    self.host = [[PicassoVCHost alloc] init];
    self.host.alias = self.jsName;
    [self.host createControllerWithScript:self.jsContent options:[self options] stringData:self.jsonData];
    [self.monitorEntity end:PicassoMonitorEntity.CONTROLLER_CREATE];
    self.host.pageController = self.pageController;
    self.host.msgBlock = self.onReceiveMsg;
    [self.host updateVCState:PicassoVCStateLoad];
    [self.host twiceLayout];
    self.monitorEntity.name = self.jsName;
    [self.monitorEntity end:PicassoMonitorEntity.PRECOMPUTE reportSuccess:[self isComputeSuccess]];
    self.cachedModel = nil;
}

- (NSDictionary *)options {
    NSMutableDictionary *optionDic = [@{@"width"   :@(self.width),
                                        @"height"  :@(self.height)
                                        } mutableCopy];
    if (self.extraData) {
        [optionDic setObject:self.extraData forKey:@"extraData"];
    }
    return [optionDic copy];
}

- (RACSignal *)computeSignal {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        PCSRunOnBridgeThread(^{
            [self preCompute];
            PCSRunOnMainThread(^{
                [subscriber sendNext:self];
                [subscriber sendCompleted];
            });
        });
        return nil;
    }];
}

+ (RACSignal *)computeWithInputArray:(NSArray<PicassoViewInput *> *)inputArray {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        PCSRunOnBridgeThread(^{
            for (PicassoViewInput * input in inputArray) {
                [input preCompute];
            }
            PCSRunOnMainThread(^{
                [subscriber sendNext:inputArray];
                [subscriber sendCompleted];
            });
        });
        return nil;
    }];
}

- (PicassoModel *)getPModel {
    if (self.host) {
        return self.host.model;
    } else {
        return self.cachedModel;
    }
}

- (void)setOnReceiveMsg:(PicassoMsgReceiveBlock)onReceiveMsg {
    _onReceiveMsg = onReceiveMsg;
    if (self.host) {
        self.host.msgBlock = self.onReceiveMsg;
    }
}

- (BOOL)isComputeSuccess {
    return self.host.model != nil;
}

- (void)bindPicassoView:(PicassoView *)picassoView {
    self.host.pcsView = picassoView;
}

- (void)callVCMethod:(NSString *)methodName params:(NSDictionary *)params {
    [self.host callControllerMethod:methodName argument:params];
}

- (void)dealloc {
    [_host destroyHost];
}

@end
