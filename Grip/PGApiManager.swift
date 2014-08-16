//
//  PGApiManager.swift
//  Grip
//
//  Created by Mickey Barboi on 8/6/14.
//  Copyright (c) 2014 Mickey Barboi. All rights reserved.

//TODO: reauth occasionally

import Foundation
import UIKit


@objc class PGApiManager : NSObject {
    let base_url = "http://packagegrid.com/"
    
    var user: User?
    var products = Array<Product>()
    var merchandises = Array<Merchandise>()
    var packages = Array<Package>()
    
    
    // MARK: Public Interface
    func logIn(email: String, password:String, success:(() -> Void)) -> Void {
        generateAuthenticatedClient().GET("api/v1/auth?user_email=\(email)&password=\(password)", parameters: nil,
            
            success: { ( operation: AFHTTPRequestOperation?, responseObject: AnyObject? ) in
                println("API: User Success")
                
                var error: NSError?
                self.user = MTLJSONAdapter.modelOfClass(User.self, fromJSONDictionary: responseObject as Dictionary<String, AnyObject>, error: &error) as? User
                
                //issue the rest of the download calls
                self.loadPackages()
                self.loadProducts()
                self.loadMerchandises()
                
                success()
            },
            
            failure: { ( operation: AFHTTPRequestOperation?, error: NSError? ) in
                print("failure- ")
                println(error)
        })
    }

    func loadProducts() -> Void {
        generateAuthenticatedClient().GET("dashboard/\(self.user!.group_id)/products", parameters: nil,
            
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
    
    func loadMerchandises() -> Void {
        generateAuthenticatedClient().GET("dashboard/\(self.user!.group_id)/merchandise", parameters: nil,
            
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
    
    func loadPackages() -> Void {
        generateAuthenticatedClient().GET("dashboard/\(self.user!.group_id)/packages", parameters: nil,
            
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