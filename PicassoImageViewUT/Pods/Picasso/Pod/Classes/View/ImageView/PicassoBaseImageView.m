//
//  PicassoBaseImageView.m
//  Pods
//
//  Created by Johnny on 15/12/29.
//
//

#import "NSData+PicassoImageType.h"
#import "PicassoBaseImageView.h"
#import "PicassoBaseHelper.h"
#import "PicassoWebpImageDecoder.h"
#import "PicassoFetchImageSignal.h"
#import "PicassoBaseImageView+Addition.h"
#import "PicassoDecodedImage.h"
#import "PicassoImagePlayer.h"
#import "PicassoBaseImageLog.h"
#import "NVCodeLogger.h"
#import "UIImage+pcs_Effects.h"

@interface PicassoBaseImageView ()
<PicassoImagePlayerProtocol>

@property (nonatomic, assign) PicassoImageViewState       state;
@property (nonatomic, assign) UIViewContentMode       normalContentMode;
@property (nonatomic, strong) UIButton *retryButton;

@property (nonatomic, strong, readwrite) NSString *businessName;
@property (nonatomic, assign, readwrite) CRPicassoImageCache cacheType;

@property (nonatomic, strong) NSURL *internalImageUrl;

// fade animation
@property (nonatomic, strong) UIView *placeHolderView;
@property (nonatomic, assign) NSTimeInterval fadeEffectionDuration;
//@property (nonatomic, strong) UIImageView *noLoadingImageView;

@property (nonatomic, strong) PicassoDecodedImage *decodedImage;
@property (nonatomic, strong) PicassoImagePlayer *player;

// signal
@property (nonatomic,strong) PicassoFetchImageSignal *signal;
@property (nonatomic,strong) RACDisposable *disposable;

@property (nonatomic, assign) BOOL shouldAninate;
@property (nonatomic, assign) BOOL startPlay;

@property (nonatomic, strong) PicassoBaseImageLog *log;

@end

@implementation PicassoBaseImageView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _enableMemCache = YES;
        _enableDiskCache = YES;
        _enableRetry = NO;
        
        self.loadingImage = nil;
        self.fadeEffectionDuration = 0.5;
        self.blurRadius = 0;
        
        _retryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _retryButton.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        [_retryButton setImage:[UIImage imageNamed:@"picassoimageview_retry"] forState:UIControlStateNormal];
        _retryButton.backgroundColor = [UIColor colorWithRed:(230.0/255.0) green:(230.0/255.0) blue:(230.0/255.0) alpha:1];
        _retryButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        _retryButton.autoresizingMask = UIViewAutoresizingFlexibleHeight |UIViewAutoresizingFlexibleWidth;
        [_retryButton addTarget:self action:@selector(retryAction:) forControlEvents:UIControlEventTouchUpInside];
        _retryButton.hidden = YES;
        [self addSubview:_retryButton];
        
        _statusContentMode = UIViewContentModeScaleAspectFill;
        self.contentMode = UIViewContentModeScaleAspectFill;
        
        _state = PicassoBaseImageViewStateLoadSuccess;
        self.clipsToBounds = YES;
        _autoPlayImages = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBG) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterFG) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}

- (void)setEnableRetry:(BOOL)enableRetry
{
    _enableRetry = enableRetry;
    self.retryButton.hidden = !enableRetry;
}

- (void)setContentMode:(UIViewContentMode)contentMode{
    [super setContentMode:contentMode];
    self.normalContentMode = contentMode;
}

- (void)setImageURL:(NSURL *)imageURL{
    [self setImageURL:imageURL
         withBusiness:@"Default"];
}

- (void)setImageURLString:(NSString *)imageURLString{
    [self setImageURL:[NSURL URLWithString:imageURLString]];
}

- (void)setImageURL:(NSURL *)imageURL
       withBusiness:(NSString *)business
{
    [self setImageURL:imageURL
         withBusiness:business
            cacheType:CRPicassoImageCacheDefault];
}

- (void)setImageURLString:(NSString *)imageURLString
             withBusiness:(NSString *)business
{
    [self setImageURL:[NSURL URLWithString:imageURLString]
         withBusiness:business];
}

- (void)setImageURLString:(NSString *)imageURLString
             withBusiness:(NSString *)business
                cacheType:(CRPicassoImageCache)cacheType {
    [self setImageURL:[NSURL URLWithString:imageURLString]
         withBusiness:business
            cacheType:cacheType];
}

- (void)reloadURLWhenFailed {
    [self setImageURL:self.imageURL withBusiness:self.businessName cacheType:self.cacheType];
}

