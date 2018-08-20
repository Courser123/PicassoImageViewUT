//
//  NVCodeLogger.h
//  Pods
//
//  Created by MengWang on 16/5/11.
//
//

// NVLog
#define NVLog(format, ...) __cacheNvLog(__FILE__, __LINE__, __func__, format, ## __VA_ARGS__);
// NVLogTags 可以设置Tags标签
// tags: NSArray<NSString *> *tags
#define NVLogTags(tags, format, ...) __cacheNvLogWithTags(__FILE__, __LINE__, __func__, tags, format, ## __VA_ARGS__);

// NVAssert断言
#define NVAssert(condition, desc, ...)	   \
(\
({ if(!(condition)) { \
    __cacheNvAssert(__FILE__, __LINE__, __func__, desc, ## __VA_ARGS__);}})  \
,\
((condition) ? NO:YES) \
)

typedef NSString *(^NVAssertModuleBlock)();
#define NVAssertModule(condition, moduleBlock, desc, ...)	   \
(\
({ if(!(condition)) { \
    __cacheNvAssertModule(__FILE__, __LINE__, __func__, moduleBlock, desc, ## __VA_ARGS__); \
 }})  \
,\
((condition) ? NO:YES) \
)

// custom part category
#define NVAssertModuleCustomPartCategory(condition, moduleBlock, categoryDesc, logDesc)	   \
(\
({ if(!(condition)) { \
    __cacheNvAssertCustomPartCategory(__FILE__, __LINE__, __func__, moduleBlock, categoryDesc, logDesc); \
}})  \
,\
((condition) ? NO:YES) \
)

#define NVAssertModuleWithoutStack(condition, desc, ...)	   \
(\
({ if(!(condition)) { \
    __cacheNvAssertModuleWithoutStack(__FILE__, __LINE__, __func__, desc, ## __VA_ARGS__); \
}})  \
,\
((condition) ? NO:YES) \
)

// custom part category
#define NVAssertModuleWithoutStackCustomPartCategory(condition, categoryDesc, logDesc)	   \
(\
({ if(!(condition)) { \
    __cacheNvAssertCustomPartCategory(__FILE__, __LINE__, __func__, nil, categoryDesc, logDesc); \
}})  \
,\
((condition) ? NO:YES) \
)

// 以下所有C方法严禁业务方直接调用，请使用上述宏方法
extern void __cacheNvLog(const char * file, NSInteger line, const char * func, NSString * format, ...);
extern void __cacheNvLogWithTags(const char * file, NSInteger line, const char * func, NSArray<NSString *> *tags, NSString * format, ...);
extern void __cacheNvAssert(const char * file, NSInteger line, const char * func, NSString * desc, ...);
extern void __cacheNvAssertModule(const char * file, NSInteger line, const char * func, NVAssertModuleBlock moduleBlock, NSString * desc, ...);
extern void __cacheNvAssertModuleWithoutStack(const char * file, NSInteger line, const char * func, NSString * desc, ...);
extern void __cacheNvAssertCustomPartCategory(const char * file, NSInteger line, const char * func, NVAssertModuleBlock moduleBlock, NSString * categoryDesc, NSString * logDesc);
