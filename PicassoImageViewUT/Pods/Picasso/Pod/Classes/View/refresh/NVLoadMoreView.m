//
//  NVLoadMoreView.m
//  CocoaAsyncSocket
//
//  Created by 纪鹏 on 2017/6/28.
//

#import "NVLoadMoreView.h"

@interface NVLoadMoreView ()
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) UILabel *retryLabel;
@end

@implementation NVLoadMoreView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self innerInit];
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        [self innerInit];
    }
    return self;
}

- (void)innerInit {
    _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_indicatorView startAnimating];
    [self addSubview:_indicatorView];
    
    _retryLabel = [[UILabel alloc] init];
    _retryLabel.text = @"加载失败，点击重试";
    _retryLabel.font = [UIFont systemFontOfSize:14];
    _retryLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_retryLabel];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(retryClicked)];
    [_retryLabel addGestureRecognizer:tap];
    _retryLabel.userInteractionEnabled = YES;
    
    _indicatorView.hidden = YES;
    _retryLabel.hidden = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.indicatorView.center = self.center;
    self.retryLabel.frame = self.bounds;
}

- (void)setLoadingStatus:(NVLoadingStatus)loadingStatus {
    _loadingStatus = loadingStatus;
    switch (loadingStatus) {
        case NVLoadingStatusNormal:
        case NVLoadingStatusDone:
        {
            self.indicatorView.hidden = NO;
            self.retryLabel.hidden = YES;
            [self.indicatorView stopAnimating];
            break;
        }
        case NVLoadingStatusLoading:
        {
            self.indicatorView.hidden = NO;
            self.retryLabel.hidden = YES;
            [self.indicatorView startAnimating];
            break;
        }
        case NVLoadingStatusFail:
        {
            [self.indicatorView stopAnimating];
            self.indicatorView.hidden = YES;
            self.retryLabel.hidden = NO;
            break;
        }
        default:
            break;
    }
}

- (void)retryClicked {
    if (self.retryBlock) {
        self.retryBlock();
    }
}

@end
