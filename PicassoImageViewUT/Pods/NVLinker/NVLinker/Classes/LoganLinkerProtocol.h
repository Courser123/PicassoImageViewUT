//
//  LoganLinkerProtocol.h
//  NVLinker
//
//  Created by xiangnan.yang on 2018/6/29.
//


#ifndef LoganLinkerProtocol_h
#define LoganLinkerProtocol_h

#define LoganLinkerCalssString @"Logan"

@protocol LoganLinkerProtocol <NSObject>

- (void)LLog:(NSString *)log
        type:(NSUInteger)type;

- (void)LLog:(NSString *)log
        type:(NSUInteger)type
        tags:(NSArray<NSString *> *)tags;

@end

#endif /* LoganLinkerProtocol_h */
