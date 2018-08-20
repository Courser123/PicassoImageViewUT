//
//  PicassoSwitchWrapper.m
//  Picasso
//
//  Created by pengfei.zhou on 2018/4/26.
//

#import "PicassoSwitchWrapper.h"
#import "PicassoSwitch.h"
#import "PicassoSwitchModel.h"

@implementation PicassoSwitchWrapper

+ (Class)viewClass {
    return [PicassoSwitch class];
}

+ (Class)modelClass {
    return [PicassoSwitchModel class];
}

+ (UIView *)createViewWithModel:(PicassoModel *)model inPicassoView:(PicassoView *)picassoView {
    PicassoSwitch *sw = [PicassoSwitch new];
    [self updateView:sw withModel:model inPicassoView:picassoView];
    return sw;
}

+ (void)updateView:(UIView *)view withModel:(PicassoModel *)model inPicassoView:(PicassoView *)picassoView {
    [super updateView:view withModel:model inPicassoView:picassoView];
    if ([view isKindOfClass:[PicassoSwitch class]]) {
        PicassoSwitch *sw = (PicassoSwitch *)view;
        [sw updateWithModel:(PicassoSwitchModel *)model];
    }
}

@end
