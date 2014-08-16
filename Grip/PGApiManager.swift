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
//
// TODO: 
// Must construct a cacheing scheme!
// Note also the absence of groups. Cache the incoming objects behind the user object somehow
// Backend is responsible for sending the right items, the app just functions as a listener for those objects. I.E. Inherited model objects (from old groups, etc)

import Foundation
import UIKit


@objc class PGApiManager : NSObject {
    let base_url = "http://packagegrid.com/"
    
    var user: User?
    var products = Array<Product>()
    var merchandises = Array<Merchandise>()
    var packages = Array<Package>()
    
    
    // MARK: Public Interface
    func auth() -> Void {
        generateAuthenticatedClient().GET("api/v1/auth?user_email=test@test.com&password=12345678", parameters: nil,
            success: { ( operation: AFHTTPRequestOperation?, responseObject: AnyObject? ) in
                println("API: User Success")
                var error: NSError?
                
                //WARNING-- not checking type of responseObject before unpacking to dictionary-- will crash at runtime if a dictionary is not passed in!
                self.user = MTLJSONAdapter.modelOfClass(User.self, fromJSONDictionary: responseObject as Dictionary<String, AnyObject>, error: &error) as? User
                
                self.packages(self.user!)
            },
            failure: { ( operation: AFHTTPRequestOperation?, error: NSError? ) in
                print("failure- ")
                println(error)
        })
    }

    func products(user: User) -> Void {
        generateAuthenticatedClient().GET("dashboard/\(user.group_id)/products", parameters: nil,
            
            success: { ( operation: AFHTTPRequestOperation?, responseObject: AnyObject? ) in
                println("API: Products Success")
                
                var error: NSError?
                let cocoaArray: NSArray = MTLJSONAdapter.modelsOfClass(Product.self, fromJSONArray: (responseObject as NSDictionary).objectForKey("products") as NSArray, error: &error) as NSArray
                
                //'cast' the NSArray to a swift array. There must be a cleaner way of doing this...
                for product in cocoaArray {
                    self.products.append(product as Product)
                }
            },
            
            failure: { ( operation: AFHTTPRequestOperation?, error: NSError? ) in
                print("failure- ")
                println(error)
        })
    }
    
    func merchandises(user: User) -> Void {
        generateAuthenticatedClient().GET("dashboard/\(user.group_id)/merchandise", parameters: nil,
            
            success: { ( operation: AFHTTPRequestOperation?, responseObject: AnyObject? ) in
                println("API: Merchandise Success")
                
                var error: NSError?
                let cocoaArray: NSArray = MTLJSONAdapter.modelsOfClass(Merchandise.self, fromJSONArray: (responseObject as NSDictionary).objectForKey("merchandises") as NSArray, error: &error) as NSArray
                
                //'cast' the NSArray to a swift array. There must be a cleaner way of doing this...
                for product in cocoaArray {
                    self.merchandises.append(product as Merchandise)
                }
            },
            
            failure: { ( operation: AFHTTPRequestOperation?, error: NSError? ) in
                print("failure- ")
                println(error)
        })
    }
    
    func packages(user: User) -> Void {
        generateAuthenticatedClient().GET("dashboard/\(user.group_id)/packages", parameters: nil,
            
            success: { ( operation: AFHTTPRequestOperation?, responseObject: AnyObject? ) in
                println("API: Package Success")
                
                var error: NSError?
                let cocoaArray: NSArray = MTLJSONAdapter.modelsOfClass(Package.self, fromJSONArray: (responseObject as NSDictionary).objectForKey("packages") as NSArray, error: &error) as NSArray

                for product in cocoaArray {
                    self.packages.append(product as Package)
                }
            },
            
            failure: { ( operation: AFHTTPRequestOperation?, error: NSError? ) in
                print("failure- ")
                println(error)
        })
    }
    
    func customers() -> Void {
        
    }
    
    
    //MARK: Internal Methods
    //Returns an authenticated, ready to go AFHTTPManager. If a user is not currently signed in, the 
    //authentication fields will silently NOT be filled!
    func generateAuthenticatedClient() -> AFHTTPRequestOperationManager {
        var client = AFHTTPRequestOperationManager(baseURL: NSURL(string: base_url))
        client.requestSerializer = AFJSONRequestSerializer()
        client.requestSerializer.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if user != nil {
            client.requestSerializer.setValue(String(user!.id), forHTTPHeaderField: "X-USER-ID")
            client.requestSerializer.setValue(user?.authentication_token, forHTTPHeaderField: "X-AUTHENTICATION-TOKEN")
        }
        
        return client
    }
}