//
//  PicassoScrollView.m
//  clogan
//
//  Created by 纪鹏 on 2017/10/20.
//

#import "PicassoScrollView.h"
#import "PicassoScrollViewModel.h"
#import "PicassoHostManager.h"
#import "PicassoVCHost.h"
#import "PicassoRefreshControl.h"
#import "PicassoRefreshProtocol.h"
#import "PicassoViewWrapperFactory.h"
#import "PicassoBaseViewWrapper.h"
#import "PicassoDefine.h"

static NSString *PullRefreshActionName = @"onPullDown";

@interface PicassoScrollView () <UIScrollViewDelegate, PicassoRefreshControlDelegate>
@property (nonatomic, strong) PicassoScrollViewModel *scrollModel;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, assign) BOOL onScroll;
@property (nonatomic, assign) CGSize lastContentSize;
@property (nonatomic, strong) PicassoRefreshControl *pullRefreshControl;
@property (nonatomic, assign) BOOL pullRefresh;
@property (nonatomic, strong) UIView *refreshView;

@end

@implementation PicassoScrollView

- (instancetype)initWithModel:(PicassoScrollViewModel *)model {
    if (self = [super init]) {
        self.delegate = self;
    }
    return self;
}

- (void)updateWithModel:(PicassoScrollViewModel *)model {
    PicassoScrollViewModel *oldModel = self.scrollModel;
    self.scrollModel = model;
    self.showsVerticalScrollIndicator = model.showScrollIndicator;
    self.showsHorizontalScrollIndicator = model.showScrollIndicator;
    self.scrollEnabled = model.scrollEnabled;
    self.bounces = model.bounces;
    if (model.pullRefreshView && model.pullRefreshView.type != oldModel.pullRefreshView.type) {
        [self removeRefresh];
        PicassoVCHost *host = (PicassoVCHost *)[PicassoHostManager hostForId:self.scrollModel.hostId];
        self.refreshView = [[PicassoViewWrapperFactory viewWrapperByType:model.pullRefreshView.type] createViewWithModel:model.pullRefreshView inPicassoView:host.pcsView];
        self.pullRefreshControl = [[PicassoRefreshControl alloc] initWithHeaderView:(id<PicassoRefreshProtocol>)self.refreshView];
        [self.pullRefreshControl attachToScrollView:self];
        self.pullRefreshControl.delegate = self;
        self.alwaysBounceVertical = YES;
    } else if (oldModel.pullRefreshView && !model.pullRefreshView) {
        [self removeRefresh];
        self.alwaysBounceVertical = NO;
    }
    [self handleRefreshStatus];
    
    if (model.contentOffsetValue) {
        self.contentOffset = [model.contentOffsetValue CGPointValue];
    }
    CGSize size = [self getContentSize];
    if (!CGSizeEqualToSize(size, self.lastContentSize)) {
        self.contentSize = size;
        self.lastContentSize = size;
    }
    [self handleActions:model.actions];
}

- (void)handleRefreshStatus {
    if (!self.pullRefreshControl) return;
    [self addSubview:self.refreshView];
    if (self.pullRefreshControl.isRefreshing && !self.scrollModel.refreshing) {
        [self stopRefresh];
    } else if (!self.pullRefreshControl.isRefreshing && self.scrollModel.refreshing) {
        [self.pullRefreshControl simulateDragRefresh];
    }
}

- (void)handleActions:(NSArray<NSString *> *)actions {
    if (self.tapGesture) {
        [self removeGestureRecognizer:self.tapGesture];
    }
    self.onScroll = NO;
    self.pullRefresh = NO;
    for (NSString *actionName in actions) {
        if ([actionName isEqualToString:@"click"]) {
            self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewClicked)];
            [self addGestureRecognizer:self.tapGesture];
        }
        if ([actionName isEqualToString:@"scroll"]) {
            self.onScroll = YES;
        }
        if ([actionName isEqualToString:PullRefreshActionName]) {
            self.pullRefresh = YES;
        }
    }
}

- (void)viewClicked {
    PicassoHost *host = [PicassoHostManager hostForId:self.scrollModel.hostId];
    if (![host isKindOfClass:[PicassoVCHost class]]) return;
    PicassoVCHost *vcHost = (PicassoVCHost *)host;
    [vcHost dispatchViewEventWithViewId:self.scrollModel.viewId action:@"click" params:nil];
}

- (CGSize)getContentSize {
    CGFloat maxBottom = self.scrollModel.height;
    CGFloat maxRight = self.scrollModel.width;
    for (PicassoModel *model in self.scrollModel.subviews) {
        CGFloat bottom = model.y + model.height;
        CGFloat right = model.x + model.width;
        maxBottom = MAX(bottom, maxBottom);
        maxRight = MAX(right, maxRight);
    }
    return CGSizeMake(maxRight, maxBottom);
}

- (void)removeRefresh {
    [self stopRefresh];
    [self.refreshView removeFromSuperview];
    self.refreshView = nil;
    self.pullRefreshControl = nil;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.pullRefreshControl) {
        [self.pullRefreshControl scrollViewDidScroll];
    }
    if (self.onScroll) {
        NSDictionary *param = @{@"x":@(scrollView.contentOffset.x),@"y":@(scrollView.contentOffset.y)};
        PicassoHost *host = [PicassoHostManager hostForId:self.scrollModel.hostId];
        if (![host isKindOfClass:[PicassoVCHost class]]) return;
        PicassoVCHost *vcHost = (PicassoVCHost *)host;
        [vcHost dispatchViewEventWithViewId:self.scrollModel.viewId action:@"scroll" params:param];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (self.pullRefreshControl) {
        [self.pullRefreshControl scrollViewDidEndDragging];
    }
}


#pragma mark - PicassoRefreshControlDelegate
- (BOOL)refreshData {
    if (self.pullRefresh) {
        PicassoVCHost *host = (PicassoVCHost *)[PicassoHostManager hostForId:self.scrollModel.hostId];
        [host dispatchViewEventWithViewId:self.scrollModel.viewId action:PullRefreshActionName params:nil];
        return YES;
    } else {
        return NO;
    }
}

- (void)stopRefresh {
    if (self.pullRefreshControl) {
        [self.pullRefreshControl headerRefreshFinished];
    }
}


@end
