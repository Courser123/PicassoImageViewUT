//
//  PicassoImageCompat.h
//  ImageViewBase
//
//  Created by Courser on 2018/6/28.
//

#import <Foundation/Foundation.h>

extern dispatch_queue_t crLogQueue(void);

//#define dispatch_async_safe(block)\
//    if (![NSThread isMainThread]) {\
//        block();\
//    } else {\
//        dispatch_async(crLogQueue(), block);\
//    }

#define pcs_log_dispatch_async_safe(block) dispatch_async(crLogQueue(), block);
