//
//  PicassoCrashReporter.m
//  Picasso
//
//  Created by 纪鹏 on 2018/5/10.
//

#import "PicassoCrashReporter.h"
#import "NSString+pcs_md5.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "PicassoUtility.h"
#include <sys/sysctl.h>
#include <zlib.h>
#import "PicassoDebugMode.h"
#import "PicassoThreadManager.h"

NSInteger const kPicassoCrashMaxReportCount = 20;           ///<每次冷启动最多上报20条

@interface PicassoCrashReporter ()

@property (nonatomic, strong) NSDateFormatter *formatter;
@property (nonatomic, assign) NSInteger crashCount;
@property (nonatomic, assign) NSTimeInterval reportInterval;

@end

@implementation PicassoCrashReporter

+ (PicassoCrashReporter *)instance {
    static PicassoCrashReporter *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [PicassoCrashReporter new];
    });
    return _instance;
}

- (NSString *)crashPath {
    return @"https://catdot.dianping.com/broker-service/crashlog";
}

- (void)reportCrashWithException:(JSValue *)exception jsContent:(NSString *)jsContent jsname:(NSString *)jsname status:(NSString *)status
{
    NSTimeInterval currentInterval = [NSDate timeIntervalSinceReferenceDate];
    if (currentInterval - self.reportInterval > 24 * 60 * 60) {
        self.crashCount = 0;
        self.reportInterval = currentInterval;
    }

    BOOL isX86_64 = [[self platformString] isEqualToString:@"x86_64"];
    BOOL isExceedMaxReport = self.crashCount > kPicassoCrashMaxReportCount;
    BOOL isNull = !exception || (jsContent.length == 0 && jsname.length == 0);
    BOOL onLiveLoad = [PicassoDebugMode instance].onLiveLoad;
    if ([PicassoUtility isDebug] && exception) {
        NSString *stack = [exception[@"stack"] toObject];
        NSArray<NSString *> *stackArr = [stack componentsSeparatedByString:@"\n"];
        NSString *reason = [NSString stringWithFormat:@"%@, %@", exception, stackArr.firstObject];

        PCSRunOnMainThread(^{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:jsname message:reason preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
        });
    }
    if (isX86_64 || isExceedMaxReport || isNull || onLiveLoad) {
        return;
    }
    self.crashCount++;

    NSString *md5 = @"";
    if (jsContent.length > 0) {
        md5 = [jsContent pcs_md5];
    }
    NSString *owner = md5.length > 0 ? md5 : jsname;
    NSString *stack = [exception[@"stack"] toObject];
    NSArray<NSString *> *stackArr = [stack componentsSeparatedByString:@"\n"];
    NSString *reason = [NSString stringWithFormat:@"%@, %@", exception, stackArr.firstObject];
    NSString *title = [NSString stringWithFormat:@"$$$%@###%@$$$", owner, reason];
    NSString *decoStack = [NSString stringWithFormat:@"/***StackTrace***/\n%@\n/***StackTrace***/", stack];
    NSString *crashContent = [NSString stringWithFormat:@"%@\nJS执行错误[source:%@, line:%@, column:%@]：%@\n%@", title, exception[@"sourceURL"], exception[@"line"], exception[@"column"], exception, decoStack];
    
    NSString *projectName = @"";
    NSString *bundleName = @"";
    if (jsname.length > 0) {
        NSInteger location = [jsname rangeOfString:@"/"].location;
        if (location == NSNotFound) {
            projectName = bundleName = jsname?:@"";
        } else {
            projectName = [jsname substringToIndex:location];
            bundleName = [jsname substringFromIndex:location + 1];
        }
    }
    
    NSMutableDictionary *crashDic = [self crashEnv];
    
    [crashDic setObject:md5?:@"" forKey:@"md5"];
    [crashDic setObject:projectName?:@"" forKey:@"projectName"];
    [crashDic setObject:bundleName?:@"" forKey:@"bundleName"];
    [crashDic setObject:reason forKey:@"reason"];
    
    NSMutableString *reportString = [[NSMutableString alloc] init];
    for (NSString *key in crashDic.allKeys) {
        NSObject *value = crashDic[key];
        [reportString appendFormat:@"%@=%@\n",key,value];
    }
    [reportString appendString:@"\n"];
    [reportString appendString:@"\n"];
    [reportString appendString:@"\n"];
    [reportString appendString:crashContent];
    [reportString appendString:@"\n"];
    [reportString appendString:@"\n"];
    [crashDic setObject:reportString forKey:@"crashContent"];
    [crashDic setObject:(status?:@"") forKey:@"status"];
    NSString *uploadStr = [self transformUploadCatJsonString:crashDic];
    [self uploadJSCrash:uploadStr];
}

