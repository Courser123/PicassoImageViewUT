//
//  PicassoActivityIndicatorViewModel.h
//  clogan
//
//  Created by 纪鹏 on 2017/10/25.
//

#import "PicassoModel.h"

@interface PicassoActivityIndicatorViewModel : PicassoModel

@property (nonatomic, assign) BOOL animating;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, assign) NSInteger style;

@end
