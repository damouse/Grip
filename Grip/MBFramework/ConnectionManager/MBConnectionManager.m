//
//  MBConnectionManager.m
//  Culvers
//
//  Created by Mickey Barboi on 7/23/13.
//  Copyright (c) 2013 HardinDD. All rights reserved.
//

/**
 v2.0
 
 This class will do three things
 
 - leverage RK to load objects from an API with one line and send them in the same way 
 - use AF to replace the NSURLConnection functionality of MBCM v1.0
 - miscelanious: manage MBHUD for children, cache objects if necesary, connect to Core Data to store objects, etc
 
 NOTE: DOCUMENTATION IS EXTERNAL. If your name is Mickey and you forgot this, then check Drive. If your name is 
 not Mickey and you want to see the notes, go ahead and ask mickey
 */

#import "MBConnectionManager.h"

@implementation MBConnectionManager

#pragma mark Initialization
+ (MBConnectionManager *) manager {
    // Persistent instance.
    static MBConnectionManager *conMan = nil;
    
    if (conMan != nil)
        return conMan;
    
    static dispatch_once_t safer;
    dispatch_once(&safer, ^(void)
                  {
                      conMan = [[MBConnectionManager alloc] init];
                      // private initialization goes here.
                  });
    
    return conMan;
}

- (void) test {
//    // Set up Article and Error Response Descriptors
//    // Successful JSON looks like {"article": {"title": "My Article", "author": "Blake", "body": "Very cool!!"}}
//    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[Article class]];
//    [mapping addAttributeMappingsFromArray:@[@"title", @"author", @"body"]];
//    NSIndexSet *statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful); // Anything in 2xx
//    RKResponseDescriptor *articleDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:RKRequestMethodAny pathPattern:@"/articles" keyPath:@"article" statusCodes:statusCodes];
//    
//    // Error JSON looks like {"errors": "Some Error Has Occurred"}
//    RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[RKErrorMessage class]];
//    // The entire value at the source key path containing the errors maps to the message
//    [errorMapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:nil toKeyPath:@"errorMessage"]];
//    NSIndexSet *statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassClientError);
//    // Any response in the 4xx status code range with an "errors" key path uses this mapping
//    RKResponseDescriptor *errorDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:errorMapping method:RKRequestMethodAny pathPattern:nil keyPath:@"errors" statusCodes:statusCodes];
//    
//    // Add our descriptors to the manager
//    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://restkit.org"]];
//    [manager addResponseDescriptorsFromArray:@[ articleDescriptor, errorDescriptor ]];
//    
//    [manager getObjectsAtPath:@"/articles/555.json" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
//        // Handled with articleDescriptor
//    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
//        // Transport error or server error handled by errorDescriptor
//    }];
}

- (void) login {
    NSURL *url = [NSURL URLWithString:@"http://packagegrid.com/api/v1/auth?user_email=test@test.com&password=12345678"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"App.net Global Stream: %@", JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        NSLog(@"Failed. %@", JSON);
    }];
    [operation start];
}

#pragma mark RestKit Requests
//- (void) apiRequestWithMapping:(RKObjectMapping *)mapping atURL:(NSString *)url withKeyPath:(NSString *)path success:(void (^)(RKMappingResult *))success fail:(void (^)(NSError *))failure {
//    //this makes an API request with the given descriptor with the given success/failure blocks
//    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping pathPattern:nil keyPath:path statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
//    
//    NSURL *URL = [NSURL URLWithString:url];
//    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
//    
//    //RKLogConfigureByName("RestKit", RKLogLevelWarning);
//    //RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
//   //RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);
//    RKLogConfigureByName("*", RKLogLevelOff)
//    
//    //WHAT HAPPN
//    RKObjectRequestOperation *objectRequestOperation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[ responseDescriptor ]];
//    
//    [objectRequestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
//        ALog(@"CM: api call success");
//        
//        success(mappingResult);
//    }
//    
//    failure:^(RKObjectRequestOperation *operation, NSError *error) {
//        ALog(@"CM: api call failure");
//        
//        //allow callees to skip this if needed
//        if(failure != nil)
//            failure(error);
//    }];
//    
//    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://restkit.org"]];
//    [manager enqueueObjectRequestOperation:objectRequestOperation];
//    
//}


#pragma mark RestKit Submits
@end
