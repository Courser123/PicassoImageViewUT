//
//  NSData+GzipHelper.h
//  MonitorDemo
//
//  Created by yxn on 16/9/1.
//  Copyright © 2016年 dianping. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (mcGzipHelper)

- (NSData *)mcDecodeGZip;
- (NSData *)mcEncodeGZip;

@end
