//
//  PicassoListViewModel.m
//  Pods
//
//  Created by 纪鹏 on 2017/6/11.
//
//

#import "PicassoListViewModel.h"
#import "PicassoBaseModel+Private.h"
#import "PicassoListItemModel.h"
#import "PicassoPullRefreshModel.h"
#import "PicassoLoadingViewModel.h"
#import "UIColor+pcsUtils.h"
#import "PicassoViewWrapperFactory.h"

@implementation PicassoListViewModel

- (void)setModelWithDictionary:(NSDictionary *)dictionaryValue {
    [super setModelWithDictionary:dictionaryValue];
    self.initIndex = [dictionaryValue[@"initIndex"] integerValue];
    self.estimateItemHeight = [dictionaryValue[@"estimateItemHeight"] integerValue];
    self.sectionItemCounts = dictionaryValue[@"sectionItemCounts"];
    self.indexTitles = dictionaryValue[@"indexTitles"];
    self.itemActionConfigs = dictionaryValue[@"itemActionConfigs"];
    // Section Index Color
    if (self.indexTitles.count > 0){
        NSString *indexColorHex = dictionaryValue[@"indexColor"];
        self.indexColor = indexColorHex.length ? [UIColor pcsColorWithHexString:indexColorHex] : [UIColor blackColor];
    } else {
        self.indexColor = [UIColor blackColor];
    }
    
    NSArray *items = dictionaryValue[@"items"];
    NSMutableArray *itemModels = [NSMutableArray new];
    for (NSDictionary *itemDic in items) {
        PicassoListItemModel *model = [PicassoListItemModel modelWithDictionary:itemDic];
        if (model) {
            [itemModels addObject:model];
        }
    }
    self.items = [itemModels copy];
    
    NSDictionary *refreshDic = dictionaryValue[@"refreshView"];
    if (refreshDic && ![refreshDic isEqual:[NSNull null]]) {
        NSInteger type = [refreshDic[@"type"] integerValue];
        self.pullRefreshView = [[PicassoViewWrapperFactory viewModelByType:type] modelWithDictionary:refreshDic];
        NSString *refreshStatus = dictionaryValue[@"refreshStatus"];
        self.refreshing = [refreshStatus isEqualToString:@"loading"];
    }
    NSDictionary *loadingDic = dictionaryValue[@"loadingView"];
    if (loadingDic) {
        self.loadingView = [PicassoViewModel modelWithDictionary:loadingDic];
    }
}

- (NSArray <PicassoModel *> *)subModels {
    return self.loadingView ? @[self.loadingView] : nil;
}

@end
