//
//  PicassoDebuggerSelectHelper.h
//  clogan
//
//  Created by 钱泽虹 on 2018/5/8.
//

#import <Foundation/Foundation.h>

extern NSString *const NSNotificationVSCodeDebuggerOpen;
extern NSString *const NSNotificationVSCodeDebuggerClose;

@interface PicassoDebuggerSelectHelper : NSObject

@property (nonatomic, assign) BOOL isDebuggerOn;
@property (nonatomic, strong) NSString *serverIP;

+ (instancetype)helper;
- (void)selectViewShow;
- (void)changeDebuggerStatus;
@end
