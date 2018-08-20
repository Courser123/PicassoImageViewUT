//
//  PicassoRenderUtils.h
//  clogan
//
//  Created by 纪鹏 on 2017/10/20.
//

#import <Foundation/Foundation.h>

@class PicassoView;
@class PicassoModel;
@class PicassoVCHost;

@interface PicassoRenderUtils : NSObject

+ (void)addViewInPicassoView:(PicassoView *)picassoView withModel:(PicassoModel *)model rootView:(UIView *)rootView index:(NSInteger)index;

+ (void)updateViewTreeInPicassoView:(PicassoView *)picassoView withModel:(PicassoModel *)model rootView:(UIView *)rootView;

@end
