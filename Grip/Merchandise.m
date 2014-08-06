//
//
// Merchandise
// This is an object created by COBGIN
//
//
// by Mickey Barboi
//
//


#import "Merchandise.h"

@implementation Merchandise
@synthesize name, description, group_id, order_index, price, created_at, updated_at, image_file_name, image_updated_at;

#pragma mark Connection Manager
//+ (RKObjectMapping *) mapping {
//	//returns the mapping needed by RestKit to perform API calls
//	RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[self class]];
//	[mapping addAttributeMappingsFromDictionary:@{
//	@"name": @"name",
//	@"description": @"description",
//	@"group_id": @"group_id",
//	@"order_index": @"order_index",
//	@"price": @"price",
//	@"created_at": @"created_at",
//	@"updated_at": @"updated_at",
//	@"image_file_name": @"image_file_name",
//	@"image_content_type": @"image_content_type",
//	@"image_file_size": @"image_file_size",
//	@"image_updated_at": @"image_updated_at"  }];
//
//	return mapping;
//}


#pragma mark NSCoding Protocol
-(void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:name forKey:@"name"];
	[encoder encodeObject:description forKey:@"description"];
	[encoder encodeObject:group_id forKey:@"group_id"];
	[encoder encodeObject:order_index forKey:@"order_index"];
	[encoder encodeObject:price forKey:@"price"];
	[encoder encodeObject:created_at forKey:@"created_at"];
	[encoder encodeObject:updated_at forKey:@"updated_at"];
	[encoder encodeObject:image_file_name forKey:@"image_file_name"];
	[encoder encodeObject:image_updated_at forKey:@"image_updated_at"];
}

- (id)initWithCoder:(NSCoder *)decoder {
	self = [super init];
	self.name = [decoder decodeObjectForKey:@"name"];
	self.description = [decoder decodeObjectForKey:@"description"];
	self.group_id = [decoder decodeObjectForKey:@"group_id"];
	self.order_index = [decoder decodeObjectForKey:@"order_index"];
	self.price = [decoder decodeObjectForKey:@"price"];
	self.created_at = [decoder decodeObjectForKey:@"created_at"];
	self.updated_at = [decoder decodeObjectForKey:@"updated_at"];
	self.image_file_name = [decoder decodeObjectForKey:@"image_file_name"];
	self.image_updated_at = [decoder decodeObjectForKey:@"image_updated_at"];
	return self;
}



@end