//
//  PicassoScrollViewModel.m
//  Pods
//
//  Created by 纪鹏 on 2017/6/19.
//
//

#import "PicassoScrollViewModel.h"
#import "PicassoBaseModel+Private.h"
#import "PicassoViewWrapperFactory.h"

@implementation PicassoScrollViewModel

- (void)setModelWithDictionary:(NSDictionary *)dictionaryValue {
    [super setModelWithDictionary:dictionaryValue];
    self.showScrollIndicator = [[dictionaryValue objectForKey:@"showScrollIndicator"] boolValue];
    self.scrollDirection = [[dictionaryValue objectForKey:@"scrollDirection"] integerValue];
    self.scrollEnabled = [[dictionaryValue objectForKey:@"scrollEnabled"] boolValue];
    self.bounces = [[dictionaryValue objectForKey:@"bounces"] boolValue];
    NSNumber *offSetXNum = [dictionaryValue objectForKey:@"contentOffsetX"];
    NSNumber *offSetYNum = [dictionaryValue objectForKey:@"contentOffsetY"];
    if (offSetXNum && offSetYNum) {
        self.contentOffsetValue = [NSValue valueWithCGPoint:(CGPoint){[offSetXNum doubleValue], [offSetYNum doubleValue]}];
    }
    NSDictionary *refreshDic = dictionaryValue[@"refreshView"];
    if (refreshDic && ![refreshDic isEqual:[NSNull null]]) {
        NSInteger type = [refreshDic[@"type"] integerValue];
        self.pullRefreshView = [[PicassoViewWrapperFactory viewModelByType:type] modelWithDictionary:refreshDic];
        NSString *refreshStatus = dictionaryValue[@"refreshStatus"];
        self.refreshing = [refreshStatus isEqualToString:@"loading"];
    }
}

@end
