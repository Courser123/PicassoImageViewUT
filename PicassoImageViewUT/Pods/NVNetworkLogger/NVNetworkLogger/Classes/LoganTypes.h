//
//  LoganTypes.h
//  Pods
//
//  Created by ZhouHui on 2017/7/7.
//
//

#ifndef LoganTyps_h
#define LoganTyps_h

typedef enum : NSUInteger {
    LoganTypeLogan      = 1, //Logan内部日志
    LoganTypeJudas      = 2, //用户行为日志
    LoganTypeCode       = 3, //代码级日志
    LoganTypeShark      = 4, //Shark日志
    LoganTypeCat        = 5, //端到端日志
    LoganTypePush       = 6, //PushSDK日志
    LoganTypeCrash      = 7, //崩溃日志
    LoganTypeLingXi     = 8, //灵犀日志
    LoganTypeFatCat     = 9, //FatCat
    LoganTypeTA         = 10,//外卖日志
    LoganTypeSharkPush  = 11,//sharkPush
    LoganTypeLuban      = 12,//luban配置sdk
    LoganTypeDXSDK      = 20,//大象SDK日志
} LoganType;

#endif /* LoganTypes_h */
