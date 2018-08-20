//
//  PicassoVCHost+LayoutFinished.h
//  Pods
//
//  Created by 纪鹏 on 2018/5/30.
//

#import "PicassoVCHost.h"

typedef void(^PicassoLayoutFinishBlock)();

@interface PicassoVCHost ()

@property (nonatomic, copy) PicassoLayoutFinishBlock layoutFinishBlock;

@end
