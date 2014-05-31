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


#pragma mark RestKit Requests
- (void) apiRequestWithMapping:(RKObjectMapping *)mapping atURL:(NSString *)url withKeyPath:(NSString *)path success:(void (^)(RKMappingResult *))success fail:(void (^)(NSError *))failure {
    //this makes an API request with the given descriptor with the given success/failure blocks
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping pathPattern:nil keyPath:path statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    NSURL *URL = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    //RKLogConfigureByName("RestKit", RKLogLevelWarning);
    //RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
   //RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);
    RKLogConfigureByName("*", RKLogLevelOff)
    
    //WHAT HAPPN
    RKObjectRequestOperation *objectRequestOperation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[ responseDescriptor ]];
    
    [objectRequestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        ALog(@"CM: api call success");
        
        success(mappingResult);
    }
    
    failure:^(RKObjectRequestOperation *operation, NSError *error) {
        ALog(@"CM: api call failure");
        
        //allow callees to skip this if needed
        if(failure != nil)
            failure(error);
    }];
    
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://restkit.org"]];
    [manager enqueueObjectRequestOperation:objectRequestOperation];
    
}


#pragma mark RestKit Submits
@end
