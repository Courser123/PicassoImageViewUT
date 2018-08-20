//
//  PicassoVCHost+VCView.h
//  Pods
//
//  Created by 纪鹏 on 2017/12/20.
//

#import "PicassoVCHost.h"

typedef void(^PicassoMsgReceiveBlock)(NSDictionary *msgDic);

@interface PicassoVCHost (VCView)

@property (nonatomic, copy) PicassoMsgReceiveBlock msgBlock;

@end
