//
//  NSObject+JSON.m
//  Nova
//
//  Created by dawei on 9/4/14.
//  Copyright (c) 2014 dianping.com. All rights reserved.
//


@implementation NSObject (JSON)
- (NSString *)JSONRepresentation {
    if (![NSJSONSerialization isValidJSONObject:self]) return @"{}";
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:NSJSONReadingAllowFragments | NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        NSLog(@"%@", error);
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}
@end