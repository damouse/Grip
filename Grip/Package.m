//
//
// Package
// This is an object created by COBGIN
//
//
// by Mickey Barboi
//
//


#import "Package.h"

@implementation Package
@synthesize name, discount, order_index, group_id, created_at, updated_at;

#pragma mark Connection Manager
+ (RKObjectMapping *) mapping {
	//returns the mapping needed by RestKit to perform API calls
	RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[self class]];
	[mapping addAttributeMappingsFromDictionary:@{
	@"name": @"name",
	@"discount": @"discount",
	@"order_index": @"order_index",
	@"group_id": @"group_id",
	@"created_at": @"created_at",
	@"updated_at": @"updated_at"  }];

	return mapping;
}


#pragma mark NSCoding Protocol
-(void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:name forKey:@"name"];
	[encoder encodeObject:discount forKey:@"discount"];
	[encoder encodeObject:order_index forKey:@"order_index"];
	[encoder encodeObject:group_id forKey:@"group_id"];
	[encoder encodeObject:created_at forKey:@"created_at"];
	[encoder encodeObject:updated_at forKey:@"updated_at"];
}

- (id)initWithCoder:(NSCoder *)decoder {
	self = [super init];
	self.name = [decoder decodeObjectForKey:@"name"];
	self.discount = [decoder decodeObjectForKey:@"discount"];
	self.order_index = [decoder decodeObjectForKey:@"order_index"];
	self.group_id = [decoder decodeObjectForKey:@"group_id"];
	self.created_at = [decoder decodeObjectForKey:@"created_at"];
	self.updated_at = [decoder decodeObjectForKey:@"updated_at"];
	return self;
}



@end