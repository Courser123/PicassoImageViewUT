//
//  PicassoViewModel.m
//  Picasso
//
//  Created by 纪鹏 on 2018/5/8.
//

#import "PicassoViewModel.h"
#import "PicassoViewWrapperFactory.h"
#import "PicassoBaseModel+Private.h"

@implementation PicassoViewModel

- (NSArray <PicassoModel *> *)subModels {
    return self.subviews;
}

- (void)setModelWithDictionary:(NSDictionary *)dictionaryValue {
    [super setModelWithDictionary:dictionaryValue];
    NSNumber *clipToBoundsNum = dictionaryValue[@"clipToBounds"];
    self.clipToBounds = clipToBoundsNum ? [clipToBoundsNum boolValue] : YES;
    NSArray *subviews = [dictionaryValue objectForKey:@"subviews"];
    NSMutableArray *subviewModels = [NSMutableArray array];
    for (NSDictionary *subview in subviews) {
        NSNumber *viewType = [subview objectForKey:@"type"];
        Class modelCls = [PicassoViewWrapperFactory viewModelByType:[viewType integerValue]];
        PicassoModel *model = [modelCls modelWithDictionary:subview];
        if (model) {
            [subviewModels addObject:model];
        }
    }
    self.subviews = subviewModels;
}
@end
