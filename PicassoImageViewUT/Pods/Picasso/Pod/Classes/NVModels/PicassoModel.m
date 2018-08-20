//
//  PicassoModel.m
//  Picasso
//
//  Created by 纪鹏 on 2018/5/8.
//

#import "PicassoModel.h"
#import "UIColor+pcsUtils.h"
#import "NSString+JSON.h"
#import "PicassoVCHost+Private.h"
#import "PicassoHostManager.h"
#import "NVCodeLogger.h"

@implementation PicassoModel

- (NSArray <PicassoModel *> *)subModels {
    return nil;
}

+(instancetype)modelWithDictionary:(NSDictionary *)dictionaryValue {
    PicassoModel *model = [[self alloc] init];
    @try {
        NSString *hostId = dictionaryValue[@"hostId"];
        NSNumber *key = dictionaryValue[@"key"];
        if (key) {
            PicassoHost *host = [PicassoHostManager hostForId:hostId];
            if ([host isKindOfClass:[PicassoVCHost class]]) {
                PicassoVCHost *vcHost = (PicassoVCHost *)host;
                PicassoModel *cachedModel = [vcHost modelForKey:key];
                if ([cachedModel isKindOfClass:[self class]]) {
                    return cachedModel;
                } else {
                    [vcHost setModel:model forKey:key];
                }
            }
        }
        [model setModelWithDictionary:dictionaryValue];
    } @catch (NSException *exception) {
        NSString *errorStr = [NSString stringWithFormat:@"ModelClass: %@\nexceptionName:%@\nexceptionReason:%@\nStack:\n%@",
                                                        NSStringFromClass([self class]),
                                                        exception.name,
                                                        exception,
                                                        [exception.callStackSymbols componentsJoinedByString:@"\n"]];
        NVAssert(false, @"PicassoModel解析错误: %@", errorStr);
    } @finally {
        
    }

    return model;
}

