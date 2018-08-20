//
//  PicassoListViewModel.h
//  Pods
//
//  Created by 纪鹏 on 2017/6/11.
//
//

#import "PicassoScrollViewModel.h"

@class PicassoListItemModel;

@interface PicassoListViewModel : PicassoModel

@property (nonatomic, assign) NSInteger initIndex;
@property (nonatomic, assign) NSInteger estimateItemHeight;
@property (nonatomic, strong) UIColor *indexColor;
@property (nonatomic, strong) NSArray <NSNumber *> *sectionItemCounts;
@property (nonatomic, strong) NSArray <NSString *> *indexTitles;
@property (nonatomic, strong) NSArray <PicassoListItemModel *> *items;
@property (nonatomic, strong) PicassoModel *pullRefreshView;
@property (nonatomic, strong) PicassoViewModel *loadingView;
@property (nonatomic, assign) BOOL refreshing;
@property (nonatomic, strong) NSArray <NSArray <NSArray <NSDictionary *> *> *> *itemActionConfigs;

@end
