//
//  PicassoGroupView.h
//  clogan
//
//  Created by 纪鹏 on 2017/10/19.
//

#import <UIKit/UIKit.h>

@class PicassoViewModel;
@class PicassoView;
@interface PicassoGroupView : UIView

- (void)updateWithModel:(PicassoViewModel *)model inPicassoView:(PicassoView *)pcsView;

@end
