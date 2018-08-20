//
//  PicassoGroupView.m
//  clogan
//
//  Created by 纪鹏 on 2017/10/19.
//

#import "PicassoGroupView.h"
#import "PicassoViewModel.h"
#import "PicassoHostManager.h"
#import "PicassoVCHost.h"

@interface PicassoGroupView ()

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) PicassoViewModel *viewModel;

@end

@implementation PicassoGroupView

- (void)updateWithModel:(PicassoViewModel *)model inPicassoView:(PicassoView *)pcsView {
    self.viewModel = model;
    if (model.clipToBounds == NO) {
        self.clipsToBounds = NO;
    }
    [self handleActions:model.actions];
}

- (void)handleActions:(NSArray<NSString *> *)actions {
    if (self.tapGesture) {
        [self removeGestureRecognizer:self.tapGesture];
    }
    if (actions.count == 0) {
        return;
    }
    self.userInteractionEnabled = YES;
    for (NSString *action in actions) {
        if ([action isEqualToString:@"click"]) {
            self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewClicked)];
            [self addGestureRecognizer:self.tapGesture];
        }
    }
}

- (void)viewClicked {
    PicassoHost *host = [PicassoHostManager hostForId:self.viewModel.hostId];
    if (![host isKindOfClass:[PicassoVCHost class]]) return;
    PicassoVCHost *vcHost = (PicassoVCHost *)host;
    [vcHost dispatchViewEventWithViewId:self.viewModel.viewId action:@"click" params:nil];
}

@end
