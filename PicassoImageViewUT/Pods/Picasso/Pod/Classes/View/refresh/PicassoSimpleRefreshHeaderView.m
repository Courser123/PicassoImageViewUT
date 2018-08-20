//
//  NVSimpleRefreshHeaderView.m
//  Pods
//
//  Created by 纪鹏 on 15/7/16.
//
//

#import "PicassoSimpleRefreshHeaderView.h"
#import "UIView+Layout.h"

@interface PicassoSimpleRefreshHeaderView ()

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@end

@implementation PicassoSimpleRefreshHeaderView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicatorView.hidesWhenStopped = false;
        [_indicatorView sizeToFit];
        _indicatorView.centerX = self.width / 2;
        _indicatorView.bottom = self.height - [self maxBottomOffset];
        [self addSubview:_indicatorView];
    }
    return self;
}

- (CGFloat)maxBottomOffset {
    return 20.0;
}

- (void)setViewWithYOffset:(CGFloat)offset isDragging:(BOOL)isDragging {
//Todo:add animations
}

- (void)setState:(PicassoPullRefrshState)state {
    switch (state) {
        case PicassoPullRefrshStateNone:
        {
            [self.indicatorView stopAnimating];
            break;
        }
        case PicassoPullRefrshStateDragging:
        {
            break;
        }
        case PicassoPullRefrshStateLoading:
        {
            [self.indicatorView startAnimating];
            break;
        }
        default:
            break;
    }

}


@end
