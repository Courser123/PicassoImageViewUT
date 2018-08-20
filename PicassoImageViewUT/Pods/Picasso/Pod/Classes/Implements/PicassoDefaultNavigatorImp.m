//
//  PicassoDefaultNavigatorImp.m
//  CocoaAsyncSocket
//
//  Created by 纪鹏 on 2017/7/2.
//

#import "PicassoDefaultNavigatorImp.h"
#import "PicassoBaseViewController.h"
#import "PicassoHostManager.h"
#import "PicassoHost+Bridge.h"
#import "UIView+Picasso.h"
#import "UIColor+pcsUtils.h"
#import "UIView+Layout.h"
#import "UIImageView+WebCache.h"
#import "UIImage+Picasso.h"

@interface PicassoNavigatorItemView: UIView

@property (nonatomic, strong) PicassoNavigatorItemModel *model;
@property (nonatomic, strong) NSNumber *idx;

@end

@implementation PicassoNavigatorItemView

+ (PicassoNavigatorItemView *)viewWithItemModel:(PicassoNavigatorItemModel *)model {
    PicassoNavigatorItemView *bgView = [[PicassoNavigatorItemView alloc] initWithFrame:(CGRect){0,0,0,30}];
    bgView.model = model;
    UIView *contentView;
    if (model.title.length) {
        UILabel *label = [[UILabel alloc] init];
        label.text  = model.title;
        if (model.titleColor.length) {
            label.textColor = [UIColor pcsColorWithHexString:model.titleColor];
        }
        label.size = [label sizeThatFits:(CGSize){CGFLOAT_MAX, 30}];
        contentView = label;
    } else if (model.iconName.length || model.iconUrl.length || model.iconBase64.length) {
        UIImageView *imageview = [[UIImageView alloc] initWithFrame:(CGRect){0, 0, model.iconWidth, model.iconHeight}];
        if (model.iconName.length) {
            imageview.image = [UIImage imageNamed:model.iconName];
        } else if (model.iconBase64.length) {
            imageview.image = [UIImage pcs_imageWithBase64:model.iconBase64];
        } else {
            [imageview sd_setImageWithURL:[NSURL URLWithString:model.iconUrl]];
        }
        contentView = imageview;
    }
    bgView.width = contentView.width;
    [bgView addSubview:contentView];
    contentView.centerY = bgView.height/2;
    
    if (model.callback) {
        UIButton *clickBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [clickBtn addTarget:bgView action:@selector(btnClicked) forControlEvents:UIControlEventTouchUpInside];
        [bgView addSubview:clickBtn];
        clickBtn.frame = bgView.bounds;
    }
    return bgView;
}

- (void)btnClicked {
    [self.model.callback sendNext:(self.idx ? @{@"index":self.idx} : nil)];
}

@end

@implementation PicassoDefaultNavigatorImp

- (void)popViewControllerWithModel:(PicassoNavigatorPopModel *)model withViewController:(UIViewController *)controller {
    [controller.navigationController popViewControllerAnimated:model.animated];
}

- (void)setNavigationBarTitleWithModel:(PicassoNavigatorItemModel *)model withViewController:(UIViewController *)controller
{
    if (model.title.length > 0 && model.titleColor.length == 0) {
        controller.navigationItem.title = model.title;
    } else {
        PicassoNavigatorItemView *itemView = [PicassoNavigatorItemView viewWithItemModel:model];
        [controller.navigationItem setTitleView:itemView];
    }
}

- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated withController:(UIViewController *)controller {
    [controller.navigationController setNavigationBarHidden:hidden animated:animated];
}

- (void)setLeftNavigationItemsWithModelArray:(NSArray<PicassoNavigatorItemModel *> *)modelArr withViewController:(UIViewController *)controller {
    NSMutableArray *barItemArr = [NSMutableArray new];
    for (NSInteger idx = 0; idx < modelArr.count; idx++) {
        PicassoNavigatorItemView *itemView = [PicassoNavigatorItemView viewWithItemModel:modelArr[idx]];
        itemView.idx = @(idx);
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:itemView];
        [barItemArr addObject:barButtonItem];
    }
    controller.navigationItem.leftBarButtonItems = barItemArr;
}

- (void)setRightNavigationItemsWithModelArray:(NSArray<PicassoNavigatorItemModel *> *)modelArr withViewController:(UIViewController *)controller {
    NSMutableArray *barItemArr = [NSMutableArray new];
    for (NSInteger idx = 0; idx < modelArr.count; idx++) {
        PicassoNavigatorItemView *itemView = [PicassoNavigatorItemView viewWithItemModel:modelArr[idx]];
        itemView.idx = @(idx);
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:itemView];
        [barItemArr addObject:barButtonItem];
    }
    controller.navigationItem.rightBarButtonItems = barItemArr;
}

- (void)setNavigationBarBackgroundColor:(UIColor *)backgroundColor withController:(UIViewController *)controller {
    if (backgroundColor) {
        controller.navigationController.navigationBar.barTintColor = backgroundColor;
    }
}

@end
