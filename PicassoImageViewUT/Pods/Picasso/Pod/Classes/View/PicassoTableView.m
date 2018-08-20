//
//  PicassoTableView.m
//  clogan
//
//  Created by 纪鹏 on 2017/10/20.
//

#import "PicassoTableView.h"
#import "PicassoListViewModel.h"
#import "PicassoListItemModel.h"
#import "PicassoListItemWrapper.h"
#import "PicassoVCHost.h"
#import "PicassoVCHost+Relayout.h"
#import "PicassoHostManager.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "PicassoViewWrapperFactory.h"
#import "PicassoRefreshControl.h"
#import "PicassoRefreshProtocol.h"
#import "PicassoDefine.h"
#import "PicassoRenderUtils.h"
#import "PicassoThreadManager.h"
#import "UIColor+pcsUtils.h"
#import "ReactiveCocoa.h"

static NSString *PullRefreshActionName = @"onPullDown";
static NSString *LoadMoreActionName = @"onLoadMore";
static NSString *ItemEditActionName = @"onItemAction";
static NSString *ScrollStartActionName = @"onScrollStart";
static NSString *ScrollEndActionName = @"onScrollEnd";

@interface PicassoItemActionConfig: NSObject
@property (nonatomic, copy) NSString *colorHex;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImage *image;
+ (PicassoItemActionConfig *)configWithDictionary:(NSDictionary *)dictionary;
@end

@implementation PicassoItemActionConfig
+ (PicassoItemActionConfig *)configWithDictionary:(NSDictionary *)dictionary {
    PicassoItemActionConfig *config = [PicassoItemActionConfig new];
    config.colorHex = dictionary[@"color"];
    config.title = dictionary[@"title"];
    NSString *imageStr = dictionary[@"image"];
    if (imageStr.length > 0) {
        config.image = [UIImage imageNamed:imageStr];
    }
    return config;
}

- (BOOL)isValid {
    return self.title.length > 0 || self.image != nil;
}
@end

@interface PicassoTableView () <UITableViewDelegate, UITableViewDataSource, PicassoRefreshControlDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) PicassoVCHost *host;
@property (nonatomic, strong) NSArray <NSArray <PicassoListItemModel *> *> *sectionItem2DList;
@property (nonatomic, strong) NSArray <PicassoListItemModel *> *sectionHeaderList;
@property (atomic, strong) PicassoListViewModel *listModel;
@property (nonatomic, strong) PicassoRefreshControl *pullRefreshControl;
@property (nonatomic, strong) UIView *loadingView;
@property (nonatomic, strong) UIView *refreshView;
@property (nonatomic, strong) NSArray *sectionIndexTitles;
@property (nonatomic, strong) NSDictionary *sectionIndexMapping;
@property (nonatomic, strong) NSArray <NSArray < NSArray <PicassoItemActionConfig *> *> *> *itemActionConfig3DList;
@property (nonatomic, assign) BOOL pullRefresh;
@property (nonatomic, assign) BOOL needCallLoadMore;
@property (nonatomic, assign) BOOL hasLoadMore;
@property (nonatomic, assign) BOOL monitorScrollStart;
@property (nonatomic, assign) BOOL monitorScrollEnd;

@end

@implementation PicassoTableView

const NSInteger SECTION_HEADER_INDEX = -1;

