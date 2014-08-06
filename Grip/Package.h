//
//
// Package
// This is an object created by COBGIN
//
//
// by Mickey Barboi
//
//


@interface Package : NSObject

@property (strong, nonatomic) NSString * name;
@property (strong, nonatomic) NSNumber *  discount;
@property (strong, nonatomic) NSString *  order_index;
@property (strong, nonatomic) NSString *  group_id;
@property (strong, nonatomic) NSString * created_at;
@property (strong, nonatomic) NSString * updated_at;

+ (RKObjectMapping *) mapping;

@end