- (void)setImageURL:(NSURL *)imageURL
       withBusiness:(NSString *)business
          cacheType:(CRPicassoImageCache)cacheType {
    //translate `http` to `https`
    NSURL *transLatedUrl = [PicassoBaseHelper translatedUrl:imageURL];
    if ([self.internalImageUrl isEqual:transLatedUrl]) {
        if (self.state == PicassoBaseImageViewStateLoading) {
            if ([self.delegate respondsToSelector:@selector(imageViewDidBeginLoading:)]) {
                [(NSObject *)self.delegate performSelectorOnMainThread:@selector(imageViewDidBeginLoading:) withObject:self waitUntilDone:NO];
            }
            return;
        }else if (self.state == PicassoBaseImageViewStateLoadSuccess) {
            if ([self.delegate respondsToSelector:@selector(imageViewDidFinishLoading:)]) {
                [(NSObject *)self.delegate performSelectorOnMainThread:@selector(imageViewDidFinishLoading:) withObject:self waitUntilDone:NO];
            }
            if (self.autoPlayImages) [self startPlaying];
            return;
        }
    }
    [self removeLoadingViews];
    
    [self resetParam];
    
    self.businessName = business?:@"Default";
    self.cacheType = cacheType;
    _imageURL = imageURL;
    self.internalImageUrl = transLatedUrl;
    self.log.requestURL = self.internalImageUrl.absoluteString;
    self.log.st = CACurrentMediaTime();
//    NVLog(@"picasso start url request, url: %@ , currentTime: %@",self.internalImageUrl.absoluteString,[self convertDateToString:[NSDate date]]);
    [self getImageWithSignal];
}

- (NSString *)convertDateToString:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy:MM:dd HH:mm:ss"];
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    if (date) {
        return [formatter stringFromDate:date];
    }
    return nil;
}

- (NSString *)imageURLString{
    return [self.imageURL absoluteString];
}

- (void)getImageWithSignal {
    
    self.retryButton.hidden = YES;
    if (self.imageURL.absoluteString.length == 0) {
        self.state = PicassoBaseImageViewStateNoPic;
        return;
    };
    
    //    [self rebuildPlaceholderView];
    
    PicassoFetchImageSignal *fetchSignal = [[PicassoFetchImageSignal alloc] init];
    self.signal = fetchSignal;
    fetchSignal.enableMemCache = self.enableMemCache;
    fetchSignal.enableDiskCache = self.enableDiskCache;
    fetchSignal.syncReadFromDisk = self.syncReadFromDisk;
    fetchSignal.businessName = self.businessName;
    fetchSignal.cacheType = self.cacheType;
    fetchSignal.mark = self;
    fetchSignal.log = self.log;
    
    self.state = PicassoBaseImageViewStateLoading;
    
    @weakify(self);
    self.disposable = [[fetchSignal fetchSignalWithIdentifier:self.imageURL.absoluteString] subscribeNext:^(RACTuple *x) {
        PicassoFetchImageSignal *signal = x.first;
        BOOL success = [x.second boolValue];
        PicassoDecodedImage *decodedObj = x.third; //suppose x.third is PicassoDecodedImage object.
        CRPicassoImageCacheType cacheType = [x.fourth integerValue];
        
        [self.log addLog];
        
        @strongify(self);
        if (!self) return;
        if (signal != self.signal) return;
        self.signal = nil;
        self.decodedImage = decodedObj;
        
        if (success && decodedObj.imageObj.windowFrame) {
            UIImage *blurImage = decodedObj.imageObj.windowFrame;
            if (self.blurRadius > 0) {
                blurImage = [blurImage pcs_applyBlurWithRadius:self.blurRadius];
            }
            if (self.fadeEffect && cacheType != CRPicassoImageCacheTypeMemory) {
                [self fadeWithImage:blurImage contentMode:self.normalContentMode completion:^{
                    //                    [self setInternalImage:decodedObj.imageObj.windowFrame];
                }];
                if (self.autoPlayImages) [self startPlaying];
            }else {
                [self removeLoadingViews];
                [self setInternalImage:blurImage];
                if (self.autoPlayImages) [self startPlaying];
            }
            if (cacheType) {
                if ([self.delegate respondsToSelector:@selector(imageViewDidHitTheCache:)]) {
                    [(NSObject *)self.delegate performSelectorOnMainThread:@selector(imageViewDidHitTheCache:) withObject:self waitUntilDone:NO];
                }
            }
            self.state = PicassoBaseImageViewStateLoadSuccess;
        }else {
            self.state = PicassoBaseImageViewStateLoadFailed;
        }
    }];
    
}

- (void)setInternalImage:(UIImage *)image {
    [super setImage:image];
}

