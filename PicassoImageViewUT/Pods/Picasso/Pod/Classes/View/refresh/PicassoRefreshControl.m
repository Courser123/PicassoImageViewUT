//
//  NVDragRefreshControl.m
//  Pods
//
//  Created by 纪鹏 on 15/8/11.
//
//

#import "PicassoRefreshControl.h"
#import "UIView+Layout.h"
#import "UIScreen+Adaptive.h"
#import "ReactiveCocoa.h"

typedef NS_ENUM(NSInteger, eScrollViewState) {
    eScrollViewStateInit = 1,
    eScrollViewStateIdle,
    eScrollViewStateWillRefresh,
    eScrollViewStatePrepareToRefresh,
    eScrollViewStatePreparedForRefreshing,
    eScrollViewStateRefreshing
};

@interface PicassoRefreshControl ()

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, strong) id<PicassoRefreshProtocol> refreshHeaderView;
@property (nonatomic, assign) UIEdgeInsets originContentInset;
@property (nonatomic, assign) eScrollViewState state;

@end

@implementation PicassoRefreshControl

- (instancetype)initWithHeaderView:(id<PicassoRefreshProtocol>)headerView {
    self = [super init];
    if (self) {
        _refreshHeaderView = headerView;
        _state = eScrollViewStateIdle;
    }
    return self;
}

- (CGFloat)defaultHeaderHeight {
    return 80.0;
}

- (CGFloat)criticalOffset {
    CGFloat defaultOffset = 60;
    if(self.refreshHeaderView && [self.refreshHeaderView respondsToSelector:@selector(loadingOffset)]) {
        defaultOffset = [self.refreshHeaderView loadingOffset];
    }
    return ceil(-defaultOffset - self.originContentInset.top);
}

- (void)scrollViewDidScroll {
    if (self.state == eScrollViewStateRefreshing) {
        return;
    }
    CGFloat offsetY = self.scrollView.contentOffset.y;
    [self.refreshHeaderView setViewWithYOffset:self.scrollView.contentOffset.y isDragging:self.scrollView.isDragging];
    if (self.scrollView.isDragging) {
        if (self.state == eScrollViewStatePreparedForRefreshing  || self.state == eScrollViewStatePrepareToRefresh) {
            if (offsetY > 0) {
                self.state = eScrollViewStateInit;
                self.state = eScrollViewStateIdle;
                [self.refreshHeaderView setState:PicassoPullRefrshStateNone];
            }
            return;
        }
        if ([self shouldPullJump]) {
            [self.refreshHeaderView setState:PicassoPullRefrshStateJump];
        } else {
            [self.refreshHeaderView setState:PicassoPullRefrshStateDragging];
        }
        if (self.state == eScrollViewStateIdle && offsetY <= [self criticalOffset]) {
            self.state = eScrollViewStateWillRefresh;
            NSLog(@"state: willRefresh");
        } else if (self.state == eScrollViewStateWillRefresh && offsetY > [self criticalOffset]) {
            self.state = eScrollViewStateIdle;
            NSLog(@"state: Idle");
        }
    } else {
        if (self.state == eScrollViewStatePreparedForRefreshing) {
            if (offsetY  >= [self criticalOffset]) {
                //scrollview回弹到临界offset时开始刷新,避免回弹过程中reloaddata造成的抖动
                [self beginRefresh];
                NSLog(@"begin refresh, %f",self.scrollView.contentOffset.y);
            }
        }
    }
}

- (BOOL)shouldPullJump {
    return self.enablePullJump && (-self.scrollView.contentOffset.y/self.scrollView.height) > self.pullJumpThreshold;
}

- (BOOL)isRefreshing {
    return self.state == eScrollViewStateRefreshing;
}

- (void)scrollViewDidEndDragging {
    if ([self shouldPullJump]) {
        self.state = eScrollViewStateIdle;
        [self.refreshHeaderView setState:PicassoPullRefrshStateNone];
        if (self.delegate && [self.delegate respondsToSelector:@selector(pullJumpAction)]) {
            [self.delegate pullJumpAction];
        }
        return;
    }
    if (self.state == eScrollViewStateWillRefresh) {
        self.state = eScrollViewStatePrepareToRefresh;
        self.state = eScrollViewStatePreparedForRefreshing;
    }
}

- (void)beginRefresh {
    self.state = eScrollViewStateRefreshing;
    if ([self.delegate respondsToSelector:@selector(refreshData)] && [self.delegate refreshData]) {
//        [self.refreshHeaderView setState:eNVPullRefrshStateLoading];
        NSLog(@"state: refreshing");
    } else {
        [self headerRefreshFinished];
    }
}

- (void)headerRefreshFinished {
    if (self.state == eScrollViewStateRefreshing) {
        if ([self.refreshHeaderView respondsToSelector:@selector(setSuccessFinishBlock:)]) {
            @weakify(self)
            [self.refreshHeaderView setSuccessFinishBlock:^{
                @strongify(self)
                [self resetRefreshView];
            }];
            [self.refreshHeaderView setState:PicassoPullRefrshStateSuccess];
        } else {
            [self.refreshHeaderView setState:PicassoPullRefrshStateSuccess];
            [self resetRefreshView];
        }
    }
}

- (void)resetRefreshView {
    [UIView animateWithDuration:0.3 animations:^{
        self.state = eScrollViewStateInit;
        self.state = eScrollViewStateIdle;
    } completion:^(BOOL finished) {
        if (self.state == eScrollViewStateIdle) {
            [self.refreshHeaderView setState:PicassoPullRefrshStateNone];
        }
    }];
}

- (void)simulateDragRefresh {
    [self.scrollView.layer removeAllAnimations];
    self.state = eScrollViewStateInit;
    self.state = eScrollViewStateIdle;
    self.state = eScrollViewStateWillRefresh;
    [self scrollViewDidEndDragging];
    [self scrollViewDidScroll];
}

- (void)setState:(eScrollViewState)state {
    _state = state;
    switch (state) {
        case eScrollViewStateInit:
        {
            self.scrollView.contentInset = self.originContentInset;
            break;
        }
        case eScrollViewStateWillRefresh:
        {
            if (self.scrollView.contentOffset.y > [self criticalOffset]) {
                self.scrollView.contentOffset = CGPointMake(0, [self criticalOffset]);
            }
            break;
        }
        case eScrollViewStatePrepareToRefresh:
        {
            CGPoint offset = self.scrollView.contentOffset;
            self.scrollView.contentInset = UIEdgeInsetsMake(0-[self criticalOffset], 0, 0, 0);
            self.scrollView.contentOffset = offset;
            [self.refreshHeaderView setState:PicassoPullRefrshStateLoading];
            break;
        }
        default:
            break;
    }
}

- (void)attachToScrollView:(UIScrollView *)scrollView {
    self.scrollView = scrollView;
    self.originContentInset = scrollView.contentInset;
}

- (UIView *)headerRefreshView {
    return (UIView *)_refreshHeaderView;
}

@end
