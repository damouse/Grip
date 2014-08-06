//
//
// Group
// This is an object created by COBGIN
//
//
// by Mickey Barboi
//
//


#import "Group.h"

@implementation Group
@synthesize name;

#pragma mark Connection Manager
+ (RKObjectMapping *) mapping {
	//returns the mapping needed by RestKit to perform API calls
	RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[self class]];
	[mapping addAttributeMappingsFromDictionary:@{
	@"name": @"name"  }];

	return mapping;
}


#pragma mark NSCoding Protocol
-(void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:name forKey:@"name"];
}

- (id)initWithCoder:(NSCoder *)decoder {
	self = [super init];
	self.name = [decoder decodeObjectForKey:@"name"];
	return self;
}



@end