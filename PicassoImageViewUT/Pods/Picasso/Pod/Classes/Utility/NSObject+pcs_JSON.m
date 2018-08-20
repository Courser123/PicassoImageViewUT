//
//  NSObject+pcs_JSON.m
//  Pods
//
//  Created by 纪鹏 on 2018/6/7.
//

#import "NSObject+pcs_JSON.h"

@implementation NSObject (pcs_JSON)

- (NSString *)pcs_JSONRepresentation {
    if (![NSJSONSerialization isValidJSONObject:self]) return @"{}";
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:kNilOptions error:&error];
    if (error) {
        NSLog(@"%@", error);
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}


@end