- (void)setState:(PicassoImageViewState)state{
    switch (state) {
        case PicassoBaseImageViewStateNoPic:{
            [super setContentMode:self.statusContentMode];
            [super setImage:self.emptyImage];
            if ([self.delegate respondsToSelector:@selector(imageViewDidFinishLoading:)]) {
                [(NSObject *)self.delegate performSelectorOnMainThread:@selector(imageViewDidFinishLoading:) withObject:self waitUntilDone:NO];
            }
            break;
        }
        case PicassoBaseImageViewStateLoading:{
            self.placeHolderView.alpha = 1;
            if (!self.placeHolderView.superview) {
                [self addSubview:self.placeHolderView];
            }
            self.placeHolderView.hidden = NO;
            [self setInternalImage:self.loadingImage];
            if ([self.delegate respondsToSelector:@selector(imageViewDidBeginLoading:)]) {
                [(NSObject *)self.delegate performSelectorOnMainThread:@selector(imageViewDidBeginLoading:) withObject:self waitUntilDone:NO];
            }
            break;
        }
        case PicassoBaseImageViewStateLoadSuccess:{
            if (_state == PicassoBaseImageViewStateLoading) {
                [super setContentMode:self.normalContentMode];
                if ([self.delegate respondsToSelector:@selector(imageViewDidFinishLoading:)]) {
                    [(NSObject *)self.delegate performSelectorOnMainThread:@selector(imageViewDidFinishLoading:) withObject:self waitUntilDone:NO];
                }
            }
            break;
        }
        case PicassoBaseImageViewStateLoadFailed:{
            if (_state == PicassoBaseImageViewStateLoading) {
                
                if (self.fadeEffect) {
                    [self fadeWithImage:self.errorImage
                            contentMode:self.statusContentMode
                             completion:^{
                                 [super setContentMode:self.statusContentMode];
                                 [super setImage:self.errorImage];
                             }];
                }else {
                    [self removeLoadingViews];
                    [super setContentMode:self.statusContentMode];
                    [super setImage:self.errorImage];
                }
                
                if (self.enableRetry) {
                    self.userInteractionEnabled = YES;
                    self.retryButton.hidden = NO;
                    [super setImage:nil];
                }
                if ([self.delegate respondsToSelector:@selector(imageViewDidLoadFailed:)]) {
                    [(NSObject *)self.delegate performSelectorOnMainThread:@selector(imageViewDidLoadFailed:) withObject:self waitUntilDone:NO];
                }
            }
            break;
        }
    }
    _state = state;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [self resetParam];
}

- (void)disposeCurrentSignal {
    if (self.disposable) [self.disposable dispose];
    if (self.signal) [self.signal cancel];
    if ([self.delegate respondsToSelector:@selector(imageViewDidCancelLoading:)]) {
        [(NSObject *)self.delegate performSelectorOnMainThread:@selector(imageViewDidCancelLoading:) withObject:self waitUntilDone:NO];
    }
    self.log.fetchSource = PicassoLogFetchSourceCancelled;
    self.log.finishedTime = CACurrentMediaTime() - self.log.st;
    [self.log addLog];
}

- (void)retryAction:(UIButton *)sender{
    //    [self getImage];
    self.userInteractionEnabled = NO;
    [self getImageWithSignal];
}

- (void)setImage:(UIImage *)image{
    [self removeLoadingViews];
    [self resetParam];
    
    [super setContentMode:self.normalContentMode];
    if (self.blurRadius > 0) {
        image = [image pcs_applyBlurWithRadius:self.blurRadius];
    }
    [super setImage:image];
    _state = PicassoBaseImageViewStateLoadSuccess;
    _imageURL = nil;
    _internalImageUrl = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.placeHolderView.frame = self.bounds;
}

#pragma mark - fade animation

- (void)fadeWithImage:(UIImage *)image
          contentMode:(UIViewContentMode)contentMode
           completion:(void (^)(void))completeblock{
    if (self.placeHolderView) {
        [self setInternalImage:image];
        [UIView animateWithDuration:self.fadeEffectionDuration delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.placeHolderView.alpha = 0;
        } completion:^(BOOL finished) {
            if (finished) {
                self.placeHolderView.hidden = YES;
                if (completeblock) {
                    completeblock();
                }
            }
        }];
    }else {
        [UIView transitionWithView:self duration:self.fadeEffectionDuration options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            [super setContentMode:contentMode];
            [self setInternalImage:image];
        } completion:^(BOOL finished) {
            if (finished) {
                if (completeblock) {
                    completeblock();
                }
            }
        }];
    }
}

- (void)removeLoadingViews {
    self.placeHolderView.hidden = YES;
}

#pragma mark - animated image play

- (void)startPlaying {
    if (![self.decodedImage canPlay]) return;
    if (self.player.isPlaying) return;
    self.startPlay = YES;
    [self updateShouldAnimate];
    
    if (!self.player) {
        self.player = [[PicassoImagePlayer alloc] initWithDecodedObj:self.decodedImage];
        self.player.delegate = self;
        //        self.player.diskAssistant = YES;
    }
    [self.player play];
}

