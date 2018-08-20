//
//  PicassoLabel.h
//  clogan
//
//  Created by 纪鹏 on 2017/10/19.
//

#import "PCSJsonLabel.h"

@class PicassoLabelModel;

@interface PicassoLabel : PCSJsonLabel

- (void)updateWithModel:(PicassoLabelModel *)model;

@end
