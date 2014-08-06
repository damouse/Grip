//
//  PGApiManager.swift
//  Grip
//
//  Created by Mickey Barboi on 8/6/14.
//  Copyright (c) 2014 Mickey Barboi. All rights reserved.
//
// Public interface
//        currentUser -> User
//            Returns the currently signed in, authenticated user. If there is no user cached, nil is returned.
//            If there is a user in the cache present but with an expired/invalid token, opaquely refresh the token and 
//            return the user
//
//        products -> Array
//            Return the loaded products as an array
//
//        packages -> Array
//            Return the loaded products as an array
//
//        customers -> Array
//            Returns an array of customers
//
//        completeDeal(Package, [SigningObject]) -> Void
//            Given the salesperson, the customer, and the package that was created, create and upload a signing object, calling back 
//            once completed. 

// NOTE: Must construct a cacheing scheme!


import Foundation
import UIKit


@objc class PGApiManager : NSObject {
    let base_url = "http://packagegrid.com/"
    
    var user: User?
    
    
    func login() -> Void {
        var client = AFHTTPRequestOperationManager(baseURL: NSURL(string: base_url))
        client.requestSerializer = AFJSONRequestSerializer()
        client.requestSerializer.setValue("application/json", forHTTPHeaderField: "Accept")

        client.GET("api/v1/auth?user_email=test@test.com&password=12345678", parameters: nil,
            success: { ( operation: AFHTTPRequestOperation?, responseObject: AnyObject? ) in
                print("success- ")
                var error: NSError?
                
                //WARNING-- not checking type of responseObject before unpacking to dictionary-- will crash at runtime if a dictionary is not passed in!
                var user: User = MTLJSONAdapter.modelOfClass(User.self, fromJSONDictionary: responseObject as Dictionary<String, AnyObject>, error: &error) as User
                println(user)
                
                self.user = user

            },
            failure: { ( operation: AFHTTPRequestOperation?, error: NSError? ) in
                print("failure- ")
                println(error)
        })
    }
    
    
}