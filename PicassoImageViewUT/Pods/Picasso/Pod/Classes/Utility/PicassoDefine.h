//
//  PicassoDefine.h
//  Pods
//
//  Created by 纪鹏 on 2017/5/11.
//
//

#ifndef PicassoDefine_h
#define PicassoDefine_h

#define PCS_CONCAT2(a, b) a ## b
#define PCS_CONCAT(a, b) PCS_CONCAT2(a, b)

#define PCS_EXPORT_METHOD_INTERNAL(token, method) \
+ (NSString *)PCS_CONCAT(token, __LINE__) { \
    return NSStringFromSelector(method); \
}

#define PCS_EXPORT_METHOD(method) PCS_EXPORT_METHOD_INTERNAL(pcs_export_method_, method)


#define PCS_BRIDGE_THREAD_NAME @"com.dianping.picasso.bridge"
#define PCS_VIEW_COMPUTE_THREAD_NAME @"com.dianping.picasso.viewcompute"

#define PCSAssertBridgeThread() \
NSAssert([[NSThread currentThread].name isEqualToString:PCS_BRIDGE_THREAD_NAME], \
@"function must be called on bridge thread, call PCSRunOnBridgeThread()")

#define PCSAssertViewComputeThread() \
NSAssert([[NSThread currentThread].name isEqualToString:PCS_VIEW_COMPUTE_THREAD_NAME], \
@"function must be called on view compute thread, call PCSRunOnViewComputeThread()")


#define PCSAssertMainThread() \
NSAssert([NSThread isMainThread], \
@"function must be called on main thread")


#endif /* PicassoDefine_h */
