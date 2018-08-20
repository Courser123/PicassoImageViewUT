//
//  PicassoListItem.h
//  Picasso
//
//  Created by 纪鹏 on 2018/2/28.
//

#import <UIKit/UIKit.h>

@class PicassoListItemModel;
@interface PicassoListCell : UITableViewCell

- (instancetype)initWithModel:(PicassoListItemModel *)model;
- (void)updateWithModel:(PicassoListItemModel *)model;

@end
