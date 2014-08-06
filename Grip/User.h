//
//
// User
// This is an object created by COBGIN
//
//
// by Mickey Barboi
//
//


@interface User : NSObject

@property (strong, nonatomic) NSString * name;
@property (strong, nonatomic) NSString * group_id;
@property (strong, nonatomic) NSString * email;
@property (strong, nonatomic) NSString * authentication_token;
@property (strong, nonatomic) NSString * token_expiration;
@property (strong, nonatomic) NSString * created_at;
@property (strong, nonatomic) NSString * updated_at;

+ (RKObjectMapping *) mapping;

@end