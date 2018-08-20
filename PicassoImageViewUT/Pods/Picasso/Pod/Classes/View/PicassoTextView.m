//
//  PicassoTextView.m
//  clogan
//
//  Created by game3108 on 2017/10/23.
//

#import "PicassoTextView.h"

@interface PicassoTextView()

@property (nonatomic, assign) BOOL showPlaceHolder;

@end

@implementation PicassoTextView

#pragma mark - life cycles

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [super setFont:[UIFont systemFontOfSize:14.0]];
        [super setContentMode:UIViewContentModeRedraw];
        [super setContentInset:UIEdgeInsetsZero];
        [super setTextContainerInset:UIEdgeInsetsZero];
        [super setShowsHorizontalScrollIndicator:NO];
        _showPlaceHolder = YES;
        self.layoutManager.allowsNonContiguousLayout = NO;
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UITextViewTextDidChangeNotification
                                                      object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textDidChange:)
                                                     name:UITextViewTextDidChangeNotification
                                                   object:nil];
        
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextViewTextDidChangeNotification
                                                  object:nil];
}

#pragma mark - kvo & notification

- (void)textDidChange:(NSNotification *)aNotification {
    BOOL wasDisplayingPlaceholder = self.showPlaceHolder;
    self.showPlaceHolder = self.text.length == 0;
    if (wasDisplayingPlaceholder != self.showPlaceHolder) {
        [self setNeedsDisplay];
    }
}

#pragma override methods

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    if (!self.font) return;
    if (self.showPlaceHolder && self.placeholder.length) {
        NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
        style.alignment = self.textAlignment;
        style.lineBreakMode = NSLineBreakByTruncatingTail;
        CGFloat leftPadding = 5;
        [self.placeholder drawInRect:CGRectMake(leftPadding, self.textContainerInset.top + self.contentInset.top, self.frame.size.width - leftPadding * 2, self.font.lineHeight)
                      withAttributes:@{
                                       NSFontAttributeName:self.font,
                                       NSForegroundColorAttributeName:self.placeholderColor?:[UIColor colorWithRed:(193.0/255.0) green:(193.0/255.0) blue:(193.0/255.0) alpha:1.0],
                                       NSParagraphStyleAttributeName:style
                                       }];
    }
}

#pragma mark - caculate height

- (CGFloat)measureHeight {
    return ceilf([self sizeThatFits:self.frame.size].height);
}

#pragma mark - property methods

- (void)setText:(NSString *)text {
    [super setText:text];
    [self performSelector:@selector(textDidChange:) withObject:nil];
}

- (void)setPlaceholder:(NSString *)placeholder
{
    _placeholder = placeholder;
    [self setNeedsDisplay];
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor {
    if (_placeholderColor == placeholderColor) return;
    _placeholderColor = placeholderColor;
    [self setNeedsDisplay];
}

@end
