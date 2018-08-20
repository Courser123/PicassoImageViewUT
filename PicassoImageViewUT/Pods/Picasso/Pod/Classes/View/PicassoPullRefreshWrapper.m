//
//  PicassoDragRefreshViewWrapper.m
//  Pods
//
//  Created by 纪鹏 on 2017/6/20.
//
//

#import "PicassoPullRefreshWrapper.h"
#import "PicassoPullRefreshModel.h"
#import "PicassoSimpleRefreshHeaderView.h"


@implementation PicassoPullRefreshWrapper

+ (Class)viewClass {
    return [PicassoSimpleRefreshHeaderView class];
}

+ (Class)modelClass {
    return [PicassoPullRefreshModel class];
}

+ (UIView *)createViewWithModel:(PicassoModel *)model inPicassoView:(PicassoView *)picassoView {
    CGRect rect = CGRectMake(model.x, model.y, model.width, model.height);
    PicassoSimpleRefreshHeaderView *refreshView = [[PicassoSimpleRefreshHeaderView alloc] initWithFrame:rect];
    [self updateView:refreshView withModel:model inPicassoView:picassoView];
    return refreshView;
}

+ (void)updateView:(UIView *)view withModel:(PicassoModel *)model inPicassoView:(PicassoView *)picassoView {
    [super updateView:view withModel:model inPicassoView:picassoView];
}

@end
