//
//  PicassoGroupViewWrapper.h
//  clogan
//
//  Created by 纪鹏 on 2017/10/19.
//

#import "PicassoBaseViewWrapper.h"

@interface PicassoGroupViewWrapper : PicassoBaseViewWrapper

+ (void)updateViewWithoutSubviewUpdate:(UIView *)view withModel:(PicassoModel *)model inPicassoView:(PicassoView *)picassoView;

@end
