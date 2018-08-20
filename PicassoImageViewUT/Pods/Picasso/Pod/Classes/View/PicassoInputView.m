//
//  PicassoInputView.m
//  Pods
//
//  Created by game3108 on 2017/9/19.
//
//

#import "PicassoInputView.h"
#import "PicassoInputViewModel.h"
#import "PicassoVCHost.h"
#import "PicassoHostManager.h"
#import "PicassoView.h"
#import "PicassoTextView.h"
#import "UIView+Layout.h"

typedef NS_ENUM(NSInteger, InputType) {
    InputTypeDefault,
    InputTypeNumber,
    InputTypeASCII,
    InputTypePhonePad
};

typedef NS_ENUM(NSInteger, ReturnAction) {
    ReturnActionDefault = -1,
    ReturnActionDone,
    ReturnActionSearch,
    ReturnActionNext,
    ReturnActionGo,
    ReturnActionSend
};

typedef NS_ENUM(NSInteger, InputAlignment) {
    InputAlignmentLeft,
    InputAlignmentRight,
    InputAlignmentCenter,
};

static NSString *ACTION_TEXT_CHANGE = @"onTextChange";
static NSString *ACTION_ON_FOCUS = @"onFocus";
static NSString *ACTION_ON_RETURN_DONE = @"onReturnDone";

@interface PicassoInputView()<UITextViewDelegate, UITextFieldDelegate>
@property (nonatomic, assign) BOOL multiline;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) PicassoTextView *textView;
@property (nonatomic, weak) PicassoView *picassoView;
@property (nonatomic, assign) BOOL hasTextChangeAction;
@property (nonatomic, assign) BOOL hasOnFocusAction;
@property (nonatomic, strong) PicassoInputViewModel *model;
@property (nonatomic, assign) CGFloat keyboardHeight;
@property (nonatomic, assign) CGFloat keyboardExtraHeight;
@property (nonatomic, assign) CGFloat originTop;
@property (nonatomic, assign) CGFloat editingOffset;
@property (nonatomic, assign) BOOL isOnAnimation;
@property (nonatomic, assign) BOOL isKeyboardHasOffset;
@property (nonatomic, assign) BOOL hasOnReturnDone;
@end

@implementation PicassoInputView

#pragma mark - public method
- (instancetype)initWithModel:(PicassoInputViewModel *)model {
    self = [super init];
    if (self) {
        self.keyboardHeight = 216.0f;
        self.multiline = model.multiline;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        if (self.multiline) {
            PicassoTextView *textView = [[PicassoTextView alloc] init];
            textView.inputAccessoryView = [self getToolbar];
            self.textView = textView;
            [self addSubview:textView];
        } else {
            UITextField * textField = [[UITextField alloc] init];
            textField.inputAccessoryView = [self getToolbar];
            textField.delegate = self;
            self.textField = textField;
            [self addSubview:textField];

            if ([UIDevice currentDevice].systemVersion.floatValue < 9.0) {
                //  fix iOS 8 系统输入联想bug
                [textField addTarget:self action:@selector(textFieldDidChanged:) forControlEvents:UIControlEventEditingChanged];
            }
        }
    }
    return self;
}

