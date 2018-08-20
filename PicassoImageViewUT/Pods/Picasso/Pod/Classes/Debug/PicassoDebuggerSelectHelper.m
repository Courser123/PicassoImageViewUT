//
//  PicassoDebuggerSelectHelper.m
//  clogan
//
//  Created by 钱泽虹 on 2018/5/8.
//

#import "PicassoDebuggerSelectHelper.h"

NSString *const NSNotificationVSCodeDebuggerOpen = @"NSNotificationVSCodeDebuggerOpen";
NSString *const NSNotificationVSCodeDebuggerClose = @"NSNotificationVSCodeDebuggerClose";

@interface PicassoDebuggerSelectHelper()<UIActionSheetDelegate>
@property (nonatomic, strong) UIActionSheet *actionSheet;
@end

@implementation PicassoDebuggerSelectHelper

+ (instancetype)helper {
    static PicassoDebuggerSelectHelper *instance = nil;
    if (instance == nil) {
        instance = [[PicassoDebuggerSelectHelper alloc] init];
    }
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _serverIP = [[NSString alloc] init];
    }
    return self;
}

- (void)selectViewShow {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [self.actionSheet showInView:keyWindow];
}

- (void)selectViewDismiss {
    [self.actionSheet removeFromSuperview];
    self.actionSheet = nil;
}

- (void)changeDebuggerStatus {
    if (self.isDebuggerOn) {
        self.isDebuggerOn = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:NSNotificationVSCodeDebuggerClose object:nil];
    } else {
        self.isDebuggerOn = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:NSNotificationVSCodeDebuggerOpen object:nil];
    }
}

- (UIActionSheet *)actionSheet {
    if (!_actionSheet) {
        _actionSheet = [[UIActionSheet alloc] initWithTitle:@"JS调试选项" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"打开",@"关闭", nil];
    }
    return _actionSheet;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NSNotificationVSCodeDebuggerOpen object:nil];
        [self selectViewDismiss];
    } else if(buttonIndex == 1) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NSNotificationVSCodeDebuggerClose object:nil];
        [self selectViewDismiss];
    } else {
        [self selectViewDismiss];
    }
}

@end
