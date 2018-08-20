#import "LogBaseModel.h"
#import "Properties.h"
#import "SwitchHertz.h"
#import "SwitchSampleConfig.h"
#import "SwitchTypes.h"
#import "LogReportSwitchModel.h"
#import "SwitchProperty.h"

@interface LogBaseModel (Private)
- (void)setModelWithJSONDictionary:(NSDictionary *)dictionary;
@end

@implementation Properties
- (void)setModelWithJSONDictionary:(NSDictionary *)dictionary {
	[super setModelWithJSONDictionary:dictionary];
	self.value = [dictionary objectForKey:@"value"];
	self.key = [dictionary objectForKey:@"key"];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wcompare-distinct-pointer-types"
	if (self.value == [NSNull null]) { self.value = nil; }
	if (self.key == [NSNull null]) { self.key = nil; }
#pragma clang diagnostic pop
}

- (NSDictionary *)JSONDicionary {
	NSMutableDictionary *mDic = [[NSMutableDictionary alloc] initWithDictionary:[super JSONDicionary]];
	[mDic setValue:self.value forKey:@"value"];
	[mDic setValue:self.key forKey:@"key"];

	return mDic;
}
@end

@implementation SwitchHertz
- (void)setModelWithJSONDictionary:(NSDictionary *)dictionary {
	[super setModelWithJSONDictionary:dictionary];
	self.properties = [Properties modelArrayWithJSONDictionarys:[dictionary objectForKey:@"properties"]];
	self.type = [dictionary objectForKey:@"type"];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wcompare-distinct-pointer-types"
	if (self.type == [NSNull null]) { self.type = nil; }
#pragma clang diagnostic pop
}

- (NSDictionary *)JSONDicionary {
	NSMutableDictionary *mDic = [[NSMutableDictionary alloc] initWithDictionary:[super JSONDicionary]];
	[mDic setValue:[Properties JSONDicArray:self.properties] forKey:@"properties"];
	[mDic setValue:self.type forKey:@"type"];

	return mDic;
}
@end

@implementation SwitchSampleConfig
- (void)setModelWithJSONDictionary:(NSDictionary *)dictionary {
	[super setModelWithJSONDictionary:dictionary];
	self.sample = [dictionary objectForKey:@"sample"];
	self.uid = [dictionary objectForKey:@"id"];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wcompare-distinct-pointer-types"
	if (self.sample == [NSNull null]) { self.sample = nil; }
	if (self.uid == [NSNull null]) { self.uid = nil; }
#pragma clang diagnostic pop
}

- (NSDictionary *)JSONDicionary {
	NSMutableDictionary *mDic = [[NSMutableDictionary alloc] initWithDictionary:[super JSONDicionary]];
	[mDic setValue:self.sample forKey:@"sample"];
	[mDic setValue:self.uid forKey:@"id"];

	return mDic;
}
@end

@implementation SwitchTypes
- (void)setModelWithJSONDictionary:(NSDictionary *)dictionary {
	[super setModelWithJSONDictionary:dictionary];
	self.enable = [dictionary objectForKey:@"enable"];
	self.uid = [dictionary objectForKey:@"id"];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wcompare-distinct-pointer-types"
	if (self.enable == [NSNull null]) { self.enable = nil; }
	if (self.uid == [NSNull null]) { self.uid = nil; }
#pragma clang diagnostic pop
}

- (NSDictionary *)JSONDicionary {
	NSMutableDictionary *mDic = [[NSMutableDictionary alloc] initWithDictionary:[super JSONDicionary]];
	[mDic setValue:self.enable forKey:@"enable"];
	[mDic setValue:self.uid forKey:@"id"];

	return mDic;
}
@end

@implementation LogReportSwitchModel
- (void)setModelWithJSONDictionary:(NSDictionary *)dictionary {
	[super setModelWithJSONDictionary:dictionary];
	self.appProperties = [SwitchProperty modelArrayWithJSONDictionarys:[dictionary objectForKey:@"appProperties"]];
	self.hertz = [SwitchHertz modelArrayWithJSONDictionarys:[dictionary objectForKey:@"hertz"]];
	self.sampleConfig = [SwitchSampleConfig modelArrayWithJSONDictionarys:[dictionary objectForKey:@"sampleConfig"]];
	self.types = [SwitchTypes modelArrayWithJSONDictionarys:[dictionary objectForKey:@"types"]];
    
    self.configVersion = dictionary[@"configVersion"];
}

- (NSDictionary *)JSONDicionary {
	NSMutableDictionary *mDic = [[NSMutableDictionary alloc] initWithDictionary:[super JSONDicionary]];
	[mDic setValue:[SwitchProperty JSONDicArray:self.appProperties] forKey:@"appProperties"];
	[mDic setValue:[SwitchHertz JSONDicArray:self.hertz] forKey:@"hertz"];
	[mDic setValue:[SwitchSampleConfig JSONDicArray:self.sampleConfig] forKey:@"sampleConfig"];
	[mDic setValue:[SwitchTypes JSONDicArray:self.types] forKey:@"types"];

	return mDic;
}
@end

@implementation SwitchProperty
- (void)setModelWithJSONDictionary:(NSDictionary *)dictionary {
	[super setModelWithJSONDictionary:dictionary];
	self.content = [dictionary objectForKey:@"content"];
	self.configId = [dictionary objectForKey:@"configId"];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wcompare-distinct-pointer-types"
	if (self.content == [NSNull null]) { self.content = nil; }
	if (self.configId == [NSNull null]) { self.configId = nil; }
#pragma clang diagnostic pop
}

- (NSDictionary *)JSONDicionary {
	NSMutableDictionary *mDic = [[NSMutableDictionary alloc] initWithDictionary:[super JSONDicionary]];
	[mDic setValue:self.content forKey:@"content"];
	[mDic setValue:self.configId forKey:@"configId"];

	return mDic;
}
@end


