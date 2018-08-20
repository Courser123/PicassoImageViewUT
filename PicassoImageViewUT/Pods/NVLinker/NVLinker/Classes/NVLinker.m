//
//  NVLinker.m
//  NVLinker
//
//  Created by JiangTeng on 2018/2/27.
//

#import "NVLinker.h"

BOOL hasSharkLinker() {
    return sharkLinker() == nil? NO : YES;
}

id<SharkLinkerProtocol> sharkLinker() {
    static id sharkInstance = nil;
    static  dispatch_once_t pred;
    dispatch_once(&pred, ^{
        Class aClass = NSClassFromString(SharkLinkerCalssString);
        id instance = [[aClass alloc] init];
        if ([instance conformsToProtocol:@protocol(SharkLinkerProtocol)]) {
            sharkInstance = instance;
        }
    });
    return sharkInstance;
}

BOOL hasSharkPushLinker() {
    return sharkPushLinker() == nil? NO : YES;
}

id<SharkPushLinkerProtocol> sharkPushLinker() {
    
    static id sharkPushInstance = nil;
    static  dispatch_once_t pred;
    dispatch_once(&pred, ^{
        Class aClass = NSClassFromString(SharkPushLinkerCalssString);
        id instance = [[aClass alloc] init];
        if ([instance conformsToProtocol:@protocol(SharkPushLinkerProtocol)]) {
            sharkPushInstance = instance;
        }
    });
    return sharkPushInstance;
}

BOOL hasLubanLinker() {
    return lubanLinker() == nil? NO : YES;
}

id<LubanLinkerProtocol> lubanLinker() {
    
    static id lubanInstance = nil;
    static  dispatch_once_t pred;
    dispatch_once(&pred, ^{
        Class aClass = NSClassFromString(LubanLinkerCalssString);
        id instance = [[aClass alloc] init];
        if ([instance conformsToProtocol:@protocol(LubanLinkerProtocol)]) {
            lubanInstance = instance;
        }
    });
    return lubanInstance;
}

BOOL hasQuakerBirdLinker() {
    return quakerBirdLinker() == nil? NO : YES;
}

id<QuakerBirdLinkerProtocol> quakerBirdLinker() {
    
    static id quakerBirdInstance = nil;
    static  dispatch_once_t pred;
    dispatch_once(&pred, ^{
        Class aClass = NSClassFromString(QuakerBirdLinkerCalssString);
        id instance = [[aClass alloc] init];
        if ([instance conformsToProtocol:@protocol(QuakerBirdLinkerProtocol)]) {
            quakerBirdInstance = instance;
        }
    });
    return quakerBirdInstance;
}

id<LoganLinkerProtocol>loganLinker(){
    static id loganInstance = nil;
    static  dispatch_once_t pred;
    dispatch_once(&pred, ^{
        Class aClass = NSClassFromString(LoganLinkerCalssString);
        id instance = [[aClass alloc] init];
        if ([instance conformsToProtocol:@protocol(LoganLinkerProtocol)]) {
            loganInstance = instance;
        }
    });
    return loganInstance;
    
}

BOOL hasLoganLinker() {
    return loganLinker() == nil? NO : YES;
}

