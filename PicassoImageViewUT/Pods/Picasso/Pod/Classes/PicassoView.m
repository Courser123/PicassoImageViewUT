//
//  PicassoView.m
//  Pods
//
//  Created by Stephen Zhang on 16/7/18.
//
//

#import "PicassoView.h"
#import "PicassoDebugMode.h"
#import "PicassoModel.h"
#import "PicassoInput.h"
#import "RACSignal.h"
#import "RACSubscriber.h"
#import "UIView+Picasso.h"
#import "ReactiveCocoa.h"
#import "UIView+PicassoNotification.h"
#import "PicassoUtility.h"
#import "PicassoViewInput.h"
#import "PicassoGroupViewWrapper.h"
#import "PicassoVCHost.h"
#import "PicassoHostManager.h"

@interface PicassoViewInput (Private)
- (void)bindPicassoView:(PicassoView *)picassoView;
- (PicassoModel *)getPModel;
@end

@interface PicassoInput (Private)
- (PicassoModel *)getPModel;
@end

@interface PicassoView ()

@property (nonatomic, weak) PicassoInput *debugInput;
@property (nonatomic, weak) PicassoViewInput *debugViewInput;
@property (nonatomic, strong) PicassoNotificationCenter *defaultCenter;
@property (nonatomic, weak) PicassoVCHost *host;

@end

@implementation PicassoView

+ (PicassoView *)createView:(PicassoInput *)input {    
    PicassoView *view = [PicassoView new];
    return view;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self _innerInit];
    }
    return self;
}

- (void)_innerInit {
    _defaultCenter = [PicassoNotificationCenter new];
    if ([PicassoUtility isDebug]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileChange:) name:PicassoDebugFileChangeNotification object:nil];
    }
}

- (void)fileChange:(NSNotification *)n {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *resultDic = n.object;
        if ([resultDic isKindOfClass:[NSDictionary class]]) {
            NSString *fileName = [[resultDic objectForKey:@"fileName"] componentsSeparatedByString:@"."].firstObject;
            if ([self.debugInput.jsName isEqualToString:fileName]) {
                self.debugInput.jsContent = [resultDic objectForKey:@"content"];
                @weakify(self)
                [[self.debugInput computeSignal] subscribeNext:^(PicassoInput * input) {
                    @strongify(self)
                    [self painting:input];
                }];
            } else if ([self.debugViewInput.jsName containsString:fileName]) {
                self.debugViewInput.jsContent = [resultDic objectForKey:@"content"];
                @weakify(self)
                [[self.debugViewInput computeSignal] subscribeNext:^(PicassoViewInput *input) {
                    @strongify(self)
                    [self paintingInput:input];
                }];
            }
        }
    });
}

- (void)painting:(PicassoInput *)input {
    PicassoModel *model = [input getPModel];
    if ([PicassoUtility isDebug]) {
        self.debugInput = input;
    }
    [self paintViewWithModel:model];
}

- (void)modelPainting:(PicassoModel *)model {
    [self paintViewWithModel:model];
}

- (void)paintViewWithModel:(PicassoModel *)model {
    if (model && model.type == 0) {
        [PicassoGroupViewWrapper updateView:self withModel:model inPicassoView:self];
    } else {
        NSLog(model?@"":@"model is nil, there maybe be JS execuation error");
        NSAssert(model.type == 0, @"root view should be View class");
    }
}

+ (CGFloat)getViewHeight:(PicassoInput *)input {
    return [input getPModel].height;
}

+ (CGFloat)getViewWidth:(PicassoInput *)input {
    return [input getPModel].width;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - UT

- (UIView *)viewWithPTag:(NSString *)pTag
{
    return [self findViewWithTag:pTag inView:self];
}

- (UIView *)findViewWithTag:(NSString *)tag inView:(UIView *)view
{
    if ([view.p_tag isEqualToString:tag]) {
        return view;
    }
    for (UIView *subView in view.subviews) {
        UIView *resultView = [self findViewWithTag:tag inView:subView];
        if (resultView) {
            return resultView;
        }
    }
    return nil;
}

/************** PicassoViewInput接口 ******************/

- (void)paintingInput:(PicassoViewInput *)input {
    PicassoModel *model = [input getPModel];
    if ([input respondsToSelector:@selector(bindPicassoView:)]) {
        [input bindPicassoView:self];
    }
    if ([PicassoUtility isDebug]) {
        self.debugViewInput = input;
    }
    [self paintViewWithModel:model];
    PicassoHost *host = [PicassoHostManager hostForId:model.hostId];
    if ([host isKindOfClass:[PicassoVCHost class]]) {
        [(PicassoVCHost *)host notifyLayoutFinished];
    }
}

+ (CGFloat)getHeight:(PicassoViewInput *)input {
    return [input getPModel].height;
}

+ (CGFloat)getWidth:(PicassoViewInput *)input {
    return [input getPModel].width;
}

@end
