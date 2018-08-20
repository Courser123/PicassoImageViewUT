//
//  PicassoVCHost+Private.h
//  Picasso
//
//  Created by 纪鹏 on 2018/5/20.
//

#import "PicassoVCHost.h"
#import "PicassoModel.h"

@class PicassoView;
@interface PicassoVCHost ()

- (void)twiceLayout;

- (void)storeView:(UIView *)view withId:(NSString *)viewId;
- (UIView *)viewForId:(NSString *)viewId;
- (void)removeViewForId:(NSString *)viewId;

- (void)setModel:(PicassoModel *)model forKey:(NSNumber *)key;
- (PicassoModel *)modelForKey:(NSNumber *)key;

- (void)addSizeCacheForKey:(NSString *)sizeKey size:(NSDictionary *)sizeDic;

- (PicassoView *)picassoViewWithChildVCId:(NSInteger)vcId;

@end
