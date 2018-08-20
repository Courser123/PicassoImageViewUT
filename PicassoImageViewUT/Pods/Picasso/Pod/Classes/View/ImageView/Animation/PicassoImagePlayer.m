//
//  PicassoImagePlayer.m
//  ImageViewBase
//
//  Created by welson on 2018/3/6.
//

#import "PicassoImagePlayer.h"
#import "PicassoWeakProxy.h"
#import "PicassoImagePlayerDiskManager.h"

@interface PicassoImagePlayer()

@property (nonatomic, strong) PicassoDecodedImage *decodeImageObj;

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) BOOL needsDisplayWhenImageBecomesAvailable;
@property (nonatomic, assign) NSTimeInterval accumulator;

@property (nonatomic, assign) NSUInteger currentIdx;
@property (nonatomic, strong) UIImage *windowFrame;

@property (nonatomic, assign) NSUInteger loopCount;

@end

@implementation PicassoImagePlayer

- (instancetype)initWithImageData:(NSData *)imageData {
    PicassoDecodedImage *decodeImageObj = [[PicassoDecodedImage alloc] initWithData:imageData];
    return [self initWithDecodedObj:decodeImageObj];
}

- (instancetype)initWithDecodedObj:(PicassoDecodedImage *)decodeObj {
    if (self = [super init]) {
        _decodeImageObj = decodeObj;
        _windowFrame = _decodeImageObj.imageObj.windowFrame;
        _currentIdx = 0;
        _isPlaying = NO;
        _diskAssistant = NO;
        
        _loopCount = 0;
    }
    return self;
}

- (void)play {
    [self resume];
}

- (void)resume {
    if (![self multiPicImage]) return;
    if (self.isPlaying) return;
    self.isPlaying = YES;
    
    if (self.displayLink) {
        self.displayLink.paused = NO;
    }else {
        PicassoWeakProxy *weakProxy = [PicassoWeakProxy weakProxyForObject:self];
        self.displayLink = [CADisplayLink displayLinkWithTarget:weakProxy selector:@selector(loopImages:)];
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void)pause {
    if (![self multiPicImage]) return;
    
    self.isPlaying = NO;
    if (!self.displayLink) return;
    self.displayLink.paused = YES;
}

- (void)stop {
    if (![self multiPicImage]) return;
    
    self.isPlaying = NO;
    if (self.displayLink) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
    [self resetParam];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(picassoImagePlayer:shouldDisplayImage:idx:)]) {
        [self.delegate picassoImagePlayer:self shouldDisplayImage:self.windowFrame idx:self.currentIdx];
    }
    [self prepareNextFrame];
}

- (void)prepareNextFrame {
    NSUInteger nextRequestFrameIdx = (self.currentIdx + 1) % self.decodeImageObj.imageObj.frameCount;
    if (self.diskAssistant && self.identifier.length) {
        UIImage *cachedImage = [[PicassoImagePlayerDiskManager shareInstance] imageWithKey:self.identifier idx:nextRequestFrameIdx];
        if (cachedImage) {
            self.windowFrame = cachedImage;
            return;
        }
    }
    __weak typeof(PicassoImagePlayer) *weakSelf = self;
//    NSLog(@"Request frame idx: %@", @(nextRequestFrameIdx));
    [self.decodeImageObj.imageObj asyncDecodeCertainFrames:@[@(nextRequestFrameIdx)] WithCompleteHandler:^(NSDictionary<NSNumber *,UIImage *> *result, NSArray<NSNumber *> *failedIdxes, id userinfo) {
        NSUInteger needIdx = weakSelf.needsDisplayWhenImageBecomesAvailable?weakSelf.currentIdx:(weakSelf.currentIdx + 1)%weakSelf.decodeImageObj.imageObj.frameCount;
//        if (nextRequestFrameIdx == needIdx) {
//            NSLog(@"%@ decoded!", @(nextRequestFrameIdx));
//        }else {
//            NSLog(@"%@ decoded! But we need %@ frame!", @(nextRequestFrameIdx), @((self.currentIdx + 1) % self.decodeImageObj.imageObj.frameCount));
//        }
        
        UIImage *image = result[@(needIdx)];
        if (image) weakSelf.windowFrame = image;
        if (self.diskAssistant && self.identifier.length) [[PicassoImagePlayerDiskManager shareInstance] savePhoto:image withKey:weakSelf.identifier idx:nextRequestFrameIdx];
    }];
}

- (void)resetParam {
    self.currentIdx = 0;
    self.accumulator = 0;
    self.loopCount = 0;
    self.windowFrame = self.decodeImageObj.imageObj.windowFrame;
}

- (BOOL)multiPicImage {
    if (self.decodeImageObj.imageObj.frameCount < 2) return NO;
    return YES;
}

- (void)loopImages:(CADisplayLink *)displayLink {
    NSNumber *delayTimeNumber = [self.decodeImageObj.imageObj.frameDuration objectForKey:@(self.currentIdx)];
    NSTimeInterval delayTime = [delayTimeNumber floatValue];
    if (delayTime) {
        UIImage *image = self.windowFrame;
        if (image) {
            if (self.needsDisplayWhenImageBecomesAvailable) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(picassoImagePlayer:shouldDisplayImage:idx:)]) {
                    [self.delegate picassoImagePlayer:self shouldDisplayImage:image idx:self.currentIdx];
                }
                [self prepareNextFrame];
                self.needsDisplayWhenImageBecomesAvailable = NO;
            }
            
            self.accumulator += displayLink.duration * displayLink.frameInterval;
            
            while (self.accumulator >= delayTime) {
                self.accumulator -= delayTime;
                self.currentIdx = (self.currentIdx + 1) % self.decodeImageObj.imageObj.frameCount;
                
                if (self.currentIdx == 0) {
                    self.loopCount ++;
                    if (self.delegate && [self.delegate respondsToSelector:@selector(picassoImagePlayer:loopCount:)]) {
                        [self.delegate picassoImagePlayer:self loopCount:self.loopCount];
                    }
                }
                
                self.needsDisplayWhenImageBecomesAvailable = YES;
            }
        }
    }else {
        self.currentIdx = (self.currentIdx + 1) % self.decodeImageObj.imageObj.frameCount;
    }
}

- (UIImage *)posterImage {
    return self.decodeImageObj.imageObj.windowFrame;
}

- (void)dealloc {
    NSLog(@"PicassoImagePlayer dealloc!!!");
    
    [self.displayLink invalidate];
    self.displayLink = nil;
}

@end
