#import "MBConnectionManager.h"
#import "User.h"
#import "Product.h"
#import "Merchandise.h"
#import "Package.h"
#import "Group.h"

@implementation MBConnectionManager

//#pragma mark Initialization
//+ (MBConnectionManager *) manager {
//	static MBConnectionManager *conMan = nil;
//	if (conMan != nil) return conMan;
//
//	static dispatch_once_t safer;
//
//	dispatch_once(&safer, ^(void) {
//		conMan = [[MBConnectionManager alloc] init];
//	});
//
//	return conMan
//
//}
//
//#pragma mark Requests
//- (void) API_User_get_success:(void (^)(RKMappingResult *))success fail:(void (^)(NSError *))failure {
//	[self apiRequestWithMapping:[User mapping] success:success fail:failure]; 
//}
//
//- (void) API_Product_get_success:(void (^)(RKMappingResult *))success fail:(void (^)(NSError *))failure {
//	[self apiRequestWithMapping:[Product mapping] success:success fail:failure]; 
//}
//
//- (void) API_Merchandise_get_success:(void (^)(RKMappingResult *))success fail:(void (^)(NSError *))failure {
//	[self apiRequestWithMapping:[Merchandise mapping] success:success fail:failure]; 
//}
//
//- (void) API_Package_get_success:(void (^)(RKMappingResult *))success fail:(void (^)(NSError *))failure {
//	[self apiRequestWithMapping:[Package mapping] success:success fail:failure]; 
//}
//
//- (void) API_Group_get_success:(void (^)(RKMappingResult *))success fail:(void (^)(NSError *))failure {
//	[self apiRequestWithMapping:[Group mapping] success:success fail:failure]; 
//}
//
//- (void) API_int_get_success:(void (^)(RKMappingResult *))success fail:(void (^)(NSError *))failure {
//	[self apiRequestWithMapping:[int mapping] success:success fail:failure]; 
//}
//
//- (void) API_str_get_success:(void (^)(RKMappingResult *))success fail:(void (^)(NSError *))failure {
//	[self apiRequestWithMapping:[str mapping] success:success fail:failure]; 
//}

@end
