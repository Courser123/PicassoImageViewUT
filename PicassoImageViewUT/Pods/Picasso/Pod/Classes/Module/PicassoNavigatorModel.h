//
//  PicassoNavigatorItemInfo.h
//  CocoaAsyncSocket
//
//  Created by 纪鹏 on 2017/7/2.
//

#import <Foundation/Foundation.h>
#import "PicassoHost.h"
#import "PicassoCallBack.h"

@interface PicassoNavigatorOpenModel : NSObject

@property (nonatomic, copy) NSString *scheme;
@property (nonatomic, assign) BOOL animated;
@property (nonatomic, strong) NSDictionary *info;
@property (nonatomic, strong) PicassoCallBack *callback;

+ (PicassoNavigatorOpenModel *)modelWithDictionary:(NSDictionary *)params;

@end

@interface PicassoNavigatorItemModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *titleColor;
@property (nonatomic, weak) PicassoHost *host;
@property (nonatomic, copy) NSString *iconName;
@property (nonatomic, copy) NSString *iconUrl;
@property (nonatomic, copy) NSString *iconBase64;
@property (nonatomic, assign) CGFloat iconWidth;
@property (nonatomic, assign) CGFloat iconHeight;
@property (nonatomic, strong) PicassoCallBack *callback;

+ (PicassoNavigatorItemModel *)modelWithDictionary:(NSDictionary *)params;

@end

@interface PicassoNavigatorPopModel : NSObject

@property (nonatomic, assign) BOOL popToRoot;
@property (nonatomic, assign) BOOL animated;

+ (PicassoNavigatorPopModel *)modelWithDictionary:(NSDictionary *)params;

@end

