//
//  PicassoSwitch.m
//  Picasso
//
//  Created by pengfei.zhou on 2018/4/26.
//

#import "PicassoSwitch.h"
#import "PicassoHostManager.h"
#import "PicassoVCHost.h"

@interface PicassoSwitch ()

@property (nonatomic, strong) PicassoSwitchModel *switchModel;

@end

@implementation PicassoSwitch

- (void)updateWithModel:(PicassoSwitchModel *)model {
    [self setOn:model.on];
    self.tintColor = model.tintColor;
    self.backgroundColor = model.tintColor;
    if(model.tintColor){
        self.layer.cornerRadius = self.bounds.size.height/2.0;
        self.layer.masksToBounds = true;
    }

    self.onTintColor = model.onTintColor;
    self.thumbTintColor = model.thumbTintColor;
    self.clipsToBounds = NO;
    self.switchModel = model;
    [self handleActions:model.actions];
}

- (void)handleActions:(NSArray <NSString*>*)actions {
    [self removeTarget:self action:@selector(switchAction) forControlEvents:UIControlEventValueChanged];
    if (actions.count == 0) {
        return;
    }
    for(NSString *action in actions){
        if([action isEqualToString:@"onSwitch"]) {
            [self addTarget:self action:@selector(switchAction) forControlEvents:UIControlEventValueChanged];
        }
    }
}

-(void)switchAction {
    PicassoHost *host = [PicassoHostManager hostForId:self.switchModel.hostId];
    if (![host isKindOfClass:[PicassoVCHost class]]) return;
    PicassoVCHost *vcHost = (PicassoVCHost *)host;
    [vcHost dispatchViewEventWithViewId:self.switchModel.viewId action:@"onSwitch" params:@{@"isOn":[NSNumber numberWithBool:self.isOn]}];
}
@end
