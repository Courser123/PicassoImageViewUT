//
//  PicassoCrashReporter.h
//  Picasso
//
//  Created by 纪鹏 on 2018/5/10.
//

#import <Foundation/Foundation.h>

@class JSValue;
@interface PicassoCrashReporter : NSObject

+ (PicassoCrashReporter *)instance;
- (void)reportCrashWithException:(JSValue *)exception jsContent:(NSString *)jsContent jsname:(NSString *)jsname status:(NSString *)status;

@end
