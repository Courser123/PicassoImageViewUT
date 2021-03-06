#import "PCSJsonLabelBaseModel.h"

@implementation PCSJsonLabelBaseModel
+ (instancetype)modelWithJSONDictionary:(NSDictionary *)dictionary {
	if (![dictionary isKindOfClass:[NSDictionary class]]) return [self new];
	PCSJsonLabelBaseModel *model = [self new];
	[model setModelWithJSONDictionary:dictionary];
	return model;
}

- (NSDictionary *)JSONDicionary {
	return [NSDictionary new];
}

+ (NSArray *)modelArrayWithJSONDictionarys:(NSArray *)array {
	if (![array isKindOfClass:[NSArray class]]) return [NSArray new];
	NSMutableArray *mArray = [NSMutableArray new];
	for (NSDictionary *dic in array) {
		if (![dic isKindOfClass:[NSDictionary class]]) continue;
		[mArray addObject:[self modelWithJSONDictionary:dic]];
	}
	return mArray;
}

+ (NSArray *)JSONDicArray:(NSArray *)array {
	NSMutableArray *mArray = [NSMutableArray new];
	for (PCSJsonLabelBaseModel *model in array) {
		[mArray addObject:[model JSONDicionary]];
	}
	return mArray;
}

- (void)setModelWithJSONDictionary:(NSDictionary *)dictionary {
}

@end
