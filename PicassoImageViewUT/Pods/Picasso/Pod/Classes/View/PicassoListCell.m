//
//  PicassoListItem.m
//  Picasso
//
//  Created by 纪鹏 on 2018/2/28.
//

#import "PicassoListCell.h"
#import "PicassoListItemModel.h"
#import "PicassoVCHost.h"
#import "PicassoHostManager.h"

@interface PicassoListCell ()
@property (nonatomic, strong) PicassoListItemModel *itemModel;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@end

@implementation PicassoListCell

- (instancetype)initWithModel:(PicassoListItemModel *)model {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:model.reuseId]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)updateWithModel:(PicassoListItemModel *)model {
    self.itemModel = model;
    self.backgroundColor = model.backgroundColor;
    [self handleActions:model.actions];
}

- (void)handleActions:(NSArray<NSString *> *)actions {
    if (self.tapGesture) {
        [self.contentView removeGestureRecognizer:self.tapGesture];
    }
    if (actions.count == 0) {
        return;
    }
    self.contentView.userInteractionEnabled = YES;
    for (NSString *action in actions) {
        if ([action isEqualToString:@"click"]) {
            self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewClicked)];
            [self.contentView addGestureRecognizer:self.tapGesture];
        }
    }
}

- (void)viewClicked {
    PicassoHost *host = [PicassoHostManager hostForId:self.itemModel.hostId];
    if (![host isKindOfClass:[PicassoVCHost class]]) return;
    PicassoVCHost *vcHost = (PicassoVCHost *)host;
    [vcHost dispatchViewEventWithViewId:self.itemModel.viewId action:@"click" params:nil];
}

@end
