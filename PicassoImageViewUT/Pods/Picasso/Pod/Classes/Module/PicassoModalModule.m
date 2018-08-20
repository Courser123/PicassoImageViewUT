//
//  PicassoModalModule.m
//  Pods
//
//  Created by 纪鹏 on 2017/6/23.
//
//

#import "PicassoModalModule.h"
#import "PicassoHost.h"
#import "PicassoBaseViewController.h"
#import "PicassoDefine.h"
#import "UIView+Layout.h"
#import "PicassoThreadManager.h"

@interface PicassoToastHelper : NSObject

@property (strong, nonatomic) UIView *toastingView;

+ (instancetype)shareInstance;

@end

@implementation PicassoToastHelper

static PicassoToastHelper* _instance = nil;

+ (instancetype)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[PicassoToastHelper alloc] init];
    });
    return _instance;
}

@end

typedef NS_ENUM(NSInteger, PicassoToastPosition) {
    PicassoToastPositionBottom,
    PicassoToastPositionCenter,
    PicassoToastPositionTop
};

@interface PicassoModalModule ()

@property (atomic, strong) NSMutableDictionary *textfieldDic;

@end

@implementation PicassoModalModule

PCS_EXPORT_METHOD(@selector(toast:))
PCS_EXPORT_METHOD(@selector(alert:callback:))
PCS_EXPORT_METHOD(@selector(confirm:callback:))
PCS_EXPORT_METHOD(@selector(prompt:callback:))
PCS_EXPORT_METHOD(@selector(actionSheet:callback:))

- (instancetype)init {
    if (self = [super init]) {
        _textfieldDic = [NSMutableDictionary new];
    }
    return self;
}

static const NSTimeInterval DefaultToastDuration = 2;
- (void)toast:(NSDictionary *)params {
    NSString *msg = params[@"message"];
    NSString *positionStr = params[@"position"];
    PicassoToastPosition position = [self positionFromString:positionStr];
    if (msg.length == 0) {
        return;
    }
    NSTimeInterval duration = [params[@"duration"] doubleValue];
    if (duration <= 0) {
        duration = DefaultToastDuration;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self toast:msg duration:duration position:position];
    });
}

- (PicassoToastPosition)positionFromString:(NSString *)str {
    if (!str) {
        return PicassoToastPositionBottom;
    }
    if ([str isEqualToString:@"center"]) {
        return PicassoToastPositionCenter;
    } else if ([str isEqualToString:@"top"]) {
        return PicassoToastPositionTop;
    } else {
        return PicassoToastPositionBottom;
    }
}

- (void)toast:(NSString *)msg duration:(NSTimeInterval)duration position:(PicassoToastPosition)position {
    UIView *superView =  [[UIApplication sharedApplication] keyWindow];
    UIView *toastView = [self toastViewForMessage:msg superView:superView position:position];
    PicassoToastHelper* toastHelper = [PicassoToastHelper shareInstance];
    if (toastHelper.toastingView) {
        [toastHelper.toastingView removeFromSuperview];
        toastHelper.toastingView = nil;
    }
    [self showToast:toastView superView:superView duration:duration];
}

- (void)showToast:(UIView *)toastView superView:(UIView *)superView duration:(double)duration
{
    if (!toastView || !superView) {
        return;
    }
    
    PicassoToastHelper* toastHelper = [PicassoToastHelper shareInstance];
    toastHelper.toastingView = toastView;
    [superView addSubview:toastView];
    
    __block UIView* blockToastView = toastView;
    
    [UIView animateWithDuration:0.2 delay:duration options:UIViewAnimationOptionCurveEaseInOut animations:^{
        toastView.alpha = 0;
    } completion:^(BOOL finished){
        [toastView removeFromSuperview];
        blockToastView = nil;
    }];
}

- (UIView *)toastViewForMessage:(NSString *)message superView:(UIView *)superView position:(PicassoToastPosition)position
{
    const CGFloat padding = 30;
    const CGFloat toastViewBottom = 80;
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    CGFloat maxWidth = window.width - padding - 20;
    CGFloat maxHeight = window.height - toastViewBottom * 2;
    
    UILabel *messageLabel = [[UILabel alloc] init];
    messageLabel.numberOfLines =  0;
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.text = message;
    messageLabel.font = [UIFont boldSystemFontOfSize:15];
    messageLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    messageLabel.textColor = [UIColor whiteColor];
    messageLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    messageLabel.clipsToBounds = YES;
    messageLabel.layer.cornerRadius = 8;
    messageLabel.width = maxWidth;
    [messageLabel sizeToFit];
    messageLabel.width += padding;
    messageLabel.height += padding;

    messageLabel.width = MIN(messageLabel.width, maxWidth);
    messageLabel.height = MIN(messageLabel.height, maxHeight);
    messageLabel.centerX = window.width / 2;
    switch (position) {
        case PicassoToastPositionBottom:
        {
            messageLabel.bottom = window.height - toastViewBottom;
            break;
        }
        case PicassoToastPositionTop:
        {
            messageLabel.top = toastViewBottom;
            break;
        }
        case PicassoToastPositionCenter:
        {
            messageLabel.centerY = window.height / 2;
            break;
        }
        default:
            break;
    }
    return messageLabel;
}

- (void)alert:(NSDictionary *)params callback:(PicassoCallBack *)callback {
    NSString *title = params[@"title"];
    NSString *message = params[@"message"];
    NSString *okTitle = params[@"okTitle"];
    [self alertWithTitle:title message:message okTitle:(okTitle.length?okTitle:@"确定") cancelTitle:nil needInput:NO placeholder:nil preText:nil callback:callback];
}

