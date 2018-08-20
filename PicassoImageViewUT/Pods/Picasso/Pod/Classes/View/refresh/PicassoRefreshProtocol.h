//
//  NVPullRefreshProtocol.h
//  Pods
//
//  Created by 纪鹏 on 15/7/16.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, PicassoPullRefrshState) {
    PicassoPullRefrshStateNone = 0,
    PicassoPullRefrshStateDragging,
    PicassoPullRefrshStateLoading,
    PicassoPullRefrshStateJump,
    PicassoPullRefrshStateSuccess
};

@protocol PicassoRefreshProtocol <NSObject>
/**
 *  set animations according to the tableview offset
 *
 *  @param offset - tableview's Y offset
 *  @param isDragging - whether scrollview is being dragging
 */
- (void)setViewWithYOffset:(CGFloat)offset isDragging:(BOOL)isDragging;

/**
 *  set the state of the refresh view
 *
 *  @param state - the state
 */
- (void)setState:(PicassoPullRefrshState)state;

@optional
/**
 *  tableview loading margin
 *
 *  @return  must be a positive value
 */
- (CGFloat)loadingOffset;

//set success state finish block
- (void)setSuccessFinishBlock:(void(^)())block;

@end
