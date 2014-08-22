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
    var products = NSArray()
    var merchandises = Array<Product>()
    var packages = Array<Package>()
    
    var progressHUD: MBProgressHUD?
    
    
    //MARK: Public Interface
    func logInAttempt(email: String, password:String, view:UIView, success:(() -> Void)) -> Void {
        //wrapper function for issuing a login request from a controller, performs a login but shows the spinner

        showHUD(view)
        logIn(email, password: password, success: { () -> Void in
                self.getAllResourcesSequentially()
                success()
            }
        );
    }
    
    
    // MARK: ProgressHUD methods
    func showHUD(view:UIView) {
        progressHUD = MBProgressHUD.showHUDAddedTo(view, animated: true)
        progressHUD?.dimBackground = true
        progressHUD?.minShowTime = 1
        progressHUD?.removeFromSuperViewOnHide = true
        progressHUD?.detailsLabelFont = UIFont(name:"Titillium", size: 16)
        progressHUD?.labelFont = UIFont(name:"Titillium", size: 20)
        progressHUD?.labelText = "Connecting to Server"
        progressHUD?.detailsLabelText = ""
        
    }
    
    func removeHUD() {
        //check to see if the HUD is actually present!
        progressHUD?.hide(true)
    }
    
    func updateHUDText(newText:String) {
        progressHUD?.detailsLabelText = newText
    }
    
    
    //MARK: Batch Tasks
    func getAllResourcesSequentially() {
        //gets all of the resources sequentially-- waits for the previous one to finished before starting the next
        
        //success blocks
        let packageSuccess = { () -> Void in
            self.removeHUD()
        }
        
        let productSuccess = { () -> Void in
            self.loadPackages(packageSuccess)
        }
        
        let merchandiseSuccess = { () -> Void in
            self.loadProducts(productSuccess)
        }
        
        let customerSuccess = { () -> Void in
            self.loadMerchandises(merchandiseSuccess)
        }
        
        //Kick off the daisy chain
        loadCustomers(customerSuccess)
    }
    
    
    // MARK: Calls
    func logIn(email: String, password:String, success:(() -> Void)?) -> Void {
        updateHUDText("Logging in")
        
        generateAuthenticatedClient().GET("api/v1/auth?user_email=\(email)&password=\(password)", parameters: nil,
            
            success: { ( operation: AFHTTPRequestOperation?, responseObject: AnyObject? ) in
                println("API: User Success")
                
                var error: NSError?
                self.user = MTLJSONAdapter.modelOfClass(User.self, fromJSONDictionary: responseObject as Dictionary<String, AnyObject>, error: &error) as? User
                
                success?()
            },
            
            failure: { ( operation: AFHTTPRequestOperation?, error: NSError? ) in
                print("failure- ")
                println(error)
        })
    }

    func loadProducts(success:(() -> Void)?) -> Void {
        updateHUDText("Updating Products")
        
        generateAuthenticatedClient().GET("dashboard/\(self.user!.group_id)/products", parameters: nil,
            
            success: { ( operation: AFHTTPRequestOperation?, responseObject: AnyObject? ) in
                println("API: Products Success")
                
                self.products = self.serializeObjects(responseObject!, jsonKey: "products", objectClass: Product.self)
                
                success?()
            },
            
            failure: { ( operation: AFHTTPRequestOperation?, error: NSError? ) in
                print("failure- ")
                println(error)
        })
    }
    
    func loadMerchandises(success:(() -> Void)?) -> Void {
        updateHUDText("Updating Merchandise")
        
        generateAuthenticatedClient().GET("dashboard/\(self.user!.group_id)/merchandise", parameters: nil,
            
            success: { ( operation: AFHTTPRequestOperation?, responseObject: AnyObject? ) in
                println("API: Merchandise Success")
                
                var error: NSError?
                let cocoaArray: NSArray = MTLJSONAdapter.modelsOfClass(Product.self, fromJSONArray: (responseObject as NSDictionary).objectForKey("merchandises") as NSArray, error: &error) as NSArray
                
                //'cast' the NSArray to a swift array. There must be a cleaner way of doing this...
                for product in cocoaArray {
                    self.merchandises.append(product as Product)
                }
                
                success?()
            },
            
            failure: { ( operation: AFHTTPRequestOperation?, error: NSError? ) in
                print("failure- ")
                println(error)
        })
    }
    
    func loadPackages(success:(() -> Void)?) -> Void {
        updateHUDText("Updating Packages")
        
        generateAuthenticatedClient().GET("dashboard/\(self.user!.group_id)/packages", parameters: nil,
            
            success: { ( operation: AFHTTPRequestOperation?, responseObject: AnyObject? ) in
                println("API: Package Success")
                
                var error: NSError?
                let cocoaArray: NSArray = MTLJSONAdapter.modelsOfClass(Package.self, fromJSONArray: (responseObject as NSDictionary).objectForKey("packages") as NSArray, error: &error) as NSArray

                for product in cocoaArray {
                    self.packages.append(product as Package)
                }
                
                success?()
            },
            
            failure: { ( operation: AFHTTPRequestOperation?, error: NSError? ) in
                print("failure- ")
                println(error)
        })
    }
    
    func loadCustomers(success:(() -> Void)?) -> Void {
        updateHUDText("Updating Customers")
        
        println("API: Customer Success")
        success?()
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
    
    func serializeObjects(responseObject:AnyObject, jsonKey:String, objectClass:AnyClass) -> NSArray {
        println("API: Products Success")
        var error: NSError?
        let cocoaArray: NSArray = MTLJSONAdapter.modelsOfClass(objectClass, fromJSONArray: (responseObject as NSDictionary).objectForKey(jsonKey) as NSArray, error: &error) as NSArray
        return cocoaArray
    }
}