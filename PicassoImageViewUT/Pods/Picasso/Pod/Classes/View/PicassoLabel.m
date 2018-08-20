//
//  PicassoLabel.m
//  clogan
//
//  Created by 纪鹏 on 2017/10/19.
//

#import "PicassoLabel.h"
#import "PicassoLabelModel.h"
#import "PicassoJSObject.h"
#import "PicassoVCHost.h"
#import "PicassoHostManager.h"

@interface PicassoLabel ()

@property (nonatomic, strong) PicassoLabelModel *labelModel;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@end

@implementation PicassoLabel

- (void)updateWithModel:(PicassoLabelModel *)model {
    self.labelModel = model;
    self.textColor = model.textColor;
    self.font = model.font;
    self.textAlignment = model.textAlignment;
    self.lineBreakMode = model.lineBreakMode;
    self.numberOfLines = model.numberOfLines;
    if (model.attributedText) {
        self.attributedText = nil;
        self.attributedText = model.attributedText;
        [self setLabelBorderStyleWithJsonString:model.text];
    } else {
        self.attributedText = nil;
        self.text = model.text;
    }
    [self handleActions:model.actions];
}

- (void)handleActions:(NSArray<NSString *> *)actions {
    if (self.tapGesture) {
        [self removeGestureRecognizer:self.tapGesture];
    }
    if (actions.count == 0) {
        self.userInteractionEnabled = NO;
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
    PicassoHost *host = [PicassoHostManager hostForId:self.labelModel.hostId];
    if (![host isKindOfClass:[PicassoVCHost class]]) return;
    PicassoVCHost *vcHost = (PicassoVCHost *)host;
    [vcHost dispatchViewEventWithViewId:self.labelModel.viewId action:@"click" params:nil];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    if (highlighted && self.labelModel.highlightedBgColor) {
        self.backgroundColor = self.labelModel.highlightedBgColor;
    }
}

@end
