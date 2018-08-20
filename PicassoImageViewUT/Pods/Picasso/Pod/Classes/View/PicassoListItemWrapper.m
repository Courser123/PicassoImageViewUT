//
//  PicassoItemViewWrapper.m
//  Pods
//
//  Created by 纪鹏 on 2017/6/11.
//
//

#import "PicassoListItemWrapper.h"
#import "PicassoListItemModel.h"
#import "PicassoListCell.h"

@implementation PicassoListItemWrapper

+ (Class)viewClass {
    return [PicassoListCell class];
}

+ (Class)modelClass {
    return [PicassoListItemModel class];
}

+ (UIView *)createViewWithModel:(PicassoModel *)model inPicassoView:(PicassoView *)picassoView {
    PicassoListCell *cell = [[PicassoListCell alloc] initWithModel:(PicassoListItemModel *)model];
    [self updateView:cell withModel:model inPicassoView:picassoView];
    return cell;
}

+ (void)updateView:(UIView *)view withModel:(PicassoModel *)model inPicassoView:(PicassoView *)picassoView {
    UIView *contentView = ((UITableViewCell *)view).contentView;
    [super updateView:contentView withModel:model inPicassoView:picassoView];
    if ([view isKindOfClass:[PicassoListCell class]]) {
        PicassoListCell *cell = (PicassoListCell *)view;
        [cell updateWithModel:(PicassoListItemModel *)model];
    }
}

@end
