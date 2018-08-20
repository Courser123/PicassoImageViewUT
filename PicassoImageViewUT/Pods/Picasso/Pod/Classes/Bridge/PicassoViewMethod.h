//
//  PicassoViewMethod.h
//  clogan
//
//  Created by 纪鹏 on 2017/10/23.
//

#import <JavaScriptCore/JavaScriptCore.h>

@interface PicassoViewMethod : NSObject

- (instancetype)initWithHostId:(NSString *)hostId viewId:(NSString *)viewId method:(NSString *)methodName arguments:(NSDictionary *)args;
- (void)invoke;

@end