- (instancetype)initWithModel:(PicassoListViewModel *)model {
    if (self = [super init]) {
        self.delegate = self;
        self.dataSource = self;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.estimatedRowHeight = 0;
        self.estimatedSectionFooterHeight = 0;
        self.estimatedSectionHeaderHeight = 0;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.sectionIndexBackgroundColor = [UIColor clearColor];
        
        if (@available(iOS 11,*)) {
            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return self;
}

- (void)updateWithModel:(PicassoListViewModel *)model {
    PicassoListViewModel *oldModel = self.listModel;
    self.listModel = model;
    PicassoHost *pcsHost = [PicassoHostManager hostForId:model.hostId];
    if (![pcsHost isKindOfClass:[PicassoVCHost class]]) {
        self.host = nil;
        return ;
    }
    self.host = (PicassoVCHost *)pcsHost;
    
    self.sectionIndexColor = model.indexColor;
    [self generateSectionIndexs];
    [self generateItemActionConfigs];

    if (model.pullRefreshView && model.pullRefreshView.type != oldModel.pullRefreshView.type) {
        [self removeRefresh];
        self.refreshView = [[PicassoViewWrapperFactory viewWrapperByType:model.pullRefreshView.type] createViewWithModel:model.pullRefreshView inPicassoView:self.host.pcsView];
        self.pullRefreshControl = [[PicassoRefreshControl alloc] initWithHeaderView:(id<PicassoRefreshProtocol>)self.refreshView];
        [self.pullRefreshControl attachToScrollView:self];
        self.pullRefreshControl.delegate = self;
    } else if (oldModel.pullRefreshView && !model.pullRefreshView) {
        [self removeRefresh];
    }
    [self handleRefreshStatus];
    
    [self removeLoading];
    if (model.loadingView) {
        self.loadingView = [[PicassoViewWrapperFactory viewWrapperByType:model.loadingView.type] createViewWithModel:model.loadingView inPicassoView:self.host.pcsView];
    }
    self.hasLoadMore = (self.loadingView != nil);

    [self handleActions:self.listModel.actions];
    
    NSMutableArray<NSMutableArray <PicassoListItemModel *> *> *sectionItemsTempArr = [NSMutableArray new];
    NSMutableArray<PicassoListItemModel *> *sectionHeaderTempArray = [NSMutableArray new];
    
    NSInteger index = 0;
    for (NSInteger sectionIndex = 0; sectionIndex < model.sectionItemCounts.count; sectionIndex++) {
        // Section Header
        PicassoListItemModel *itemModel = [self getItemModelWithModelList:model.items index:index];
        if (itemModel) {
            [sectionHeaderTempArray addObject:itemModel];
            index++;
        } else {
            break;
        }

        // Table Cell
        NSMutableArray *sectionItemList = [NSMutableArray new];
        for (NSInteger j = 0; j < [model.sectionItemCounts[sectionIndex] integerValue]; j++) {
            PicassoListItemModel *itemModel = [self getItemModelWithModelList:model.items index:index];
            if (itemModel) {
                [sectionItemList addObject:itemModel];
                index++;
            } else {
                sectionIndex = model.sectionItemCounts.count;  // Exit for loop
                break;
            }
        }
        [sectionItemsTempArr addObject:sectionItemList];
    }
    if ([self.host needRelayout]) {
        PCSRunOnBridgeThread(^{
            [self.host flushSizeCache];
            [self getDataForItemList:sectionItemsTempArr headerList:sectionHeaderTempArray withSection:0 start:SECTION_HEADER_INDEX length:model.items.count];
            PCSRunOnMainThread(^{
                self.sectionItem2DList = [sectionItemsTempArr copy];
                self.sectionHeaderList = [sectionHeaderTempArray copy];
                [self reloadData];
            });
        });
    } else {
        self.sectionItem2DList = [sectionItemsTempArr copy];
        self.sectionHeaderList = [sectionHeaderTempArray copy];
        [self reloadData];
    }
}

- (void)removeLoading {
    [self.loadingView removeFromSuperview];
    self.loadingView = nil;
}

- (void)removeRefresh {
    [self stopPullDown];
    [self.refreshView removeFromSuperview];
    self.refreshView = nil;
    self.pullRefreshControl = nil;
}

- (void)handleRefreshStatus {
    if (!self.pullRefreshControl) return;
    [self addSubview:self.refreshView];
    if (self.pullRefreshControl.isRefreshing && !self.listModel.refreshing) {
        [self stopPullDown];
    } else if (!self.pullRefreshControl.isRefreshing && self.listModel.refreshing) {
        [self.pullRefreshControl simulateDragRefresh];
    }
}

- (void)handleActions:(NSArray<NSString *> *)actions {
    if (actions.count == 0) {
        return;
    }
    self.pullRefresh = NO;
    self.needCallLoadMore = NO;
    self.monitorScrollStart = NO;
    self.monitorScrollEnd = NO;
    for (NSString *actionName in actions) {
        if ([actionName isEqualToString:PullRefreshActionName]) {
            self.pullRefresh = YES;
        } else if ([actionName isEqualToString:LoadMoreActionName]) {
            self.needCallLoadMore = YES;
        } else if ([actionName isEqualToString:ScrollStartActionName]) {
            self.monitorScrollStart = YES;
        } else if ([actionName isEqualToString:ScrollEndActionName]) {
            self.monitorScrollEnd = YES;
        }
    }
}

/**
 * section: start from 0;
 * start: start from -1; -1 means section header
 */
- (void)getDataForItemList:(NSMutableArray<NSMutableArray <PicassoListItemModel *> *> *)itemList headerList:(NSMutableArray<PicassoListItemModel *> *)headerList withSection: (NSInteger)section start:(NSInteger)start length:(NSInteger)length {
    JSValue *value = [self.host syncDispatchViewEventWithViewId:self.listModel.viewId action:@"getItems" params:@{@"section":@(section), @"start":@(start), @"length":@(length)}];
    NSArray *itemDicArr = [value toArray];
    
    NSInteger index = 0;
    NSInteger beginSection = section;
    
    if (start != SECTION_HEADER_INDEX){
        for (NSInteger i = start; i < itemList[section].count; i++){
            PicassoListItemModel *model = [self getItemModelWithDicList:itemDicArr index:index];
            if (model) {
                itemList[section][i] = model;
            }
            index++;
        }
        beginSection++;
    }
    
    for (NSInteger i = beginSection; i < itemList.count; i++){
        PicassoListItemModel *model = [self getItemModelWithDicList:itemDicArr index:index];
        if (model) {
            headerList[i] = model;
        }
        index++;
        for (NSInteger j = 0; j < itemList[i].count; j++) {
            PicassoListItemModel *model = [self getItemModelWithDicList:itemDicArr index:index];
            if (model) {
                itemList[i][j] = model;
            }
            index++;
        }
    }
    if ([self.host needRelayout]) {
        [self.host flushSizeCache];
        [self getDataForItemList:itemList headerList:headerList withSection:section start:start length:length];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionItem2DList.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section < self.sectionItem2DList.count - 1) {
        return self.sectionItem2DList[section].count;
    }
    return self.sectionItem2DList[section].count + self.hasLoadMore; //loadingCell添加到最后一个section中
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PicassoVCHost *host = [self host];
    if ([self isLoadingCellWithIndexPath:indexPath]) {
        UITableViewCell *loadingCell = [tableView dequeueReusableCellWithIdentifier:@"loadingcell"];
        if (!loadingCell) {
            loadingCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"loadingcell"];
        }
        [loadingCell.contentView addSubview:self.loadingView];
        if (self.needCallLoadMore) {
            self.needCallLoadMore = NO;
            [host dispatchViewEventWithViewId:self.listModel.viewId action:LoadMoreActionName params:nil];
        }
        return loadingCell;
    }
    
    PicassoListItemModel *itemModel = self.sectionItem2DList[indexPath.section][indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:itemModel.reuseId];
    if (!cell) {
        cell = (UITableViewCell *)[PicassoListItemWrapper createViewWithModel:(PicassoModel *)itemModel inPicassoView:host.pcsView];
    }
    [PicassoListItemWrapper updateView:cell withModel:(PicassoModel *)itemModel inPicassoView:host.pcsView];
    return cell;
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.sectionIndexTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [self.sectionIndexMapping[@(index)] integerValue];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isLoadingCellWithIndexPath:indexPath]) {
        return self.loadingView.frame.size.height;
    }
    
    PicassoListItemModel *itemModel = self.sectionItem2DList[indexPath.section][indexPath.row];
    return itemModel.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    PicassoListItemModel *itemModel = self.sectionHeaderList[section];
    return itemModel.height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    PicassoListItemModel *itemModel = self.sectionHeaderList[section];
    UIView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:itemModel.reuseId];
    if (!view) {
        view = (UIView *)[PicassoGroupViewWrapper createViewWithModel:(PicassoModel *)itemModel inPicassoView:self.host.pcsView];
    }
    [PicassoGroupViewWrapper updateView:view withModel:(PicassoModel *)itemModel inPicassoView:self.host.pcsView];
    return view;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self actionConfigsForIndexPath:indexPath].count > 0;
}

- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray <PicassoItemActionConfig *>* actionConfigs = [self actionConfigsForIndexPath:indexPath];
    NSMutableArray <UITableViewRowAction *> *actionArr = [NSMutableArray new];
    for (PicassoItemActionConfig *config in actionConfigs) {
        NSInteger actionIndex = [actionConfigs indexOfObject:config];
        @weakify(self)
        UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:config.title handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            @strongify(self)
            [self itemEditActionForIndexPath:indexPath actionIndex:actionIndex];
        }];
        if (config.colorHex.length > 0) {
            action.backgroundColor = [UIColor pcsColorWithHexString:config.colorHex];
        }
        [actionArr addObject:action];
    }
    return [actionArr copy];
}

- (nullable UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(11_0) {
    NSArray <PicassoItemActionConfig *>* actionConfigs = [self actionConfigsForIndexPath:indexPath];
    NSMutableArray<UIContextualAction *> *actionArr = [NSMutableArray new];
    for (PicassoItemActionConfig *config in actionConfigs) {
        NSInteger actionIndex = [actionConfigs indexOfObject:config];
        @weakify(self)
        UIContextualAction *action = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:config.title handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
            @strongify(self)
            [self itemEditActionForIndexPath:indexPath actionIndex:actionIndex];
        }];
        if (config.colorHex.length > 0) {
            action.backgroundColor = [UIColor pcsColorWithHexString:config.colorHex];
        }
        action.image = config.image;
        [actionArr addObject:action];
    }
    UISwipeActionsConfiguration *configuration = [UISwipeActionsConfiguration configurationWithActions:actionArr];
    configuration.performsFirstActionWithFullSwipe = NO;
    return configuration;

}

