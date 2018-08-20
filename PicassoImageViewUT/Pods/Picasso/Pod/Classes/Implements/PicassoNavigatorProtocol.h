//
//  PicassoNavigatorProtocol.h
//  Pods
//
//  Created by 纪鹏 on 2017/7/2.
//

#import <Foundation/Foundation.h>
#import "PicassoNavigatorModel.h"

@protocol PicassoNavigatorProtocol <NSObject>

- (void)setNavigationBarHidden:(BOOL)hidden
                      animated:(BOOL)animated
                withController:(UIViewController *)controller;

- (void)setNavigationBarBackgroundColor:(UIColor *)backgroundColor
                      withController:(UIViewController *)controller;

- (void)setNavigationBarTitleWithModel:(PicassoNavigatorItemModel *)model
                   withViewController:(UIViewController *)controller;

- (void)setLeftNavigationItemsWithModelArray:(NSArray <PicassoNavigatorItemModel *> *)modelArr
                          withViewController:(UIViewController *)controller;

- (void)setRightNavigationItemsWithModelArray:(NSArray <PicassoNavigatorItemModel *> *)modelArr
                          withViewController:(UIViewController *)controller;

- (void)popViewControllerWithModel:(PicassoNavigatorPopModel *)model
               withViewController:(UIViewController *)controller;

@optional
- (void)openScheme:(PicassoNavigatorOpenModel *)model withViewController:(UIViewController *)controller;

@end
