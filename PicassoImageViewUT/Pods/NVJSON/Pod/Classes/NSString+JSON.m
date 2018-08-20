//
//  NSString+JSON.m
//  Nova
//
//  Created by dawei on 4/28/15.
//  Copyright (c) 2015 dianping.com. All rights reserved.
//


@implementation NSString (JSON)
- (id)JSONValue {
    if (self.length == 0) return @{};
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    if (!data) return nil;
    NSError *error = nil;
    id obj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    if (error) {
        NSLog(@"%@", error);
        return nil;
    }
    return obj;
}
@end
