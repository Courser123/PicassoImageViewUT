#import <UIKit/UIKit.h>
@interface PCSJsonLabelBaseModel : NSObject
+ (instancetype)modelWithJSONDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)JSONDicionary;

+ (NSArray *)modelArrayWithJSONDictionarys:(NSArray *)array;
+ (NSArray *)JSONDicArray:(NSArray *)array;

@end
