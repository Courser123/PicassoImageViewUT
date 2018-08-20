//
//  LoganDataProcess.h
//  Pods
//
//  Created by yxn on 2017/5/23.
//
//

#import <Foundation/Foundation.h>

@interface LoganDataProcess : NSObject

+ (instancetype)sharedInstance;
- (void)initAndOpenCLib;
- (NSData *)processData:(NSString *)data;

@end
