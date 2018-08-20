//
//  PicassoTableView.h
//  clogan
//
//  Created by 纪鹏 on 2017/10/20.
//

#import <UIKit/UIKit.h>

@class PicassoListViewModel;

@interface PicassoTableView : UITableView

- (instancetype)initWithModel:(PicassoListViewModel *)model;
- (void)updateWithModel:(PicassoListViewModel *)model;

@end
