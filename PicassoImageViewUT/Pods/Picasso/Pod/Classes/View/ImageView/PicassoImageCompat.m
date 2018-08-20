//
//  PicassoImageCompat.m
//  ImageViewBase
//
//  Created by Courser on 2018/6/28.
//

#import "PicassoImageCompat.h"

inline dispatch_queue_t crLogQueue(void) {
    static dispatch_queue_t crLogQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        crLogQueue = dispatch_queue_create("logQueue", DISPATCH_QUEUE_SERIAL);
//        dispatch_queue_t targetQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
//        dispatch_set_target_queue(crLogQueue, targetQueue);
    });
    return crLogQueue;
}

