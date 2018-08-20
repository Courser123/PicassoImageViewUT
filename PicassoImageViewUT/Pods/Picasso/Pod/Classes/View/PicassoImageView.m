//
//  PicassoImageView.m
//  clogan
//
//  Created by 纪鹏 on 2017/10/19.
//

#import "PicassoImageView.h"
#import "PicassoImageViewModel.h"
#import "UIImageView+WebCache.h"
#import "PicassoVCHost.h"
#import "PicassoHostManager.h"

@interface PicassoImageView () <PicassoImageViewDelegate>
@property (nonatomic, strong) PicassoImageViewModel *imageModel;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, assign) BOOL imageLoadAction;
@end

@implementation PicassoImageView

- (void)updateWithModel:(PicassoImageViewModel *)model {
    self.imageModel = model;
    self.contentMode = model.contentMode;
    self.clipsToBounds = YES;
    self.fadeEffect = model.fadeEffect;
    self.enableRetry = model.failedRetry;
    if (model.blurRadius > 0) {
        CGFloat radius = ceilf(MIN(model.blurRadius, 1.0) * 25);
        self.blurRadius = radius;
    } else {
        self.blurRadius = 0.0f;
    }
    if (model.localImage) {
        self.image = [self needResize] ? [self resizedImage:model.localImage] : model.localImage;
    } else {
        self.delegate = self;
        self.loadingImage = model.loadingImage;
        self.emptyImage = model.loadingImage;
        self.errorImage = model.errorImage;
        [self setImageURLString:model.imageUrl withBusiness:@"Default" cacheType:model.cacheType];
    }
    [self handleActions:model.actions];
}

- (void)handleActions:(NSArray<NSString *> *)actions {
    self.imageLoadAction = NO;
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
        if ([action isEqualToString:@"imageLoaded"]) {
            self.imageLoadAction = YES;
        }
    }
}

- (void)viewClicked {
    PicassoHost *host = [PicassoHostManager hostForId:self.imageModel.hostId];
    if (![host isKindOfClass:[PicassoVCHost class]]) return;
    PicassoVCHost *vcHost = (PicassoVCHost *)host;
    [vcHost dispatchViewEventWithViewId:self.imageModel.viewId action:@"click" params:nil];
}

- (void)imageViewDidFinishLoading:(PicassoBaseImageView *)imageView {
    UIImage *image = imageView.image;
    if (self.imageLoadAction) {
        PicassoHost *host = [PicassoHostManager hostForId:self.imageModel.hostId];
        if (![host isKindOfClass:[PicassoVCHost class]]) return;
        PicassoVCHost *vcHost = (PicassoVCHost *)host;
        [vcHost dispatchViewEventWithViewId:self.imageModel.viewId action:@"imageLoaded" params:@{@"success":@(YES), @"width":@(image.size.width * image.scale), @"height":@(image.size.height * image.scale)}];
    }
    if ([self needResize]) {
        imageView.image = [self resizedImage:image];
    }
}

- (BOOL)needResize {
    return !UIEdgeInsetsEqualToEdgeInsets(self.imageModel.edgeInsets, UIEdgeInsetsZero);
}

- (UIImage *)resizedImage:(UIImage *)image {
    UIImage *midImage = [[UIImage alloc] initWithCGImage:image.CGImage scale:self.imageModel.imageScale orientation:image.imageOrientation];
    UIImage *resizeImage = [midImage resizableImageWithCapInsets:self.imageModel.edgeInsets resizingMode:UIImageResizingModeStretch];
    return resizeImage;
}

- (void)imageViewDidLoadFailed:(PicassoBaseImageView *)imageView {
    if (self.imageLoadAction) {
        PicassoHost *host = [PicassoHostManager hostForId:self.imageModel.hostId];
        if (![host isKindOfClass:[PicassoVCHost class]]) return;
        PicassoVCHost *vcHost = (PicassoVCHost *)host;
        [vcHost dispatchViewEventWithViewId:self.imageModel.viewId action:@"imageLoaded" params:@{@"success":@(NO)}];
    }
}

- (void)imageView:(PicassoBaseImageView *)imageView gifImagePlayedWithCount:(NSUInteger)count {
    if (self.imageModel.gifLoopCount > -1 && count >= self.imageModel.gifLoopCount) {
        [self pausePlaying];
    }
}

@end
