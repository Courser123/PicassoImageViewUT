//
//  MTDPDNSResolution.h
//  NVReachability
//
//  Created by xiangnan.yang on 2017/12/19.
//

#import <Foundation/Foundation.h>

@interface MTDPDNSResolution : NSObject

+ (NSArray *)syncResoluteWithHost:(NSString *)hostName;
//- (void)asyncResoluteWithHost:(NSString *)hostName callBack:(void (^)(NSString *result))block;

@end
