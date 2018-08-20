//
//  PicassoScrollView.h
//  clogan
//
//  Created by 纪鹏 on 2017/10/20.
//

#import <UIKit/UIKit.h>

@class PicassoScrollViewModel;

@interface PicassoScrollView : UIScrollView

- (instancetype)initWithModel:(PicassoScrollViewModel *)model;
- (void)updateWithModel:(PicassoScrollViewModel *)model;

@end
