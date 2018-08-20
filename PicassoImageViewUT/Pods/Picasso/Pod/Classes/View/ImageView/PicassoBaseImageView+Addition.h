//
//  PicassoBaseImageView+Addition.h
//  ImageViewBase
//
//  Created by welson on 2018/3/2.
//

#import "PicassoBaseImageView.h"

@interface PicassoBaseImageView (Addition)

@property (nonatomic, assign) NSTimeInterval fadeEffectionDuration;

/**
 *  用户自定义的加载视图
 *  与loadingImage的优先级是采用最后设置生效原则
 */
@property (nonatomic, strong) UIView *placeHolderView;

@end
