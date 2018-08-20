//
//  PicassoViewFactory.h
//  Pods
//
//  Created by 纪鹏 on 2017/6/5.
//
//

#import <Foundation/Foundation.h>

@interface PicassoViewWrapperFactory : NSObject

+ (Class)viewWrapperByType:(NSInteger)viewType;
+ (Class)viewModelByType:(NSInteger)viewType;
+ (Class)viewClassByType:(NSInteger)viewType;
+ (SEL)selectorWithViewClass:(Class)cls method:(NSString *)method;
@end