- (void)uploadJSCrash:(NSString *)uploadStr {
    NSURL *url = [NSURL URLWithString:[self crashPath]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    NSString *unionId = [PicassoUtility unionId];
    if (unionId.length != 0) {
        [request addValue:unionId forHTTPHeaderField:@"unionId"];
    }
    [request setHTTPBody:[self encodeGZip:[uploadStr dataUsingEncoding:NSUTF8StringEncoding]]];
    NSURLSessionDataTask *task = [[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if((!error) && ([(NSHTTPURLResponse *)response statusCode] == 200)) {
            NSLog(@"Crash report send success");
        } else {
            NSLog(@"Failed to send crash report");
        }
    }];
    [task resume];
}

- (NSMutableDictionary *)crashEnv {
    NSDictionary *picassoEnv = [PicassoUtility getEnvironment];
    NSString *uploadAppVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *archiveSourceStr = [self archiveSource];
    if (![archiveSourceStr isEqualToString:@"TestFlight"] && ![archiveSourceStr isEqualToString:@"AppStore"]) {
        uploadAppVersion = [NSString stringWithFormat:@"%@_debug",uploadAppVersion];
    }

    NSMutableDictionary *crashEnvDic = [NSMutableDictionary new];
    
    if ([PicassoUtility isDebug]) {
        [crashEnvDic setValue:@(1) forKey:@"debug"];
    }
    [crashEnvDic setValue:[self archiveSource] forKey:@"packageSource"];
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"version-touch" withExtension:@"txt"];
    NSString *buildVersion = [NSString stringWithContentsOfURL:url usedEncoding:0 error:nil];
    [crashEnvDic setValue:buildVersion forKey:@"build"];
    [crashEnvDic setValue:[self nv_uuidString] forKey:@"uuid"];

    [crashEnvDic setObject:[self catAppId] forKey:@"appId"];
    [crashEnvDic setObject:uploadAppVersion forKey:@"appVersion"];
    [crashEnvDic setObject:picassoEnv[@"osVersion"] forKey:@"platVersion"];
    [crashEnvDic setObject:[self deviceBrand] forKey:@"deviceBrand"];
    [crashEnvDic setObject:[self platformString] forKey:@"deviceModel"];
    [crashEnvDic setObject:[self.formatter stringFromDate:[NSDate date]] forKey:@"crashTime"];
    [crashEnvDic setObject:[PicassoUtility unionId] forKey:@"unionId"];
    [crashEnvDic setObject:@"ios" forKey:@"platform"];
    [crashEnvDic setObject:@"PICASSO" forKey:@"category"];
    return crashEnvDic;
}

- (NSString*)transformUploadCatJsonString:(NSDictionary *)dic
{
    if (!dic) {
        return @"";
    }
    NSString *jsonString = @"";
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if (!jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}

- (NSString *)catAppId {
    NSInteger appId = [PicassoUtility appId].integerValue;
    if (appId == 0) {
        return @"1";
    } else if (appId == 1) {
        return @"10";
    }
    return @(appId).stringValue;
}

- (NSString *)deviceBrand {
    NSString *modelName = [[UIDevice currentDevice] model];
    if([modelName hasPrefix:@"iPhone"])
        return @"iPhone";
    else if([modelName hasPrefix:@"iPod"])
        return @"iPod";
    else if([modelName hasPrefix:@"iPad"])
        return @"iPad";
    return @"iOS";
}

- (NSString *)platformString{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    
    return platform;
}

- (NSDateFormatter *)formatter {
    if (!_formatter) {
        _formatter = [[NSDateFormatter alloc] init];
        [_formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    return _formatter;
}

- (NSString *)nv_uuidString {
    CFUUIDRef uuidObj = CFUUIDCreate(nil);
    NSString *uuid = (__bridge_transfer NSString *)CFUUIDCreateString(nil, uuidObj);
    CFRelease(uuidObj);
    return uuid;
}

- (NSString *)archiveSource {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ArchiveSource" ofType:@"txt"];
    NSString *packageSource = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    
    return [packageSource stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSData *)encodeGZip:(NSData *)zipData {
    if ([zipData length] == 0) return nil;
    
    z_stream strm;
    
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    strm.opaque = Z_NULL;
    strm.total_out = 0;
    strm.next_in=(Bytef *)[zipData bytes];
    strm.avail_in = (uInt)[zipData length];
    
    // Compresssion Levels:
    //   Z_NO_COMPRESSION
    //   Z_BEST_SPEED
    //   Z_BEST_COMPRESSION
    //   Z_DEFAULT_COMPRESSION
    
    if (deflateInit2(&strm, Z_DEFAULT_COMPRESSION, Z_DEFLATED, (15+16), 8, Z_DEFAULT_STRATEGY) != Z_OK) return nil;
    
    NSMutableData *compressed = [NSMutableData dataWithLength:16384];  // 16K chunks for expansion
    
    do {
        
        if (strm.total_out >= [compressed length])
            [compressed increaseLengthBy: 16384];
        
        strm.next_out = [compressed mutableBytes] + strm.total_out;
        strm.avail_out = (uInt)([compressed length] - strm.total_out);
        
        deflate(&strm, Z_FINISH);
        
    } while (strm.avail_out == 0);
    
    deflateEnd(&strm);
    
    [compressed setLength: strm.total_out];
    return [NSData dataWithData:compressed];
}

@end
