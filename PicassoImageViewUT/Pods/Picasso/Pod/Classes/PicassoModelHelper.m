//
//  PicassoModelHelper.m
//  Pods
//
//  Created by 纪鹏 on 2017/6/11.
//
//

#import "PicassoModelHelper.h"
#import "PicassoViewModel.h"
#import "PicassoViewWrapperFactory.h"

@implementation PicassoModelHelper

+ (PicassoModel *)modelWithDictionary:(NSDictionary *)dic {
    if (!dic) {
        return nil;
    }
    NSNumber *viewType = [dic objectForKey:@"type"];
    if (!viewType) {
        return nil;
    }
    Class modelCls = [PicassoViewWrapperFactory viewModelByType:[viewType integerValue]];
    PicassoModel *model = [modelCls modelWithDictionary:dic];
    return model;
}

@end