#pragma mark - PicassoRefreshControlDelegate
- (BOOL)refreshData {
    if (self.pullRefresh) {
        [self.host dispatchViewEventWithViewId:self.listModel.viewId action:PullRefreshActionName params:nil];
        return YES;
    } else {
        return NO;
    }
}

- (void)stopPullDown {
    if (self.pullRefreshControl) {
        [self.pullRefreshControl headerRefreshFinished];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.pullRefreshControl) {
        [self.pullRefreshControl scrollViewDidScroll];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.pullRefreshControl) {
        [self.pullRefreshControl scrollViewDidEndDragging];
    }

    if (NO == decelerate && YES == self.monitorScrollEnd) {
        [self.host dispatchViewEventWithViewId:self.listModel.viewId action:ScrollEndActionName params:nil];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (YES == self.monitorScrollStart) {
        [self.host dispatchViewEventWithViewId:self.listModel.viewId action:ScrollStartActionName params:nil];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (YES == self.monitorScrollEnd) {
        [self.host dispatchViewEventWithViewId:self.listModel.viewId action:ScrollEndActionName params:nil];
    }
}

#pragma mark - helper functions
- (BOOL)isLoadingCellWithIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.section == self.sectionItem2DList.count - 1) && (indexPath.row == self.sectionItem2DList[indexPath.section].count) && self.hasLoadMore;
}

- (PicassoListItemModel *)getItemModelWithModelList: (NSArray<PicassoListItemModel *> *)itemModels index: (NSInteger)index {
    if (index >= itemModels.count) {
        return nil;
    }
    PicassoListItemModel *itemModel = itemModels[index];
    [self.host checkRelayoutForModel:itemModel];
    return itemModel;
}

- (PicassoListItemModel *)getItemModelWithDicList: (NSArray<NSDictionary *> *)itemDics index: (NSInteger)index {
    if (index >= itemDics.count) {
        return nil;
    }
    NSDictionary *itemDic = itemDics[index];
    PicassoListItemModel *itemModel = [PicassoListItemModel modelWithDictionary:itemDic];
    [self.host checkRelayoutForModel:itemModel];
    return itemModel;
}

- (void)generateSectionIndexs {
    NSMutableDictionary *mapping = [NSMutableDictionary new];
    NSMutableArray *sectionTitles = [NSMutableArray new];
    NSInteger titleIndex = 0;
    for (NSInteger sectionIndex = 0; sectionIndex < self.listModel.indexTitles.count; sectionIndex++) {
        NSString *title = self.listModel.indexTitles[sectionIndex];
        if (title.length > 0) {
            [sectionTitles addObject:title];
            [mapping setObject:@(sectionIndex) forKey:@(titleIndex)];
            titleIndex++;
        }
    }
    self.sectionIndexTitles = [sectionTitles copy];
    self.sectionIndexMapping = [mapping copy];
}

- (void)generateItemActionConfigs {
    if(!self.listModel.itemActionConfigs) {
        self.itemActionConfig3DList = nil;
        return;
    }
    NSMutableArray *sectionConfigList = [NSMutableArray new];
    for (NSInteger sectionIndex = 0;sectionIndex < self.listModel.itemActionConfigs.count ; sectionIndex++) {
        NSMutableArray *itemConfigList = [NSMutableArray new];
        NSArray <NSArray<NSDictionary *> *> *itemConfigDicList = self.listModel.itemActionConfigs[sectionIndex];
        for (NSInteger itemIndex = 0; itemIndex < itemConfigDicList.count; itemIndex++) {
            NSArray<NSDictionary *> *configDicList = itemConfigDicList[itemIndex];
            NSMutableArray *configList = [NSMutableArray new];
            for (NSInteger configIndex = 0; configIndex < configDicList.count; configIndex++) {
                PicassoItemActionConfig *config = [PicassoItemActionConfig configWithDictionary:configDicList[configIndex]];
                if ([config isValid]) {
                    [configList addObject:config];
                }
            }
            [itemConfigList addObject:configList];
        }
        [sectionConfigList addObject:itemConfigList];
    }
    self.itemActionConfig3DList = [sectionConfigList copy];
}

- (void)itemEditActionForIndexPath:(NSIndexPath *)indexPath actionIndex:(NSInteger)actionIndex {
    [self.host dispatchViewEventWithViewId:self.listModel.viewId action:ItemEditActionName params:@{@"itemIndex":@(indexPath.row),
                                                                                                    @"sectionIndex":@(indexPath.section),
                                                                                                    @"actionIndex":@(actionIndex)
                                                                                                    }];
}

- (NSArray <PicassoItemActionConfig *> *)actionConfigsForIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= self.itemActionConfig3DList.count) return nil;
    if (indexPath.row >= self.itemActionConfig3DList[indexPath.section].count) return nil;
    return self.itemActionConfig3DList[indexPath.section][indexPath.row];
}

@end
