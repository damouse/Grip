
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
    
    
    func login() -> Void {
        var man = AFHTTPRequestOperationManager(baseURL: NSURL(string: base_url))
        man.requestSerializer = AFJSONRequestSerializer()
        man.requestSerializer.setValue("application/json", forHTTPHeaderField: "Accept")

        //Issue the call
        man.GET("api/v1/auth?user_email=test@test.com&password=12345678", parameters: nil,
            success: { ( operation: AFHTTPRequestOperation?, responseObject: AnyObject? ) in
                print("success- ")
                var error: NSError?
                
                //WARNING-- not checking type of responseObject before unpacking to dictionary-- will crash at runtime if a dictionary is not passed in!
                var user: User = MTLJSONAdapter.modelOfClass(User.self, fromJSONDictionary: responseObject as Dictionary<String, AnyObject>, error: &error) as User
                println(user)

            },
            failure: { ( operation: AFHTTPRequestOperation?, error: NSError? ) in
                print("failure- ")
                println(error)
        })
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