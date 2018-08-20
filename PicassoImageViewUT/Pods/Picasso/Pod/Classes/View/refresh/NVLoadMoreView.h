//
//  NVLoadMoreView.h
//  CocoaAsyncSocket
//
//  Created by 纪鹏 on 2017/6/28.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, NVLoadingStatus) {
    NVLoadingStatusNormal,
    NVLoadingStatusLoading,
    NVLoadingStatusFail,
    NVLoadingStatusDone
};

typedef void(^LoadMoreRetryBlock)() ;

@interface NVLoadMoreView : UIView
@property (nonatomic, assign) NVLoadingStatus loadingStatus;
@property (nonatomic, copy) LoadMoreRetryBlock retryBlock;
@end
