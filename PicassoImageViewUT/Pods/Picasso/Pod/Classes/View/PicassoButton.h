//
//  PicassoButton.h
//  clogan
//
//  Created by 纪鹏 on 2017/10/19.
//

#import <UIKit/UIKit.h>

@class PicassoView;
@class PicassoButtonModel;
@interface PicassoButton : UIButton

- (void)updateViewWithModel:(PicassoButtonModel *)model inPicassoView:(PicassoView *)picassoView;

@end
