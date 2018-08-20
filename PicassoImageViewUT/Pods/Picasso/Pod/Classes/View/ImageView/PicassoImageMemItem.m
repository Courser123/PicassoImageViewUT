//
//  PicassoImageMemItem.m
//  Picasso
//
//  Created by welson on 2018/4/8.
//

#import "PicassoImageMemItem.h"

@implementation PicassoImageMemItem

- (BOOL)beginContentAccess {
    return YES;
}

- (void)endContentAccess {
    
}

- (void)discardContentIfPossible {
    
}

- (BOOL)isContentDiscarded {
    return NO;
}

@end