- (void)confirm:(NSDictionary *)params callback:(PicassoCallBack *)callback {
    NSString *title = params[@"title"];
    NSString *message = params[@"message"];
    NSString *okTitle = params[@"okTitle"];
    NSString *cancelTitle = params[@"cancelTitle"];
    [self alertWithTitle:title message:message okTitle:(okTitle.length?okTitle:@"确定") cancelTitle:(cancelTitle.length?cancelTitle:@"取消") needInput:NO placeholder:nil  preText:nil callback:callback];
}

- (void)prompt:(NSDictionary *)params callback:(PicassoCallBack *)callback {
    NSString *title = params[@"title"];
    NSString *message = params[@"message"];
    NSString *okTitle = params[@"okTitle"];
    NSString *cancelTitle = params[@"cancelTitle"];
    NSString *placeholder = params[@"placeholder"];
    NSString *preText = params[@"input"];
    [self alertWithTitle:title message:message okTitle:(okTitle.length?okTitle:@"确定") cancelTitle:(cancelTitle.length?cancelTitle:@"取消") needInput:YES placeholder:placeholder preText:preText callback:callback];
}

- (void)alertWithTitle:(NSString *)title message:(NSString *)msg okTitle:(NSString *)okTitle cancelTitle:(NSString *)cancelTitle needInput:(BOOL)needInput placeholder:(NSString *)placeholder preText:(NSString *)preText callback:(PicassoCallBack *)callback{
    PCSRunOnMainThread(^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        if (cancelTitle.length > 0) {
            [alertController addAction:[UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                UITextField *field = [self.textfieldDic objectForKey:[self objectKey:callback]?:@""];
                NSMutableDictionary *resDic = [NSMutableDictionary new];
                [resDic setObject:cancelTitle forKey:@"clicked"];
                if (field) {
                    [resDic setObject:(field.text.length?field.text:@"") forKey:@"input"];
                    [self.textfieldDic removeObjectForKey:([self objectKey:callback]?:@"")];
                }
                [callback sendSuccess:resDic];
            }]];
        }
        if (okTitle.length > 0) {
            [alertController addAction:[UIAlertAction actionWithTitle:okTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                UITextField *field = [self.textfieldDic objectForKey:[self objectKey:callback]?:@""];
                NSMutableDictionary *resDic = [NSMutableDictionary new];
                [resDic setObject:okTitle forKey:@"clicked"];
                if (field) {
                    [resDic setObject:(field.text.length?field.text:@"") forKey:@"input"];
                    [self.textfieldDic removeObjectForKey:([self objectKey:callback]?:@"")];
                }
                [callback sendSuccess:resDic];
            }]];
        }
        if (needInput) {
            [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                if (placeholder.length > 0) {
                    textField.placeholder = placeholder;
                }
                if (preText.length > 0) {
                    textField.text = preText;
                }
                if (callback) {
                    [self.textfieldDic setObject:textField forKey:[self objectKey:callback]];
                }
            }];
        }
        [self.host.pageController presentViewController:alertController animated:YES completion:nil];
    });
}

- (void)actionSheet:(NSDictionary *)params callback:(PicassoCallBack *)callback {
    if (![params isKindOfClass:[NSDictionary class]]) return;
    NSString *title = params[@"title"];
    if ([title isKindOfClass:[NSString class]] && title.length == 0) {
        title = nil;
    }
    NSString *message = params[@"message"];
    NSArray *actionItems = params[@"actionItems"];
    if (![actionItems isKindOfClass:[NSArray class]]) return;
    NSDictionary *cancelItemDic = params[@"cancelItem"];
    
    __weak typeof(self) weakSelf = self;
    PCSRunOnMainThread(^{
        UIAlertController *actionSheetVC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleActionSheet];
        for (NSInteger index = 0; index < actionItems.count; index++) {
            NSDictionary *actionItemDic = actionItems[index];
            if (![actionItemDic isKindOfClass:[NSDictionary class]]) continue;
            NSString *actionTitle = actionItemDic[@"title"];
            UIAlertActionStyle actionStyle = [weakSelf styleForString:actionItemDic[@"style"]];
            UIAlertAction *actionItem = [UIAlertAction actionWithTitle:actionTitle style:actionStyle handler:^(UIAlertAction * _Nonnull action) {
                [callback sendSuccess:@{@"index":@(index)}];
            }];
            [actionSheetVC addAction:actionItem];
        }
        UIAlertAction *cancelItem = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
        if (cancelItemDic && [cancelItemDic isKindOfClass:[NSDictionary class]]) {
            NSString *cancelTitle = cancelItemDic[@"title"];
            cancelItem = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [callback sendSuccess:@{@"index":@(-1)}];
            }];
        }
        [actionSheetVC addAction:cancelItem];

        //  fix iPad bug
        if (actionSheetVC.popoverPresentationController) {
            actionSheetVC.popoverPresentationController.sourceView = [UIApplication sharedApplication].delegate.window;
            actionSheetVC.popoverPresentationController.sourceRect = CGRectMake(CGRectGetWidth([UIApplication sharedApplication].delegate.window.bounds) / 2.0f, CGRectGetHeight([UIApplication sharedApplication].delegate.window.bounds), 1.0f, 1.0f);
        }

        [weakSelf.host.pageController presentViewController:actionSheetVC animated:YES completion:nil];
    });
}

- (UIAlertActionStyle)styleForString:(NSString *)styleStr {
    if ([styleStr isEqualToString:@"default"]) {
        return UIAlertActionStyleDefault;
    } else if ([styleStr isEqualToString:@"destructive"]) {
        return UIAlertActionStyleDestructive;
    } else {
        return UIAlertActionStyleDefault;
    }
}


- (NSValue *)objectKey:(PicassoCallBack *)callback {
    return [NSValue valueWithNonretainedObject:callback];
}

@end