- (void)resumePlaying {
    if (![self.decodedImage canPlay]) return;
    if (self.player.isPlaying) return;
    self.startPlay = YES;
    [self updateShouldAnimate];
    
    if (!self.player) {
        self.player = [[PicassoImagePlayer alloc] initWithDecodedObj:self.decodedImage];
        self.player.delegate = self;
        //        self.player.diskAssistant = YES;
    }
    [self.player resume];
}

- (void)stopPlaying {
    self.startPlay = NO;
    [self internalStopPlaying];
}

- (void)internalStopPlaying {
    if (![self.decodedImage canPlay]) return;
    [self.player stop];
    [self setInternalImage:self.decodedImage.imageObj.windowFrame];
}

- (void)pausePlaying {
    self.startPlay = NO;
    [self internalPausePlaying];
}

- (void)internalPausePlaying {
    if (![self.decodedImage canPlay]) return;
    [self.player pause];
}

#pragma mark - properties

- (void)setLoadingImage:(UIImage *)loadingImage {
    _loadingImage = loadingImage;
    self.placeHolderView = nil;
}

- (void)rebuildPlaceholderView {
    if (self.loadingImage) {
        if (self.placeHolderView) {
            ((UIImageView *)self.placeHolderView).image = self.loadingImage;
        }else {
            UIImageView *imageView = [UIImageView new];
            imageView.contentMode = self.statusContentMode;
            imageView.image = self.loadingImage;
            self.placeHolderView = imageView;
        }
    }
}

- (void)setStatusContentMode:(UIViewContentMode)statusContentMode {
    _statusContentMode = statusContentMode;
    if ([self.placeHolderView isKindOfClass:[UIImageView class]]) {
        ((UIImageView *)self.placeHolderView).contentMode = statusContentMode;
    }
}

- (void)setPlaceHolderView:(UIView *)placeHolderView {
    _placeHolderView = placeHolderView;
    placeHolderView.frame = self.bounds;
    placeHolderView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (BOOL)isPlaying {
    return self.player.isPlaying;
}

- (void)setImageData:(NSData *)imagedata {
    [self resetParam];
    if (!imagedata.length) {
        self.image = nil;
        return;
    }
    
    @weakify(self)
    [[PicassoFetchImageSignal setImageData:imagedata] subscribeNext:^(PicassoDecodedImage *decodedObj) {
        @strongify(self)
        
        self.decodedImage = decodedObj;
        UIImage *blurImage = decodedObj.imageObj.windowFrame;
        if (self.blurRadius > 0) {
            blurImage = [blurImage pcs_applyBlurWithRadius:self.blurRadius];
        }
        [self setInternalImage:blurImage];
        if (self.autoPlayImages) [self startPlaying];
    }];
    
}

- (void)resetParam {
    [self disposeCurrentSignal];
    self.player = nil;
    self.shouldAninate = NO;
    self.startPlay = NO;
    self.decodedImage = nil;
    self.log = [PicassoBaseImageLog new];
}

/**
 *  进入后台
 */
-(void)enterBG {
    [self pausePlaying];
}

/**
 *  返回前台
 */
-(void)enterFG {
    [self resumePlaying];
}


#pragma mark - picassoimageplayer delegate

- (void)picassoImagePlayer:(PicassoImagePlayer *)player
        shouldDisplayImage:(UIImage *)givenImage
                       idx:(NSUInteger)currentIdx {
    if (!self.shouldAninate) return;
    [self setInternalImage:givenImage];
}

- (void)picassoImagePlayer:(PicassoImagePlayer *)player
                 loopCount:(NSUInteger)count {
    if ([self.delegate respondsToSelector:@selector(imageView:gifImagePlayedWithCount:)]) {
        [self.delegate imageView:self gifImagePlayedWithCount:count];
    }
}

#pragma mark - stop play when invisible

- (void)didMoveToWindow {
    [super didMoveToWindow];
    
    [self updateShouldAnimate];
    if (self.shouldAninate) {
        [self startPlaying];
    }else {
        [self internalPausePlaying];
    }
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    
    [self updateShouldAnimate];
    if (self.shouldAninate) {
        [self startPlaying];
    }else {
        [self internalPausePlaying];
    }
}

- (void)setAlpha:(CGFloat)alpha {
    [super setAlpha:alpha];
    
    [self updateShouldAnimate];
    if (self.shouldAninate) {
        [self startPlaying];
    }else {
        [self internalPausePlaying];
    }
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    
    [self updateShouldAnimate];
    if (self.shouldAninate) {
        [self startPlaying];
    }else {
        [self internalPausePlaying];
    }
}

- (void)updateShouldAnimate {
    BOOL isVisible = self.window && self.superview && ![self isHidden] && self.alpha > 0;
    self.shouldAninate = self.startPlay && isVisible;
}

@end

