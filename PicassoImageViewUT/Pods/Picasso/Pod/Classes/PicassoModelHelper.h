//
//  PicassoModelHelper.h
//  Pods
//
//  Created by 纪鹏 on 2017/6/11.
//
//

#import <Foundation/Foundation.h>
@class PicassoModel;

@interface PicassoModelHelper : NSObject

+ (PicassoModel *)modelWithDictionary:(NSDictionary *)dic;
    
@end
