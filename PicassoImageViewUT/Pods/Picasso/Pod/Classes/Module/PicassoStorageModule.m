//
//  PicassoStorageModule.m
//  Pods
//
//  Created by 纪鹏 on 2017/6/23.
//
//

#import "PicassoStorageModule.h"
#import "PicassoDefine.h"
#import "TMCache.h"

@interface PicassoStorageModule ()
@property (atomic, strong) NSMutableDictionary *cacheDic;
@end

@implementation PicassoStorageModule

PCS_EXPORT_METHOD(@selector(store:))
PCS_EXPORT_METHOD(@selector(retrieve:))
PCS_EXPORT_METHOD(@selector(remove:))
PCS_EXPORT_METHOD(@selector(clear:))

- (instancetype)init {
    if (self = [super init]) {
        _cacheDic = [NSMutableDictionary new];
    }
    return self;
}

- (NSNumber *)store:(NSDictionary *)params {
    NSString *zone = params[@"zone"];
    NSString *key = params[@"key"];
    NSString *value = params[@"value"];
    if (zone.length && key.length && value.length) {
        TMDiskCache *cache = self.cacheDic[zone];
        if (!cache) {
            cache = [[TMDiskCache alloc] initWithName:zone];
            [self.cacheDic setObject:cache forKey:zone];
        }
        [cache setObject:value forKey:key];
        return @(YES);
    }
    return @(NO);
}

- (NSString *)retrieve:(NSDictionary *)params {
    NSString *zone = params[@"zone"];
    NSString *key = params[@"key"];
    if (zone.length && key.length) {
        TMDiskCache *cache = self.cacheDic[zone];
        if (!cache) {
            cache = [[TMDiskCache alloc] initWithName:zone];
        }
        NSString *value =  (NSString *)[cache objectForKey:key];
        return value?:@"";
    }
    return @"";
}

- (void)remove:(NSDictionary *)params {
    NSString *zone = params[@"zone"];
    NSString *key = params[@"key"];
    if (zone.length && key.length) {
        TMDiskCache *cache = self.cacheDic[zone];
        [cache removeObjectForKey:key];
    }
}

- (void)clear:(NSDictionary *)params {
    NSString *zone = params[@"zone"];
    if (zone.length) {
        TMDiskCache *cache = self.cacheDic[zone];
        [cache removeAllObjects];
        [self.cacheDic removeObjectForKey:zone];
    }
}

@end
