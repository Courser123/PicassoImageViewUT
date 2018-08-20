//
//  UGCFetchOperationProtocol.h
//  Pods
//
//  Created by 薛琳 on 16/10/19.
//
//

#import <Foundation/Foundation.h>

@protocol PicassoFetchOperationProtocol <NSObject>
- (void)downloadTaskProgressChanged:(NSUInteger)progress;
- (void)downloadTaskHaveFinished:(NSData *)data andError:(NSError *)error code:(NSInteger)code;
@end
