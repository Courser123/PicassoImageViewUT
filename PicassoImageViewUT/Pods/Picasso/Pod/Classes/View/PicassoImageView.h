//
//  PicassoImageView.h
//  clogan
//
//  Created by 纪鹏 on 2017/10/19.
//

#import "PicassoBaseImageView.h"

@class PicassoImageViewModel;

@interface PicassoImageView : PicassoBaseImageView

- (void)updateWithModel:(PicassoImageViewModel *)model;

@end
