//
//  PicassoListViewWrapper.m
//  Pods
//
//  Created by 纪鹏 on 2017/6/11.
//
//

#import "PicassoListViewWrapper.h"
#import "PicassoListViewModel.h"
#import "PicassoListItemModel.h"
#import "PicassoListItemWrapper.h"
#import "UIView+Picasso.h"
#import "PicassoRefreshControl.h"
#import "PicassoPullRefreshWrapper.h"
#import "PicassoBridgeContext.h"
#import "PicassoDefine.h"
#import "PicassoLoadingViewWrapper.h"
#import "PicassoTableView.h"

@implementation PicassoListViewWrapper

+ (Class)viewClass {
    return [PicassoTableView class];
}

+ (Class)modelClass {
    return [PicassoListViewModel class];
}

+ (UIView *)createViewWithModel:(PicassoModel *)model inPicassoView:(PicassoView *)picassoView {
    PicassoTableView *tableview = [[PicassoTableView alloc] initWithModel:(PicassoListViewModel *)model];
    [self updateView:tableview withModel:model inPicassoView:picassoView];
    return tableview;
}

+ (void)updateView:(UIView *)view withModel:(PicassoModel *)model inPicassoView:(PicassoView *)picassoView {
    [super updateView:view withModel:model inPicassoView:picassoView];
    if ([view isKindOfClass:[PicassoTableView class]]) {
        [(PicassoTableView *)view updateWithModel:(PicassoListViewModel *)model];
    }
}

@end
