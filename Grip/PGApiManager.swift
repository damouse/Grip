
//
//  PGApiManager.swift
//  Grip
//
//  Created by Mickey Barboi on 8/6/14.
//  Copyright (c) 2014 Mickey Barboi. All rights reserved.
//

import Foundation
import UIKit

@objc class PGApiManager : NSObject {
    let base_url = "http://packagegrid.com/"
    
    
    func login() -> String {
        var man = AFHTTPRequestOperationManager(baseURL: NSURL(string: base_url))
        man.requestSerializer = AFJSONRequestSerializer()
        man.requestSerializer.setValue("application/json", forHTTPHeaderField: "Accept")
        

        return "yay!"
        
        
    }
    
    
    /*
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
    
    
    
    
    - (void) login;
    
    - (void) completeDeal;
*/
}