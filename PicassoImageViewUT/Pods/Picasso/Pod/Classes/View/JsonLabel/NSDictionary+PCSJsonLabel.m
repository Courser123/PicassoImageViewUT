//
//  NSDictionary+NVJsonLabel.m
//  Nova
//
//  Created by xiebohui on 05/07/2017.
//  Copyright © 2017 xiebohui. All rights reserved.
//

#import "NSDictionary+PCSJsonLabel.h"

@implementation NSDictionary (PCSJsonLabel)

- (id)pcs_objectForKey:(NSString *)key abbreviatedKey:(NSString *)abbreviatedKey {
    return [self objectForKey:abbreviatedKey] ? [self objectForKey:abbreviatedKey] : [self objectForKey:key];
}

@end
