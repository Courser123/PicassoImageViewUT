//
//  PicassoItemViewModel.m
//  Pods
//
//  Created by 纪鹏 on 2017/6/11.
//
//

#import "PicassoListItemModel.h"
#import "PicassoBaseModel+Private.h"
#import "PicassoVCHost.h"
#import "PicassoVCHost+Private.h"
#import "PicassoHostManager.h"

@implementation PicassoListItemModel

- (void)setModelWithDictionary:(NSDictionary *)dictionaryValue {
    [super setModelWithDictionary:dictionaryValue];
    self.reuseId = [dictionaryValue objectForKey:@"reuseId"];
}

@end
