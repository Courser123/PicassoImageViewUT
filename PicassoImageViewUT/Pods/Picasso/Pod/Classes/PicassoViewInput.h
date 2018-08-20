//
//  PicassoViewInput.h
//  AFNetworking
//
//  Created by 纪鹏 on 2017/11/29.
//

#import <Foundation/Foundation.h>
#import "PicassoVCHost+VCView.h"

@class RACSignal;
@class PicassoModel;

@interface PicassoViewInput : NSObject <NSCoding>

@property (nonatomic, assign) CGFloat width;

@property (nonatomic, assign) CGFloat height;
/**
 预计算之前传入的数据，JSON格式字符串。一般是业务数据，ts中通过 this.intentData 获取
 */
@property (nonatomic, strong) NSString *jsonData;
/**
 额外需要传入js中的数据，ts中通过 this.extraData 获取
 */
@property (nonatomic, strong) NSDictionary *extraData;
/**
 js标识名，区分不同的业务js
 */
@property (nonatomic, copy) NSString *jsName;
/**
 业务js bundle
 */
@property (nonatomic, copy) NSString *jsContent;
/**
 是否预计算成功。如果失败，一般是js执行错误
 */
@property (nonatomic, assign) BOOL isComputeSuccess;
/**
 picassoview所在页面的controller
 */
@property (nonatomic, weak) UIViewController *pageController;

/**
 JS计算,会在后台线程计算，然后sendNext算好的input本身到主线程
 */
- (RACSignal *)computeSignal;
/**
 针对一组input的计算,会在后台线程计算，sendNext算好的input数组本身到主线程
 */
+ (RACSignal *)computeWithInputArray:(NSArray<PicassoViewInput *> *)inputArray;

/**
 在js中通过this.sendMsg(data)向native发送数据，通过实现该block对数据进行处理
 */
@property (nonatomic, copy) PicassoMsgReceiveBlock onReceiveMsg;

/**
 调用js中的方法。
 注：预计算之后才能执行
 @param methodName vc中的方法名
 @param params 方法参数
 */
- (void)callVCMethod:(NSString *)methodName params:(NSDictionary *)params;

@end
