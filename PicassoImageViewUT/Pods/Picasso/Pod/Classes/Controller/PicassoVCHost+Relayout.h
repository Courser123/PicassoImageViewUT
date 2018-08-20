//
//  PicassoVCHost+Relayout.h
//  Pods
//
//  Created by 纪鹏 on 2018/6/26.
//

#import "PicassoVCHost.h"

@interface PicassoVCHost ()

- (void)checkRelayoutForModel:(PicassoModel *)model;
- (BOOL)needRelayout;
- (void)flushSizeCache;

@end