-(void)setModelWithDictionary:(NSDictionary *)dictionaryValue {
    self.dictionaryValue = dictionaryValue;
    self.viewId = [dictionaryValue objectForKey:@"viewId"];
    self.parentId = [dictionaryValue objectForKey:@"parentId"];
    self.hostId = [dictionaryValue objectForKey:@"hostId"];
    self.tag = [dictionaryValue objectForKey:@"tag"];
    self.hidden = [[dictionaryValue objectForKey:@"hidden"] boolValue];
    self.alpha = [[dictionaryValue objectForKey:@"alpha"] doubleValue];
    if (isnan(self.alpha)) {
        self.alpha = 1;
    }
    NSString *borderColorHex = [dictionaryValue objectForKey:@"borderColor"];
    if (borderColorHex.length) {
        self.borderColor = [UIColor pcsColorWithHexString:borderColorHex];
    }
    self.borderWidth = [[dictionaryValue objectForKey:@"borderWidth"] doubleValue];
    if (isnan(self.borderWidth)) {
        self.borderWidth = 0;
    }
    {
        self.cornerRadius = [[dictionaryValue objectForKey:@"cornerRadius"] doubleValue];
        if (isnan(self.cornerRadius)) {
            self.cornerRadius = 0;
        }
        BOOL cornerTopLeft = [dictionaryValue[@"cornerRadiusLT"] boolValue];
        BOOL cornerTopRight = [dictionaryValue[@"cornerRadiusRT"] boolValue];
        BOOL cornerBottomLeft = [dictionaryValue[@"cornerRadiusLB"] boolValue];
        BOOL cornerBottomRight = [dictionaryValue[@"cornerRadiusRB"] boolValue];
        self.rectCorner = (cornerTopLeft?UIRectCornerTopLeft:0) | (cornerTopRight?UIRectCornerTopRight:0) | (cornerBottomLeft?UIRectCornerBottomLeft:0) | (cornerBottomRight?UIRectCornerBottomRight:0);
    }
    NSNumber *typeNum = dictionaryValue[@"type"];
    self.type = typeNum ? [typeNum integerValue] : -1;
    NSString *backgroundColorHex = [dictionaryValue objectForKey:@"backgroundColor"];
    self.backgroundColor = backgroundColorHex.length ? [UIColor pcsColorWithHexString:backgroundColorHex] : [UIColor clearColor];
    
    self.y = [[dictionaryValue objectForKey:@"y"] doubleValue];
    self.x = [[dictionaryValue objectForKey:@"x"] doubleValue];
    self.height = [[dictionaryValue objectForKey:@"height"] doubleValue];
    self.width = [[dictionaryValue objectForKey:@"width"] doubleValue];
    if (isnan(self.x)) {
        self.x = 0;
    }
    if (isnan(self.y)) {
        self.y = 0;
    }
    if (isnan(self.height)) {
        self.height = 0;
    }
    if (isnan(self.width)) {
        self.width = 0;
    }
    self.gaLabel = [dictionaryValue objectForKey:@"gaLabel"];
    NSString *gaUserInfo = [dictionaryValue objectForKey:@"gaUserInfo"];
    if ([gaUserInfo isKindOfClass:[NSString class]]) {
        self.gaUserInfo = [gaUserInfo JSONValue];
        if(![self.gaUserInfo isKindOfClass:[NSDictionary class]]){
            NSLog(@"gaUserInfo不是标准Json格式字符串，无法转为NSDictionary");
            self.gaUserInfo = nil;
        }
    } else if ([gaUserInfo isKindOfClass:[NSDictionary class]]) {
        self.gaUserInfo = (NSDictionary *)gaUserInfo;
    }
    self.actions = [dictionaryValue objectForKey:@"actions"];
    if (self.actions && ![self.actions isKindOfClass:[NSArray class]]) {
        self.actions = @[];
    }
    {   //阴影
        NSString *shColorHex = dictionaryValue[@"sdColor"];
        self.shadowColor = shColorHex.length > 0 ? [UIColor pcsColorWithHexString:shColorHex] : [UIColor blackColor];
        self.shadowRadius = [dictionaryValue[@"sdRadius"] doubleValue];
        self.shadowOpacity = [dictionaryValue[@"sdOpacity"] doubleValue];
        CGFloat offsetWidth = [dictionaryValue[@"sdOffsetX"] doubleValue];
        CGFloat offsetHeight = [dictionaryValue[@"sdOffsetY"] doubleValue];
        self.shadowOffset = CGSizeMake(offsetWidth, offsetHeight);
    }
    
    {   //渐变色
        NSString *startColorStr = dictionaryValue[@"startColor"];
        if (startColorStr.length) {
            UIColor *startColor = [UIColor pcsColorWithHexString:startColorStr];
            UIColor *endColor = [UIColor pcsColorWithHexString:dictionaryValue[@"endColor"]];
            self.gradientColors = @[(__bridge id)startColor.CGColor, (__bridge id)endColor.CGColor];
            NSInteger orientation = [dictionaryValue[@"orientation"] integerValue];
            [self setPointsForOrientation:orientation];
        }
    }
    
    self.extra = dictionaryValue[@"extra"];
    self.key = dictionaryValue[@"key"];
    self.accessId = dictionaryValue[@"accessId"];
    self.accessLabel = dictionaryValue[@"accessLabel"];
}

- (void)setPointsForOrientation:(NSInteger)orient {
    switch (orient) {
        case 0:
            self.gradientStartPoint = (CGPoint){0,0};
            self.gradientEndPoint = (CGPoint){0,1};
            break;
        case 1:
            self.gradientStartPoint = (CGPoint){1,0};
            self.gradientEndPoint = (CGPoint){0,1};
            break;
        case 2:
            self.gradientStartPoint = (CGPoint){1,0};
            self.gradientEndPoint = (CGPoint){0,0};
            break;
        case 3:
            self.gradientStartPoint = (CGPoint){1,1};
            self.gradientEndPoint = (CGPoint){0,0};
            break;
        case 4:
            self.gradientStartPoint = (CGPoint){0,1};
            self.gradientEndPoint = (CGPoint){0,0};
            break;
        case 5:
            self.gradientStartPoint = (CGPoint){0,1};
            self.gradientEndPoint = (CGPoint){1,0};
            break;
        case 6:
            self.gradientStartPoint = (CGPoint){0,0};
            self.gradientEndPoint = (CGPoint){1,0};
            break;
        case 7:
            self.gradientStartPoint = (CGPoint){0,0};
            self.gradientEndPoint = (CGPoint){1,1};
            break;
        default:
            self.gradientStartPoint = (CGPoint){0,0};
            self.gradientEndPoint = (CGPoint){0,1};
            break;
    }
}

@end
