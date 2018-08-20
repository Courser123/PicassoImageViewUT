//
//  PicassoSizeToFitProtocol.h
//  Picasso
//
//  Created by 纪鹏 on 2018/5/20.
//

#import <Foundation/Foundation.h>

@protocol PicassoSizeToFitProtocol <NSObject>

- (BOOL)needSizeToFit;

- (NSString *)sizeKey;

- (CGSize)calculateSize;

@end
