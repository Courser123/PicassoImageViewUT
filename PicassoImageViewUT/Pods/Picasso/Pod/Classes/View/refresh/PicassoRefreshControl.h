//
//  NVDragRefreshControl.h
//  Pods
//
//  Created by 纪鹏 on 15/8/11.
//
//

#import "PicassoRefreshProtocol.h"

@protocol PicassoRefreshControlDelegate <NSObject>

- (BOOL)refreshData;

@optional
- (void)pullJumpAction;

@end

@interface PicassoRefreshControl : UIView

@property (nonatomic, assign) BOOL enablePullJump;
@property (nonatomic, assign) CGFloat pullJumpThreshold;

@property (nonatomic, weak) id<PicassoRefreshControlDelegate> delegate;

- (instancetype)initWithHeaderView:(id<PicassoRefreshProtocol>)headerView;

- (void)attachToScrollView:(UIScrollView *)scrollView;

- (UIView *)headerRefreshView;

- (void)scrollViewDidScroll;

- (void)scrollViewDidEndDragging;

- (void)headerRefreshFinished;

- (void)simulateDragRefresh;

- (BOOL)isRefreshing;

@end