- (void)updateViewWithModel:(PicassoInputViewModel *)model inPicassoView:(PicassoView *)picassoView {
    self.isOnAnimation = NO;
    self.model = model;
    self.picassoView = picassoView;
    UIView<UITextInputTraits> *inputView = nil;
    if (self.multiline) {
        PicassoTextView *textView = self.textView;
        inputView = textView;
        textView.delegate = self;
        textView.placeholder = model.hint;
        textView.placeholderColor = model.hintColor;
        textView.textColor = model.textColor;
        textView.font = model.font;
        
        if (model.inputAlignment == InputAlignmentRight) {
            textView.textAlignment = NSTextAlignmentRight;
        } else if(model.inputAlignment == InputAlignmentLeft){
            textView.textAlignment = NSTextAlignmentLeft;
        } else if(model.inputAlignment == InputAlignmentCenter){
            textView.textAlignment = NSTextAlignmentCenter;
        }
        
        if (model.text) {
            textView.text = model.text;
        }
    } else {
        UITextField *textField = self.textField;
        inputView = textField;
        textField.placeholder = model.hint;
        [textField setValue:model.hintColor forKeyPath:@"_placeholderLabel.textColor"];
        [textField setValue:model.font forKeyPath:@"_placeholderLabel.font"];
        textField.textColor = model.textColor;
        textField.font = model.font;
        if (model.text) {
            textField.text = model.text;
        }

        if (model.inputAlignment == InputAlignmentRight) {
            textField.textAlignment = NSTextAlignmentRight;
        } else if(model.inputAlignment == InputAlignmentLeft){
            textField.textAlignment = NSTextAlignmentLeft;
        } else if(model.inputAlignment == InputAlignmentCenter){
            textField.textAlignment = NSTextAlignmentCenter;
        }
    }
    inputView.backgroundColor = [UIColor clearColor];
    inputView.frame = self.bounds;
    switch (model.inputType) {
            case InputTypeDefault:
            inputView.keyboardType = UIKeyboardTypeDefault;
            break;
            case InputTypeNumber:
            inputView.keyboardType = UIKeyboardTypeNumberPad;
            break;
            case InputTypeASCII:
            inputView.keyboardType = UIKeyboardTypeASCIICapable;
            break;
            case InputTypePhonePad:
            inputView.keyboardType = UIKeyboardTypePhonePad;
            break;
        default:
            break;
    }
    inputView.secureTextEntry = model.secureTextEntry;
    UIReturnKeyType keyType = UIReturnKeyDefault;
    switch (model.returnAction) {
            case ReturnActionDone:
            keyType = UIReturnKeyDone;
            break;
            case ReturnActionSearch:
            keyType = UIReturnKeySearch;
            break;
            case ReturnActionNext:
            keyType = UIReturnKeyNext;
            break;
            case ReturnActionGo:
            keyType = UIReturnKeyGo;
            break;
            case ReturnActionSend:
            keyType = UIReturnKeySend;
            break;
        default:
            break;
    }
    inputView.returnKeyType = keyType;
    if (model.autoFocus) {
        [inputView becomeFirstResponder];
    }
    
    [self handleActions:model.actions];
}

- (UIView <UITextInput> *)inputInstanceView {
    return self.multiline ? self.textView : self.textField;
}

#pragma mark - life cycle

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - private method

- (void)handleActions:(NSArray *)actions {
    self.hasTextChangeAction = NO;
    self.hasOnFocusAction = NO;
    self.hasOnReturnDone = NO;
    for (NSString *action in actions) {
        if ([action isEqualToString:ACTION_TEXT_CHANGE]) {
            self.hasTextChangeAction = YES;
        } else if ([action isEqualToString:ACTION_ON_FOCUS]) {
            self.hasOnFocusAction = YES;
        } else if ([action isEqualToString:ACTION_ON_RETURN_DONE]) {
            self.hasOnReturnDone = YES;
        }
    }
}

- (UIToolbar *)getToolbar {
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, [[UIApplication sharedApplication].delegate window].frame.size.width, 30)];
    toolbar.barStyle = UIBarStyleDefault;
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *bar = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(toolbarComplete)];
    toolbar.items = @[space, bar];
    [toolbar sizeToFit];
    return toolbar;
}


- (void)sendTextChangeMessage:(NSString *)text {
    if (!self.hasTextChangeAction) {
        return;
    }
    
    [self dispatchVCAction:ACTION_TEXT_CHANGE params:@{@"newStr":text?:@""}];
}

- (void)sendOnFocusMessage: (BOOL)isFocus {
    if (!self.hasOnFocusAction) {
        return;
    }
    [self dispatchVCAction:ACTION_ON_FOCUS params:@{@"isFocus":@(isFocus)}];
}

