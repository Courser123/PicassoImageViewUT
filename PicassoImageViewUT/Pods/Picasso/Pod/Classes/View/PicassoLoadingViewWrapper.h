//
//  PicassoLoadingViewWrapper.h
//  CocoaAsyncSocket
//
//  Created by 纪鹏 on 2017/6/28.
//

#import "PicassoBaseViewWrapper.h"
#import "NVLoadMoreView.h"

@interface PicassoLoadingViewWrapper : PicassoBaseViewWrapper

@property (nonatomic, assign) NVLoadingStatus loadingStatus;
@property (nonatomic, copy) LoadMoreRetryBlock retryBlock;

@end
