//
//  LoganEnviroment.m
//  clogan
//
//  Created by M 小军 on 2017/12/5.
//

#import "LoganEnvironment.h"

@implementation LoganEnvironment
- (void)setEnvironment:(enumKeyValueBlock)block{
    if(_userId.length){
        block(@"userid",_userId);
    }
    if(_unionId.length){
        block(@"unionid",_unionId);
    }
    if(_pushToken.length){
        block(@"pushtoken",_pushToken);
    }
    if(_additionalInfo && [_additionalInfo isKindOfClass:[NSDictionary class]]){
        block(@"tag",_additionalInfo);
    }
}
- (NSString *)getEnvironmentString{
    NSMutableDictionary *envDic = @{}.mutableCopy;
    [self setEnvironment:^(NSString *key, id value) {
            envDic[key] = value;
        }];
    NSError *err = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:envDic options:NSJSONWritingPrettyPrinted error:&err];
    NSString *env = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return env;
}
@end
