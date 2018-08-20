//
//  PicassoNavigatorModule.m
//  Pods
//
//  Created by 纪鹏 on 2017/5/11.
//
//

#import "PicassoNavigatorModule.h"
#import "PicassoDefine.h"
#import "PicassoBaseViewController.h"
#import "PicassoNavigatorProtocol.h"
#import "PicassoThreadManager.h"
#import "PicassoImplementsFactory.h"
#import "UIViewController+Picasso.h"
#import "UIColor+pcsUtils.h"

@interface PicassoNavigatorModule ()
@property (nonatomic, strong) id<PicassoNavigatorProtocol> navigator;
@end

@implementation PicassoNavigatorModule

PCS_EXPORT_METHOD(@selector(pop:callback:))
PCS_EXPORT_METHOD(@selector(openScheme:callback:))
PCS_EXPORT_METHOD(@selector(setTitle:callback:))
PCS_EXPORT_METHOD(@selector(setLeftItems:callback:))
PCS_EXPORT_METHOD(@selector(setRightItems:callback:))
PCS_EXPORT_METHOD(@selector(setBarHidden:))
PCS_EXPORT_METHOD(@selector(setBarBackgroundColor:))

- (id<PicassoNavigatorProtocol>)navigator
{
    if (!_navigator) {
        Class implClass = [PicassoImplementsFactory implementForProtocol:@protocol(PicassoNavigatorProtocol)];
        _navigator = [implClass new];
    }
    return _navigator;
}

- (void)openScheme:(NSDictionary *)params callback:(PicassoCallBack *)callback {
    PicassoNavigatorOpenModel *model = [PicassoNavigatorOpenModel modelWithDictionary:params];
    model.callback = callback;
    if ([self.navigator respondsToSelector:@selector(openScheme:withViewController:)]) {
        __weak typeof(self) weakSelf = self;
        PCSRunOnMainThread(^{
            [weakSelf.navigator openScheme:model withViewController:weakSelf.host.pageController];
        });
    }
}

- (void)pop:(NSDictionary *)params callback:(PicassoCallBack *)callback {
    PicassoNavigatorPopModel *model = [PicassoNavigatorPopModel modelWithDictionary:params];
    if ([self.navigator respondsToSelector:@selector(popViewControllerWithModel:withViewController:)]) {
        __weak typeof(self) weakSelf = self;
        PCSRunOnMainThread(^{
            [weakSelf.navigator popViewControllerWithModel:model withViewController:weakSelf.host.pageController];
        });
    }
}

- (void)setBarHidden:(NSDictionary *)params {
    BOOL hidden = [params[@"hidden"] boolValue];
    if ([self.navigator respondsToSelector:@selector(setNavigationBarHidden:animated:withController:)]) {
        __weak typeof(self) weakSelf = self;
        PCSRunOnMainThread(^{
            weakSelf.host.pageController.pcs_navibarHidden = hidden;
            [weakSelf.navigator setNavigationBarHidden:hidden animated:YES withController:weakSelf.host.pageController];
        });
    }
}

- (void)setBarBackgroundColor:(NSDictionary *)params {
    NSString *colorStr = params[@"color"];
    if ([self.navigator respondsToSelector:@selector(setNavigationBarBackgroundColor:withController:)]) {
        __weak typeof(self) weakSelf = self;
        PCSRunOnMainThread(^{
            UIColor *color = [UIColor pcsColorWithHexString:colorStr];
            [weakSelf.navigator setNavigationBarBackgroundColor:color withController:weakSelf.host.pageController];
        });
    }
}

- (void)setTitle:(NSDictionary *)params callback:(PicassoCallBack *)callback {
    PicassoNavigatorItemModel *model = [PicassoNavigatorItemModel modelWithDictionary:params];
    model.callback = callback;
    if ([self.navigator respondsToSelector:@selector(setNavigationBarTitleWithModel:withViewController:)]) {
        __weak typeof(self) weakSelf = self;
        PCSRunOnMainThread(^{
            [weakSelf.navigator setNavigationBarTitleWithModel:model withViewController:weakSelf.host.pageController];
        });
    }
}

- (void)setLeftItems:(NSDictionary *)params callback:(PicassoCallBack *)callback {
    NSArray <NSDictionary *> *items = params[@"items"];
    NSMutableArray<PicassoNavigatorItemModel *> *modelArr = [NSMutableArray new];
    for (NSDictionary *itemDic in items) {
        PicassoNavigatorItemModel *model = [PicassoNavigatorItemModel modelWithDictionary:itemDic];
        model.callback = callback;
        [modelArr addObject:model];
    }
    if ([self.navigator respondsToSelector:@selector(setLeftNavigationItemsWithModelArray:withViewController:)]) {
        __weak typeof(self) weakSelf = self;
        PCSRunOnMainThread(^{
            [weakSelf.navigator setLeftNavigationItemsWithModelArray:modelArr withViewController:weakSelf.host.pageController];
        });
    }
}

- (void)setRightItems:(NSDictionary *)params callback:(PicassoCallBack *)callback {
    NSArray <NSDictionary *> *items = params[@"items"];
    NSMutableArray<PicassoNavigatorItemModel *> *modelArr = [NSMutableArray new];
    for (NSDictionary *itemDic in items) {
        PicassoNavigatorItemModel *model = [PicassoNavigatorItemModel modelWithDictionary:itemDic];
        model.callback = callback;
        [modelArr addObject:model];
    }
    if ([self.navigator respondsToSelector:@selector(setRightNavigationItemsWithModelArray:withViewController:)]) {
        __weak typeof(self) weakSelf = self;
        PCSRunOnMainThread(^{
            [weakSelf.navigator setRightNavigationItemsWithModelArray:modelArr withViewController:weakSelf.host.pageController];
        });
    }
}

@end
