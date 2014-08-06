//
//
// Merchandise
// This is an object created by COBGIN
//
//
// by Mickey Barboi
//
//


@interface Merchandise : NSObject

@property (strong, nonatomic) NSString * name;
@property (strong, nonatomic) NSString * description;
@property (strong, nonatomic) NSString * group_id;
@property (strong, nonatomic) NSString * order_index;
@property (strong, nonatomic) NSNumber * price;
@property (strong, nonatomic) NSString * created_at;
@property (strong, nonatomic) NSString * updated_at;
@property (strong, nonatomic) NSString * image_file_name;
@property (strong, nonatomic) NSString * image_updated_at;

+ (RKObjectMapping *) mapping;

@end