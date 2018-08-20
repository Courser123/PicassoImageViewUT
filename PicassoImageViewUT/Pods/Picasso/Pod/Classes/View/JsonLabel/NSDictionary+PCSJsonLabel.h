//
//  NSDictionary+NVJsonLabel.h
//  Nova
//
//  Created by xiebohui on 05/07/2017.
//  Copyright © 2017 xiebohui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (PCSJsonLabel)

- (id)pcs_objectForKey:(NSString *)key abbreviatedKey:(NSString *)abbreviatedKey;

@end
