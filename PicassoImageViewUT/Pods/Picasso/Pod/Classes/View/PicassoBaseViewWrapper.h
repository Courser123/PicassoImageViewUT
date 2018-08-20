//
//  PicassoBaseView.h
//  Pods
//
//  Created by 纪鹏 on 2017/6/5.
//
//

#import <Foundation/Foundation.h>
@class PicassoModel;
@class PicassoView;


@interface PicassoBaseViewWrapper : NSObject

+ (UIView *)createViewWithModel:(PicassoModel *)model inPicassoView:(PicassoView *)picassoView;

+ (void)updateView:(UIView *)view withModel:(PicassoModel *)model inPicassoView:(PicassoView *)picassoView;

+ (Class)modelClass;

+ (Class)viewClass;

@end
