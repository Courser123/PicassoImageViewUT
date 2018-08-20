//
//  PicassoLoadingViewWrapper.m
//  CocoaAsyncSocket
//
//  Created by 纪鹏 on 2017/6/28.
//

#import "PicassoLoadingViewWrapper.h"
#import "PicassoDefine.h"
#import "PicassoLoadingViewModel.h"


@implementation PicassoLoadingViewWrapper

PCS_EXPORT_METHOD(@selector(setLoadingStatus:))

- (UIView *)createViewWithModel:(PicassoModel *)model {
    CGRect rect = CGRectMake(model.x, model.y, model.width, model.height);
    return [[NVLoadMoreView alloc] initWithFrame:rect];
}

//- (void)updateViewWithModel:(PicassoModel *)model {
//    [super updateViewWithModel:model];
//}
//
//- (void)setRetryBlock:(LoadMoreRetryBlock)retryBlock {
//    NVLoadMoreView *view = (NVLoadMoreView *)self.view;
//    view.retryBlock = retryBlock;
//}
//
//- (void)setLoadingStatus:(NVLoadingStatus)loadingStatus {
//    _loadingStatus = loadingStatus;
//    NVLoadMoreView *view = (NVLoadMoreView *)self.view;
//    view.loadingStatus = loadingStatus;
//}

@end
