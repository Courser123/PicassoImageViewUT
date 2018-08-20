//
//  PicassoInput.h
//  Pods
//
//  Created by Stephen Zhang on 16/9/22.
//
//
#import <Foundation/Foundation.h>

@class RACSignal;
@class PicassoModel;

@interface PicassoInput : NSObject

@property (nonatomic, assign) CGFloat width;

@property (nonatomic, assign) CGFloat height;

@property (nonatomic, strong) NSString *jsonData;

@property (nonatomic, copy) NSString *jsName;

@property (nonatomic, copy) NSString *jsContent;

@property (nonatomic, assign) BOOL isComputeSuccess;

@property (nonatomic, strong) NSError *error;

//可自定义上下文环境
@property (nonatomic, copy) NSDictionary *jsContextInject;

//JS计算,会在后台线程计算，然后sendNext算好的input本身到主线程
- (RACSignal *)computeSignal;

//针对一组input的计算,会在后台线程计算，sendNext算好的input数组本身到主线程
+ (RACSignal *)computeWithInputArray:(NSArray<PicassoInput *> *)inputArray;

@end
