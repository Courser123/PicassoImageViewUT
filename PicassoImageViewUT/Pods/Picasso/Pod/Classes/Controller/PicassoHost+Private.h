//
//  PicassoHost+Private.h
//  Picasso
//
//  Created by 纪鹏 on 2018/5/20.
//

#import "PicassoHost.h"
#import "PicassoMonitorEntity.h"

@interface PicassoHost ()
@property (nonatomic, strong) NSMutableDictionary *moduleInstanceMapper;
@property (nonatomic, copy) NSString *hostId;
@property (nonatomic, strong) PicassoMonitorEntity *monitorEntity;
- (void)createControllerWithScript:(NSString *)script options:(NSDictionary *)options stringData:(NSString *)strData;
/** 类型为String或者Dictionary */
@property (nonatomic, strong) id intentData;
@end
