//
//  PicassoImageViewModel.m
//  Picasso
//
//  Created by 纪鹏 on 2018/5/8.
//

#import "PicassoImageViewModel.h"
#import "PicassoAppConfiguration.h"
#import "PicassoBaseModel+Private.h"
#import "UIImage+Picasso.h"

@implementation PicassoImageViewModel

- (void)setModelWithDictionary:(NSDictionary *)dictionaryValue {
    [super setModelWithDictionary:dictionaryValue];
    self.contentMode = [[dictionaryValue objectForKey:@"contentMode"] integerValue];
    NSDictionary *edgeInsetsDic = dictionaryValue[@"edgeInsets"];
    if (edgeInsetsDic && [edgeInsetsDic isKindOfClass:[NSDictionary class]]) {
        self.edgeInsets = UIEdgeInsetsMake([edgeInsetsDic[@"top"] doubleValue],
                                           [edgeInsetsDic[@"left"] doubleValue],
                                           [edgeInsetsDic[@"bottom"] doubleValue],
                                           [edgeInsetsDic[@"right"] doubleValue]);
    } else {
        self.edgeInsets = UIEdgeInsetsZero;
    }
    self.imageScale = [dictionaryValue[@"imageScale"] integerValue];
    
    NSString *imageName = [dictionaryValue objectForKey:@"image"];
    NSString *imagePath = [dictionaryValue objectForKey:@"imagePath"];
    NSString *imageBase64 = [dictionaryValue objectForKey:@"imageBase64"];
    
    if (imageName.length) {
        self.localImage = [UIImage imageNamed:imageName];
    } else if (imagePath.length) {
        self.localImage = [UIImage imageWithContentsOfFile:imagePath];
    } else if (imageBase64.length) {
        self.localImage = [UIImage pcs_imageWithBase64:imageBase64];
    }
    
    self.imageUrl = [dictionaryValue objectForKey:@"imageUrl"];
    
    BOOL needPlaceholder = [dictionaryValue[@"needPlaceholder"] boolValue];
    if (needPlaceholder) {
        NSString *loadingImageName = dictionaryValue[@"placeholderLoading"];
        self.loadingImage = (loadingImageName.length > 0 ? [UIImage imageNamed:loadingImageName] : nil) ?: [PicassoAppConfiguration instance].loadingImage;
        
        NSString *errorImageName = dictionaryValue[@"placeholderError"];
        self.errorImage = (errorImageName.length > 0 ? [UIImage imageNamed:errorImageName] : nil) ?: [PicassoAppConfiguration instance].errorImage;
    } else {
        self.loadingImage = nil;
        self.errorImage = nil;
    }
    self.gifLoopCount = [dictionaryValue[@"gifLoopCount"] integerValue];
    self.fadeEffect = [dictionaryValue[@"fadeEffect"] boolValue];
    self.cacheType = [dictionaryValue[@"cacheType"] integerValue];
    self.failedRetry = [dictionaryValue[@"failedRetry"] boolValue];
    self.blurRadius = [dictionaryValue[@"blurRadius"] floatValue];
}
@end
