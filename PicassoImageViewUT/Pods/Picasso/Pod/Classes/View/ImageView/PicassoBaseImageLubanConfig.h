//
//  PicassoBaseImageLubanConfig.h
//  Picasso
//
//  Created by Courser on 2018/6/5.
//

#import <Foundation/Foundation.h>

@interface PicassoBaseImageLubanConfig : NSObject

+ (PicassoBaseImageLubanConfig *)sharedInstance;

// unit: MB
@property (nonatomic, assign) NSUInteger diskCacheSize;

// unit: s
@property (nonatomic, assign) NSUInteger timeoutIntervalForRequest;

@end
