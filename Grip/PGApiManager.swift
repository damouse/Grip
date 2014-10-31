//
//  PGApiManager.swift
//  Grip
//
//  Created by Mickey Barboi on 8/6/14.
//  Copyright (c) 2014 Mickey Barboi. All rights reserved.

//TODO: reauth occasionally

import Foundation
import UIKit

private let _singletonInstance = PGApiManager()

@objc class PGApiManager : NSObject {
    let base_url = "http://packagegrid.com/"
    
    var user: User?
    var products = NSArray()
    var merchandises = NSArray()
    var packages = NSArray()
    var customers = NSArray()
    
    var progressHUD: MBProgressHUD?
    
    //Singleton Accessor: Danger danger red ranger
    class var sharedInstance: PGApiManager {
        return _singletonInstance
    }
    
    
    //MARK: Public Interface
    func logInAttempt(email: String, password:String, view:UIView, success:(() -> Void)) -> Void {
        //wrapper function for issuing a login request from a controller, performs a login but shows the spinner

        showHUD(view)
        logIn(email, password: password, success: { () -> Void in
                self.getAllResourcesSequentially(success)
            }
        );
    }
    
    func loadPackagesForCustomer(customer: Customer, success:(() -> Void)) {
        //loads packages associated with the given customer and assigns them to the customer
        if customer.loadedPackages {
            success()
            return
        }
        
        self.loadPackages(customer.id, success: { (packages: AnyObject) -> Void in
            customer.packages = packages as [Package]
            success()
        })
    }
    
    func uploadReceipt(view: UIView, superview: UIView, receipt: Receipt, completion: (success: Bool) -> Void) {
//        showHUD(superview)
//        updateHUDText("Uploading Receipt Document")
//        
//        let pdfFactory = PDFFactory()
//        let uploader = S3FileManager()
//        
//        let data = pdfFactory.createPDFFromView(view)
//        uploader.uploadFile(data, name: "test.pdf", completion: {(success: Bool) -> () in
//            self.removeHUD()
//        })
        
        //convert the receipt object back into json
        
//        createReceipt(receipt, success: nil)
        
        
        
        //sequential, batched success tasks
        let pdfSuccess = { (success: Bool) -> Void in
            completion(success: success)
        }
        
        let receiptSuccess = {(success: Bool) -> Void in
            //receipt failed? return a fail
            if !success {
                completion(success: false)
                return
            }
            
            //call pdf task
        }
        
        let customerSuccess = {(success: Bool) -> Void in
            //customer failed? return a fail
            if !success {
                completion(success: false)
                return
            }
            
            //call reciept task
        }
        
        let merchandiseSuccess = {(success: Bool) -> Void in
            //merchandise failed? return a fail
            if !success {
                completion(success: false)
                return
            }
            
            //call customer task
        }
        
        //check if customer needs to be created
        if receipt.merchandise_receipt?.product == nil {
            createCustomer(receipt.customer!, success: customerSuccess)
        }
        
        if receipt.customer_id == -1 {
            createCustomer(receipt.customer!, success: customerSuccess)
        }
    }
    
    
    //MARK: Model Helper Methods
    func findProductById(id:Int) -> Product? {
        var ret: Product?
        
        for product in self.products {
            if (product as Product).id == id {
                return product as? Product
            }
        }
        
        return ret
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
        
        progressHUD?.mode = MBProgressHUDModeCustomView
        progressHUD?.customView = GripSpinner(frame: CGRectMake(0, 0, 37, 37))
    }
    
    func removeHUD() {
        //check to see if the HUD is actually present!
        progressHUD?.hide(true)
    }
    
