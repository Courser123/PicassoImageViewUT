//
//  PicassoVCHost+VCView.m
//  Pods
//
//  Created by 纪鹏 on 2017/12/20.
//

#import "PicassoVCHost+VCView.h"
#import <objc/runtime.h>

static const void *PicassoMsgBlockKey = &PicassoMsgBlockKey;

@implementation PicassoVCHost (VCView)

- (void)setMsgBlock:(PicassoMsgReceiveBlock)msgBlock {
    objc_setAssociatedObject(self, PicassoMsgBlockKey, msgBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (PicassoMsgReceiveBlock)msgBlock {
    return objc_getAssociatedObject(self, PicassoMsgBlockKey);
}

@end