- (void)dispatchVCAction:(NSString *)action params:(NSDictionary *)params {
    PicassoHost *host = [PicassoHostManager hostForId:self.model.hostId];
    if (![host isKindOfClass:[PicassoVCHost class]]) {
        return;
    }
    PicassoVCHost *vcHost = (PicassoVCHost *)host;
    [vcHost dispatchViewEventWithViewId:self.model.viewId action:action params:params];
}

- (CGFloat)getOffset:(UIView *)view {
    UIView *windowView = [[UIApplication sharedApplication].delegate window];
    CGRect viewFrame = [view.superview convertRect:view.frame toView:windowView];
    return (viewFrame.origin.y + viewFrame.size.height) - (windowView.frame.size.height - self.keyboardHeight);
}

- (void)didBeginEditing:(UIView *)view {
    if (YES == self.model.autoAdjust) {
        self.isOnAnimation = YES;
        self.originTop = self.picassoView.top;

        CGFloat offset = [self getOffset:view];
        if (offset <= 0) {
            self.isKeyboardHasOffset = NO;
            return;
        }
        self.editingOffset = offset;
        self.isKeyboardHasOffset = YES;
        [UIView animateWithDuration:0.3 animations:^{
            self.picassoView.top = self.originTop - offset;
        } completion:^(BOOL finished) {
            //pcsView可能会有top的变化，必须判断
            if (self.picassoView.top != self.originTop - offset) {
                self.originTop = self.picassoView.top;
            }
            self.picassoView.top = self.originTop - offset - self.keyboardExtraHeight;
            self.isOnAnimation = NO;
        }];
    }
    [self sendOnFocusMessage:true];
}

- (void)didEndEditing:(UIView *)view {
    if (YES == self.model.autoAdjust) {
        //pcsView可能会有top的变化，必须判断
        if (self.isKeyboardHasOffset && (self.originTop ==  self.picassoView.top + self.editingOffset + self.keyboardExtraHeight)) {
            self.picassoView.top = self.originTop;
        }
        self.keyboardExtraHeight = 0;
        self.isKeyboardHasOffset = NO;
    }
    [self sendOnFocusMessage:false];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    [self sendTextChangeMessage:textView.text];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self didBeginEditing:textView];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [self didEndEditing:textView];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)string {

    if (YES == self.hasOnReturnDone && [string isEqualToString:@"\n"] && self.model.returnAction != ReturnActionDefault) {
        [self dispatchVCAction:ACTION_ON_RETURN_DONE params:nil];
    }

    if (self.model.maxLength > 0) {
        // Prevent crashing undo bug – see note below.
        if(range.length + range.location > textView.text.length) {
            return NO;
        }
        
        NSUInteger newLength = [textView.text length] + [string length] - range.length;
        return newLength <= self.model.maxLength;
    }
    
    return YES;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self didBeginEditing:textField];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self didEndEditing:textField];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if (YES == self.hasOnReturnDone) {
        [self dispatchVCAction:ACTION_ON_RETURN_DONE params:nil];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([UIDevice currentDevice].systemVersion.floatValue >= 9.0f) {
        [self sendTextChangeMessage:[textField.text stringByReplacingCharactersInRange:range withString:string]];
    }
    
    if (self.model.maxLength > 0) {
        // Prevent crashing undo bug – see note below.
        if(range.length + range.location > textField.text.length) {
            return NO;
        }
        
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        return newLength <= self.model.maxLength;
    }
    
    return YES;
}

//  iOS 9.0 以下系统，才会走该方法
- (void)textFieldDidChanged:(UITextField *)textField
{
    [self sendTextChangeMessage:textField.text];
}

#pragma mark - action target

- (void)toolbarComplete {
    if (self.multiline) {
        [self.textView resignFirstResponder];
    } else {
        [self.textField resignFirstResponder];
    }
}
#pragma mark - Notification

- (void)keyboardWillShow:(NSNotification *)notification {
    if (YES == self.model.autoAdjust) {
        NSDictionary *info = [notification userInfo];
        CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;

        self.keyboardExtraHeight = 0;
        if (self.isOnAnimation) {
            self.keyboardExtraHeight = kbSize.height - self.keyboardHeight;
        }
        self.keyboardHeight = kbSize.height;
    }
}

@end

