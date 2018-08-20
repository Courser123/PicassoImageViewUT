//
//  UIView+Picasso.m
//  Picasso
//
//  Created by xiebohui on 28/11/2016.
//  Copyright © 2016 xiebohui. All rights reserved.
//

#import "UIView+Picasso.h"
#import <objc/runtime.h>

static const void *PicassoViewWrapperClz = &PicassoViewWrapperClz;
static const void *PicassoViewTag = &PicassoViewTag;
//static const void *PicassoViewWrapper = &PicassoViewWrapper;
static const void *PicassoViewId = &PicassoViewId;
static const void *PicassoBindModel = &PicassoBindModel;

//typedef void (^DeallocBlock)();
//@interface OriginalObject : NSObject
//@property (nonatomic, copy) DeallocBlock block;
//- (instancetype)initWithBlock:(DeallocBlock)block;
//@end
//
//@implementation OriginalObject
//
//- (instancetype)initWithBlock:(DeallocBlock)block
//{
//    self = [super init];
//    if (self) {
//        self.block = block;
//    }
//    return self;
//}
//- (void)dealloc {
//    self.block ? self.block() : nil;
//}
//@end

@implementation UIView (Picasso)

- (NSString *)wrapperClz {
    return objc_getAssociatedObject(self, PicassoViewWrapperClz);
}

- (void)setWrapperClz:(NSString *)wrapperClz {
    objc_setAssociatedObject(self, PicassoViewWrapperClz, wrapperClz, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)p_tag {
    return objc_getAssociatedObject(self, PicassoViewTag);
}

- (void)setP_tag:(NSString *)p_tag {
    objc_setAssociatedObject(self, PicassoViewTag, p_tag, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)viewId {
    return objc_getAssociatedObject(self, PicassoViewId);
}

- (void)setViewId:(NSString *)viewId {
    objc_setAssociatedObject(self, PicassoViewId, viewId, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (PicassoModel *)pModel {
    return objc_getAssociatedObject(self, PicassoBindModel);
}

- (void)setPModel:(PicassoModel *)pModel {
    objc_setAssociatedObject(self, PicassoBindModel, pModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

}

//- (PicassoBaseViewWrapper *)wrapper {
//    return objc_getAssociatedObject(self, PicassoViewWrapper);
//}
//
//- (void)setWrapper:(PicassoBaseViewWrapper *)wrapper {
//    OriginalObject *ob = [[OriginalObject alloc] initWithBlock:^{
//        objc_setAssociatedObject(self, PicassoViewWrapper, nil, OBJC_ASSOCIATION_ASSIGN);
//    }];
//    // 给需要被 assign 修饰的对象添加一个 strong 对象.
//    objc_setAssociatedObject(wrapper, (__bridge const void *)(ob.block), ob, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//    objc_setAssociatedObject(self, PicassoViewWrapper, wrapper, OBJC_ASSOCIATION_ASSIGN);
//}

@end
