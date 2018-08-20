//
//  PicassoJSObject.m
//  layoutDemo
//
//  Created by Stephen Zhang on 16/6/17.
//  Copyright © 2016年 Stephen Zhang. All rights reserved.
//
#import "PicassoJSObject.h"
#import "UIView+Layout.h"
#import "PCSJsonLabel.h"
#import "PicassoLabelModel.h"
#import "PCSJsonLabelStyleModel.h"

@interface PicassoJSObject ()

@end

@implementation PicassoJSObject

- (instancetype)init {
    if (self = [super init]) {
        UIFont *font = [UIFont systemFontOfSize:1.0f];
        self.fontLineHeight = font.lineHeight;
        self.fontDescender = font.descender;
    }
    return self;
}

- (NSDictionary *)size_for_text:(NSDictionary *)textJson {
    return [self.class size_for_text:textJson];
}

+ (NSDictionary *)size_for_text:(NSDictionary *)textJson {
    PicassoLabelModel *model = [PicassoLabelModel modelWithDictionary:textJson];
    CGSize size = [model calculateSize];
    return @{@"width":@(size.width), @"height":@(size.height)};
}

@end
