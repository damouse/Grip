//
//
// User
// This is an object created by COBGIN
//
//
// by Mickey Barboi
//
//


#import "User.h"

@implementation User
@synthesize name, group_id, email, authentication_token, token_expiration, created_at, updated_at;

#pragma mark Connection Manager
+ (RKObjectMapping *) mapping {
	//returns the mapping needed by RestKit to perform API calls
	RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[self class]];
	[mapping addAttributeMappingsFromDictionary:@{
	@"name": @"name",
	@"group_id": @"group_id",
	@"email": @"email",
	@"authentication_token": @"authentication_token",
	@"token_expiration": @"token_expiration",
	@"created_at": @"created_at",
	@"updated_at": @"updated_at"  }];

	return mapping;
}


#pragma mark NSCoding Protocol
-(void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:name forKey:@"name"];
	[encoder encodeObject:group_id forKey:@"group_id"];
	[encoder encodeObject:email forKey:@"email"];
	[encoder encodeObject:authentication_token forKey:@"authentication_token"];
	[encoder encodeObject:token_expiration forKey:@"token_expiration"];
	[encoder encodeObject:created_at forKey:@"created_at"];
	[encoder encodeObject:updated_at forKey:@"updated_at"];
}

- (id)initWithCoder:(NSCoder *)decoder {
	self = [super init];
	self.name = [decoder decodeObjectForKey:@"name"];
	self.group_id = [decoder decodeObjectForKey:@"group_id"];
	self.email = [decoder decodeObjectForKey:@"email"];
	self.authentication_token = [decoder decodeObjectForKey:@"authentication_token"];
	self.token_expiration = [decoder decodeObjectForKey:@"token_expiration"];
	self.created_at = [decoder decodeObjectForKey:@"created_at"];
	self.updated_at = [decoder decodeObjectForKey:@"updated_at"];
	return self;
}



@end