    func updateHUDText(newText:String) {
        progressHUD?.detailsLabelText = newText
    }
    
    
    //MARK: Batch Tasks
    func getAllResourcesSequentially(success:(() -> Void)) {
        //gets all of the resources sequentially-- waits for the previous one to finished before starting the next
        
        //success blocks
        let packageSuccess = { (packages: AnyObject) -> Void in
            self.packages = packages as NSArray
            self.removeHUD()
            success()
        }
        
        let productSuccess = { () -> Void in
            self.loadPackages(self.user!.group_id, packageSuccess)
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
    
    
    // MARK: Download
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
                self.products = self.serializeObjects(responseObject!, jsonKey: "products", objectClass: Product.self)
                success?()
                
                //after calling success on products, go ahead and load the images for each product in the background
                for product in self.products {
                    self.loadImage(product as Product)
                }
            },
            
            failure: { ( operation: AFHTTPRequestOperation?, error: NSError? ) in
                print("failure- ")
                println(error)
                println(operation)
        })
    }
    
    func loadMerchandises(success:(() -> Void)?) -> Void {
        updateHUDText("Updating Merchandise")
        
        generateAuthenticatedClient().GET("dashboard/\(self.user!.group_id)/merchandise", parameters: nil,
            
            success: { ( operation: AFHTTPRequestOperation?, responseObject: AnyObject? ) in
                self.merchandises = self.serializeObjects(responseObject!, jsonKey: "merchandises", objectClass: Product.self)
                
                for merchandise in self.merchandises {
                    self.loadImage(merchandise as Product)
                }
                
                success?()
            },
            
            failure: { ( operation: AFHTTPRequestOperation?, error: NSError? ) in
                print("failure- ")
                println(error)
        })
    }
    
    func loadPackages(id:Int, success:((AnyObject) -> Void)?) -> Void {
        updateHUDText("Updating Packages")
        
        generateAuthenticatedClient().GET("dashboard/\(id)/packages", parameters: nil,
            
            success: { ( operation: AFHTTPRequestOperation?, responseObject: AnyObject? ) in
                //self.packages = self.serializeObjects(responseObject!, jsonKey: "packages", objectClass: Package.self)
                var packages = self.serializeObjects(responseObject!, jsonKey: "packages", objectClass: Package.self)
                
                //Christ this hurts me to look at
                var rawPackages = responseObject! as [String:AnyObject]
                var unwrappedPackages: AnyObject? = rawPackages["packages"]!
                var packagesArray = unwrappedPackages! as [[String:AnyObject]]
                
                //Manually pair products to packages by comparing ids. Maybe a little rough, but it beats redundantly creating products
                for var i = 0; i < packagesArray.count; i++ {
                    let products: AnyObject? = packagesArray[i]["products"]
                    let productsArray = products! as [[String:AnyObject]]
                    
                    let package = packages[i] as Package
                    
                    for product in productsArray {
                        
                        let productID: AnyObject? = product["id"]
                        let ret = self.findProductById(productID as Int)
                        
                        if let un = ret {
                            package.products.append(un as Product)
                        }
                    }
                }
                
                success?(packages)
            },
            
            failure: { ( operation: AFHTTPRequestOperation?, error: NSError? ) in
                print("failure- ")
                println(error)
        })
    }
    
    func loadCustomers(success:(() -> Void)?) -> Void {
        updateHUDText("Updating Customers")
        
        generateAuthenticatedClient().GET("dashboard/\(self.user!.group_id)/customers", parameters: nil,
            
            success: { ( operation: AFHTTPRequestOperation?, responseObject: AnyObject? ) in
                self.customers = self.serializeObjects(responseObject!, jsonKey: "customers", objectClass: Customer.self)
                success?()
            },
            
            failure: { ( operation: AFHTTPRequestOperation?, error: NSError? ) in
                print("failure- ")
                println(error)
                println(operation)
        })
        
        println("API: Customer Success")
    }
    
    
    //MARK: Upload
    func createCustomer(customer: Customer, success:(success: Bool) -> Void) {
        
    }
    
    func createMerchandise(merch: Product, success:(success: Bool) -> Void) {
        
    }
    
    func createReceipt(receipt: Receipt, success:(success: Bool) -> Void) {
        updateHUDText("Uploading Receipt")
        let json = MTLJSONAdapter.JSONDictionaryFromModel(receipt)
        
        generateAuthenticatedClient().POST("dashboard/\(user!.id)/receipts", parameters: json,
            
            success: { ( operation: AFHTTPRequestOperation?, responseObject: AnyObject? ) in
                println("API: User Success")
                
                println(responseObject)
                
                success()
            },
            
            failure: { ( operation: AFHTTPRequestOperation?, error: NSError? ) in
                print("failure- ")
                println(error)
        })
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
        println("API: \(jsonKey) Success")
        println(responseObject)
        var error: NSError?
        let cocoaArray: NSArray = MTLJSONAdapter.modelsOfClass(objectClass, fromJSONArray: (responseObject as NSDictionary).objectForKey(jsonKey) as NSArray, error: &error) as NSArray
        return cocoaArray
    }
    
    func loadImage(product: Product) {
        //async call to load an image using AFNetworking
        let request = NSURLRequest(URL: NSURL(string: product.image_url!))
        var operation = AFHTTPRequestOperation(request: request)
        operation.responseSerializer = AFImageResponseSerializer()
        
        operation.setCompletionBlockWithSuccess({ (operation: AFHTTPRequestOperation!, object: AnyObject!) -> Void in
                product.image = object as? UIImage
                product.desaturatedImage = product.image!.desaturate()
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) ->Void in
                product.image = UIImage(named: "Placeholder")
                product.desaturatedImage = product.image!.desaturate()
                
                println("Image failure for product \(product.name)")
                println(error)
        })
        
        operation.start()
    }
}