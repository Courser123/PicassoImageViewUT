//
//  PicassoAnchorEntity.m
//  picasso
//
//  Created by 纪鹏 on 2018/1/18.
//

#import "PicassoMonitorEntity.h"
#import "PicassoThreadSafeMutableDictionary.h"
#import "NVCodeLogger.h"
#import "PicassoUtility.h"
#import "NVMonitorCenter.h"

NSString *const kPrepare = @"prepare";
NSString *const kStart = @"start";
NSString *const kEnd = @"end";

@interface PicassoMonitorEntity ()

@property (nonatomic, strong) PicassoThreadSafeMutableDictionary <NSString *, NSNumber *> *timeAnchors;
@property (atomic, assign) NSInteger incrementNumber;

@end

@implementation PicassoMonitorEntity

- (instancetype)init {
    if (self = [super init]) {
        _incrementNumber = 0;
        _timeAnchors = [PicassoThreadSafeMutableDictionary new];
    }
    return self;
}

- (void)prepare:(NSString *)anchor {
    if (![self shouldLog:anchor]) return;
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:3];
    dic[kPrepare] = [self getCurrentTime];
    self.timeAnchors[anchor] = dic;
}

- (void)start:(NSString *)anchor {
    if (![self shouldLog:anchor]) return;
    NSMutableDictionary *dic = self.timeAnchors[anchor];
    if (!dic) {
        dic = [[NSMutableDictionary alloc] initWithCapacity:2];
    }
    dic[kStart] = [self getCurrentTime];
    self.timeAnchors[anchor] = dic;
}

- (void)end:(NSString *)anchor {
    if (![self shouldLog:anchor]) return;
    NSMutableDictionary *dic = self.timeAnchors[anchor];
    if(!dic) {
        NVAssert(false, @"performance has no start");
        return;
    }
    if(dic[kEnd]) {
        return;
    }
    dic[kEnd] = [self getCurrentTime];
    
    self.timeAnchors[anchor] = dic;

    {
        NSNumber *start = dic[kPrepare]?:dic[kStart];
        NSInteger timeCost = [dic[kEnd] integerValue] - [start integerValue];
        NSMutableString *logStr = [[NSMutableString alloc] initWithFormat:@"%@ Perormance: %@", anchor, @(timeCost)];
        NSLog(@"%@", logStr);
    }
}

- (void)end:(nonnull NSString *)anchor reportSuccess:(BOOL)success {
    [self end:anchor reportCode:success?200:500];
}

- (void)end:(nonnull NSString *)anchor reportCode:(int)code {
    [self end:anchor];
    [self report:code];
}

- (void)report:(int)code {
    NSDictionary *compute = self.timeAnchors[PicassoMonitorEntity.PRECOMPUTE];
    NSDictionary *vcload = self.timeAnchors[PicassoMonitorEntity.VC_LOAD];
    NSString *jsname = self.name ?: @"UNKNOWN";
    if (compute) {
        [self report:compute cmd:[NSString stringWithFormat:@"picasso://compute/%@",jsname] code:code];
    } else if (vcload) {
        [self report:vcload cmd:[NSString stringWithFormat:@"picasso://vcload/%@",jsname] code:code];
    }
}

- (void)report:(NSDictionary *)timeDic cmd:(NSString *)cmd code:(int)code{
    NSNumber *startNum = timeDic[kStart];
    NSNumber *endNum = timeDic[kEnd];
    if (!startNum || !endNum) return;
    int time = endNum.intValue - startNum.intValue;
    [[NVMonitorCenter defaultCenter] pvWithCommand:cmd network:0 code:code requestBytes:0 responseBytes:0 responseTime:time];
}

- (nonnull NSNumber *)getCurrentTime {
    return @(floor(CFAbsoluteTimeGetCurrent() * 1000));
}

- (BOOL)shouldLog:(NSString *)anchor {
    if (anchor.length == 0) return NO;
    if([PicassoUtility isDebug]) return YES;
    return [@[PicassoMonitorEntity.VC_LOAD,
              PicassoMonitorEntity.PRECOMPUTE]
            containsObject:anchor];
}

- (NSString *)wrapMethodInvokeAnchorForName:(NSString *)methodName arg1:(id)arg1 arg2:(id)arg2 {
    NSMutableString *methodInfo = [NSMutableString stringWithFormat:@"%@:%@,args: ", PicassoMonitorEntity.CONTROLLER_INVOKE_PREFIX, methodName];
    if (arg1) {
        [methodInfo appendFormat:@"%@,", arg1];
    }
    if (arg2) {
        [methodInfo appendFormat:@"%@,", arg2];
    }
    [methodInfo appendFormat:@"@%@", @([self uniqueNumber])];
    return [methodInfo copy];
}

- (NSString *)wrapUniqued:(NSString *)name {
    return [NSString stringWithFormat:@"%@@%@", name, @([self uniqueNumber])];
}

- (NSInteger)uniqueNumber {
    return self.incrementNumber++;
}


+ (nonnull NSString *)INIT_ALL { return @"init_all"; }
+ (nonnull NSString *)INIT_INJECT { return @"init_inject"; }
+ (nonnull NSString *)INIT_MAPPING { return @"init_mapping"; }
+ (nonnull NSString *)INIT_MODULE_JS { return @"init_module_js"; }
+ (nonnull NSString *)INIT_MATRIX_JS { return @"init_matrix_js"; }
+ (nonnull NSString *)PRECOMPUTE { return @"precompute"; }
+ (nonnull NSString *)CONTROLLER_CREATE { return @"controller_create"; }
+ (nonnull NSString *)CONTROLLER_INVOKE_PREFIX { return @"controller_invoke"; }
+ (nonnull NSString *)CONTROLLER_DESTROY { return @"controller_destroy"; }
+ (nonnull NSString *)VC_LOAD { return @"vc_load"; }
+ (nonnull NSString *)VC_LAYOUT { return @"vc_layout"; }
+ (nonnull NSString *)VC_PMODEL { return @"vc_pmodel"; }
+ (nonnull NSString *)VC_LAYOUT_CHILD { return @"vc_layout_child"; }
@end
