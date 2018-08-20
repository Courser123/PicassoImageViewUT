//
//  NVLinker.h
//  NVLinker
//
//  Created by JiangTeng on 2018/2/27.
//

#import <Foundation/Foundation.h>
#import "SharkLinkerProtocol.h"
#import "SharkPushLinkerProtocol.h"
#import "LubanLinkerProtocol.h"
#import "QuakerBirdLinkerProtocol.h"
#import "LoganLinkerProtocol.h"

/**
 是否存在shark

 @return YES:项目中存在shark，NO:项目中不存在shark
 */
BOOL hasSharkLinker(void);

/**
 获取SharkLinker，如果项目中引入了Shark 返回遵守SharkLinkerProtocol协议的实例。否则返回nil
 
 @return nil 或者 遵守SharkLinkerProtocol协议的实例
 */

id<SharkLinkerProtocol> sharkLinker(void);

/**
 是否存在sharkPush
 
 @return YES:项目中存在sharkPush，NO:项目中不存在sharkPush
 */
BOOL hasSharkPushLinker(void);

/**
 获取SharkPushLinker，如果项目中引入了SharkPush返回遵守SharkPushLinkerProtocol协议的实例。否则返回nil
 
 @return nil 或者 遵守SharkPushLinkerProtocol协议的实例
 */
id<SharkPushLinkerProtocol> sharkPushLinker(void);


/**
 是否存在luban

 @return YES:项目中存在luban，NO:项目中不存在luban
 */
BOOL hasLubanLinker(void);

/**
 获取LubanLinker，如果项目中引入了Luban返回遵守LubanLinkerProtocol协议的实例。否则返回nil
 
 @return nil 或者 遵守LubanLinkerProtocol协议的实例
 */
id<LubanLinkerProtocol> lubanLinker(void);


/**
 是否存在QuakerBird
 
 @return YES:项目中存在QuakerBird，NO:项目中不存在QuakerBird
 */
BOOL hasQuakerBirdLinker(void);

/**
 获取quakerBirdLinker，如果项目中引入了QuakerBird返回遵守QuakerBirdLinkerProtocol协议的实例。否则返回nil
 
 @return nil 或者 遵守QuakerBirdLinkerProtocol协议的实例
 */
id<QuakerBirdLinkerProtocol> quakerBirdLinker(void);

/**
 是否存在Logan
 
 @return YES:项目中存在Logan，NO:项目中不存在Logan
 */
BOOL hasLoganLinker(void);

/**
 获取Logan，如果项目中引入了Logan返回遵守LoganLinkerProtocol协议的实例。否则返回nil
 
 @return nil 或者 遵守LoganLinkerProtocol协议的实例
 */
id<LoganLinkerProtocol>loganLinker(void);


