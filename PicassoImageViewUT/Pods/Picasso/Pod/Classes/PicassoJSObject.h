//
//  PicassoJSObject.h
//  layoutDemo
//
//  Created by Stephen Zhang on 16/6/17.
//  Copyright © 2016年 Stephen Zhang. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>

@class PicassoLabelModel;

@protocol PicassoJSProtocol <JSExport>
@property(nonatomic, assign) CGFloat fontLineHeight;
@property(nonatomic, assign) CGFloat fontDescender;

- (NSDictionary *)size_for_text:(NSDictionary *)textJson;
@end

@interface PicassoJSObject : NSObject <PicassoJSProtocol>
@property(nonatomic, assign) CGFloat fontLineHeight;
@property(nonatomic, assign) CGFloat fontDescender;

+ (NSDictionary *)size_for_text:(NSDictionary *)textJson;
@end
