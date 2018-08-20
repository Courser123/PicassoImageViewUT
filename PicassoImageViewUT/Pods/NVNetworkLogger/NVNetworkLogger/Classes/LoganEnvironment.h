//
//  LoganEnviroment.h
//  clogan
//
//  Created by M 小军 on 2017/12/5.
//

#import <Foundation/Foundation.h>
typedef void(^enumKeyValueBlock)(NSString *key,id value);
@interface LoganEnvironment : NSObject
@property(nonatomic,copy)NSString *unionId;
@property(nonatomic,copy)NSString *pushToken;
@property(nonatomic,copy)NSString *userId;
@property(nonatomic,strong)NSDictionary *additionalInfo;
- (NSString *)getEnvironmentString;
@end
