//
//  PicassoButton.m
//  clogan
//
//  Created by 纪鹏 on 2017/10/19.
//

#import "PicassoButton.h"
#import "PicassoButtonModel.h"
#import "PicassoView.h"
#import "UIView+PicassoNotification.h"
#import "PicassoHostManager.h"
#import "PicassoVCHost.h"

@interface PicassoButton ()
@property (nonatomic, strong) PicassoButtonModel *buttonModel;
@property (nonatomic, assign) BOOL clickAction;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;
@end

@implementation PicassoButton

- (instancetype)init {
    if (self = [super init]) {
        [self addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)updateViewWithModel:(PicassoButtonModel *)model inPicassoView:(PicassoView *)picassoView {
    self.buttonModel = model;
    __weak typeof(self) weakSelf = self;
    self.pcs_action = ^() {
        NSDictionary *userInfo = @{@"data"      :model.data?:@{},
                                   @"view"      :weakSelf,
                                   @"schema"    :model.schema?:@"",
                                   @"gaLabel"   :model.gaLabel?:@"",
                                   @"gaUserInfo":model.gaUserInfo?:@{}};
        [weakSelf.pcs_defaultCenter postNotificationName:PicassoControlEventClick userInfo:[[PicassoNotificationUserInfo alloc] initWithViewTag:model.tag userInfo:userInfo]];
    };
    [self setBackgroundImage:model.normalImage forState:UIControlStateNormal];
    [self setBackgroundImage:model.clickedImage forState:UIControlStateHighlighted];
    [self handleActions:model.actions];
}

- (void)handleActions:(NSArray<NSString *> *)actions {
    self.clickAction = NO;
    if (self.longPressGesture) {
        [self removeGestureRecognizer:self.longPressGesture];
    }
    for (NSString *action in actions) {
        if ([action isEqualToString:@"click"]) {
            self.clickAction = YES;
        }
        if ([action isEqualToString:@"longPress"]) {
            self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
            [self addGestureRecognizer:self.longPressGesture];
        }
    }
}

- (void)buttonClicked {
    if (self.pcs_action) {
        self.pcs_action();
    }
    if (self.clickAction) {
        PicassoHost *host = [PicassoHostManager hostForId:self.buttonModel.hostId];
        if (![host isKindOfClass:[PicassoVCHost class]]) return;
        PicassoVCHost *vcHost = (PicassoVCHost *)host;
        [vcHost dispatchViewEventWithViewId:self.buttonModel.viewId action:@"click" params:nil];
    }
}

- (void)longPress:(UILongPressGestureRecognizer *)longPressGesture {
    if (longPressGesture.state == UIGestureRecognizerStateBegan) {
        PicassoHost *host = [PicassoHostManager hostForId:self.buttonModel.hostId];
        if (![host isKindOfClass:[PicassoVCHost class]]) return;
        PicassoVCHost *vcHost = (PicassoVCHost *)host;
        [vcHost dispatchViewEventWithViewId:self.buttonModel.viewId action:@"longPress" params:nil];
    }
}

@end
