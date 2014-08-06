//
//  PGApiManager.m
//  Grip
//
//  Created by Mickey Barboi on 8/6/14.
//  Copyright (c) 2014 Mickey Barboi. All rights reserved.
//

#import "PGApiManager.h"
#import "User.h"
#import <AFNetworking/AFNetworking.h>


@interface PGApiManager() {
    NSString *base_url;
}

@end


@implementation PGApiManager

#pragma mark Initialization
+ (PGApiManager *) manager {
    // Persistent instance.
    static PGApiManager *conMan = nil;
    
    if (conMan != nil)
        return conMan;
    
    static dispatch_once_t safer;
    dispatch_once(&safer, ^(void) {
      conMan = [[PGApiManager alloc] init];
  });
    
    return conMan;
}

- (id) init {
    self =[super init];
    
    base_url = @"http://packagegrid.com/";
    
    return self;
}


#pragma mark Public interface
- (void) login {
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager manager] initWithBaseURL:[NSURL URLWithString:base_url]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    [manager GET:@"api/v1/auth?user_email=test@test.com&password=12345678" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSError *error;
        User *user = [MTLJSONAdapter modelOfClass:[User class] fromJSONDictionary:(NSDictionary *) responseObject error:&error];
        
        if (error) {
            NSLog(@"Couldn't convert app infos JSON to ChoosyAppInfo models: %@", error);
        }
        
        NSLog(@"User: %@", user.name);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}



@end
