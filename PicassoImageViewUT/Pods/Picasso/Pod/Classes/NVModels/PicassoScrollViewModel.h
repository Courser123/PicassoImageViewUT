//
//  PicassoScrollViewModel.h
//  Pods
//
//  Created by 纪鹏 on 2017/6/19.
//
//

#import "PicassoViewModel.h"

@interface PicassoScrollViewModel : PicassoViewModel
@property (nonatomic, assign) BOOL showScrollIndicator;
@property (nonatomic, assign) NSInteger scrollDirection;
@property (nonatomic, assign) BOOL scrollEnabled;
@property (nonatomic, assign) BOOL bounces;
@property (nonatomic, strong) NSValue *contentOffsetValue;
@property (nonatomic, strong) PicassoModel *pullRefreshView;
@property (nonatomic, assign) BOOL refreshing;
@end
