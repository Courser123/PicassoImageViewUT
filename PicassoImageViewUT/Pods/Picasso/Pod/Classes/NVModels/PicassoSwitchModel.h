//
//  PicassoSwitchModel.h
//  Picasso
//
//  Created by pengfei.zhou on 2018/4/26.
//

#import "PicassoModel.h"

@interface PicassoSwitchModel : PicassoModel

/** 开关状态*/
@property (nonatomic, assign) BOOL on;

/** 开关处于关闭状态时的颜色*/
@property (nonatomic,strong) UIColor *tintColor;

/** 开关处于开启状态时的颜色*/
@property (nonatomic,strong) UIColor *onTintColor;

/** 开关的状态钮颜色*/
@property (nonatomic,strong) UIColor *thumbTintColor;

@end
