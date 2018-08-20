//
//  PicassoNavigatorItemInfo.m
//  CocoaAsyncSocket
//
//  Created by 纪鹏 on 2017/7/2.
//

#import "PicassoNavigatorModel.h"

@implementation PicassoNavigatorOpenModel

+ (PicassoNavigatorOpenModel *)modelWithDictionary:(NSDictionary *)params {
    PicassoNavigatorOpenModel *model = [PicassoNavigatorOpenModel new];
    model.scheme = params[@"scheme"];
    model.animated = params[@"animated"] ? [params[@"animated"] boolValue] : YES;
    model.info = params[@"info"];
    return model;
}

@end

@implementation PicassoNavigatorItemModel

+ (PicassoNavigatorItemModel *)modelWithDictionary:(NSDictionary *)params {
    PicassoNavigatorItemModel *model = [PicassoNavigatorItemModel new];
    model.title = params[@"title"];
    model.titleColor = params[@"titleColor"];
    model.iconName = params[@"iconName"];
    model.iconUrl = params[@"iconUrl"];
    model.iconBase64 = params[@"iconBase64"];
    model.iconWidth = [params[@"iconWidth"] doubleValue];
    model.iconHeight = [params[@"iconHeight"] doubleValue];
    return model;
}

@end

@implementation PicassoNavigatorPopModel

+ (PicassoNavigatorPopModel *)modelWithDictionary:(NSDictionary *)params {
    PicassoNavigatorPopModel *model = [PicassoNavigatorPopModel new];
    model.animated = params[@"animated"] ? [params[@"animated"] boolValue] : YES;
    model.popToRoot = [params[@"popToRoot"] boolValue];
    return model;
}

@end
