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
//    let base_url = "http://192.168.79.166:3000/"
    
    
    var user: User?
    var products = NSArray()
    var merchandises = NSArray()
    var packages = NSArray()
    var customers = NSArray()
    
    var progressHUD: MBProgressHUD?
    
    //Singleton Accessor: DANGER DANGER RED RANGER
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
    
//    func loadPackagesForCustomer(customer: Customer, success:(() -> Void)) {
//        //loads packages associated with the given customer and assigns them to the customer
//        if customer.loadedPackages {
//            success()
//            return
//        }
//        
//        self.loadPackages(customer.id, success: { (packages: AnyObject) -> Void in
//            customer.packages = packages as [Package]
//            success()
//        })
//    }
    
    func uploadReceipt(view: UIView, superview: UIView, receipt: Receipt, completion: (success: Bool) -> Void) {
        showHUD(superview)
        updateHUDText("Uploading Receipt Document")
        
        //sequential, batched success tasks. These are chained together to perform the uploads sequentially
        //NOTE: refactor this to use BFTasks-- should clean up the code and logic pretty well
        
        //overall completion-- PDF uploaded to AWS. Call completion block and return
        let pdfSuccess = { (success: Bool) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                self.removeHUD()
                completion(success: success)
            })
        }
        
        //receipt upload task. Call the PDF task
        let receiptSuccess = {(success: Bool) -> Void in
            if !success {
                completion(success: false)
                return
            }
            
            let aws_name = "\(self.user!.group_id)/\(receipt.id).pdf"
            self.createPDF(view, name: aws_name, success: pdfSuccess)
        }
        

        var startBlock: () -> Void
        
        let startReceipt = { (success: Bool) in
            self.createReceipt(receipt, success: receiptSuccess)
        }
        
        //check if the merchandise needs to be created
        let merchandiseExists = receipt.merchandise_receipt_attributes?.product == nil
        let customerExists = receipt.customer_id != -1
        
        //the enumeration here is stupid, but short of using BFTasks instead, this is the cleanest way
        //create merchandise and/or customer, or neither by batching blocks and then call the upload task
        if !merchandiseExists && !customerExists {
            startBlock = {
                self.createCustomer(receipt, success: { (success) -> Void in
                    self.createMerchandise(receipt, success: startReceipt)
                })
            }
        }
        else if !customerExists {
            startBlock = {
                self.createCustomer(receipt, success: startReceipt)
            }
        }
        else if !merchandiseExists {
            startBlock = {
                self.createMerchandise(receipt, success: startReceipt)
            }
        }
        else {
            startBlock = {
                self.createReceipt(receipt, success: startReceipt)
            }
        }
        
        startBlock()
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
    
    
    //MARK: Batch Login Tasks
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
    func createCustomer(receipt: Receipt, success:(success: Bool) -> Void) {
        updateHUDText("Creating Customer")
        let json = MTLJSONAdapter.JSONDictionaryFromModel(receipt.customer)
        
        generateAuthenticatedClient().POST("dashboard/\(user!.group_id)/customers", parameters: json,
            
            success: { ( operation: AFHTTPRequestOperation?, responseObject: AnyObject? ) in
                println("API: Customer Success")
                
                //asign the returned customer object as the receipt's custoemr
                let customer = self.serializeObject(responseObject!, jsonKey: "customer", objectClass: Customer.self)
                receipt.customer = customer as? Customer
                
                //add the new customer to the local list of customers
                let temp = NSMutableArray(array: self.customers)
                temp.addObject(receipt.customer!)
                self.customers = temp
                
                success(success: true)
            },
            
            failure: { ( operation: AFHTTPRequestOperation?, error: NSError? ) in
                print("failure- ")
                println(error)
                success(success: false)
        })
    }
    
    func createMerchandise(receipt: Receipt, success:(success: Bool) -> Void) {
        updateHUDText("Creating Merchandise")
        let json = MTLJSONAdapter.JSONDictionaryFromModel(receipt.merchandise_receipt_attributes?.product)
        
        generateAuthenticatedClient().POST("dashboard/\(user!.group_id)/merchandise", parameters: json,
            
            success: { ( operation: AFHTTPRequestOperation?, responseObject: AnyObject? ) in
                println("API: Merchandise Success")
                
                //asign the returned merchandise object as the receipts merchandise root object
                let merchandise = self.serializeObject(responseObject!, jsonKey: "merchandise", objectClass: Product.self)
                receipt.merchandise_receipt_attributes?.product = merchandise as Product
                
                //add the new customer to the local list of customers
                let temp = NSMutableArray(array: self.merchandises)
                temp.addObject(merchandise)
                self.merchandises = temp
                
                success(success: true)
            },
            
            failure: { ( operation: AFHTTPRequestOperation?, error: NSError? ) in
                print("failure- ")
                println(error)
                success(success: false)
        })
    }
    
    func createReceipt(receipt: Receipt, success:(success: Bool) -> Void) {
        updateHUDText("Uploading Receipt")
        let json = MTLJSONAdapter.JSONDictionaryFromModel(receipt)
        
        println(json)
        
        generateAuthenticatedClient().POST("dashboard/\(user!.group_id)/receipts", parameters: json,
            
            success: { ( operation: AFHTTPRequestOperation?, responseObject: AnyObject? ) in
                println("API: Receipt Success")
//                println(responseObject)
                
                //need the receipt ID in order to create the pdf path on S3
                receipt.id = (responseObject as NSDictionary).objectForKey("receipt") as Int
                
                success(success: true)
            },
            
            failure: { ( operation: AFHTTPRequestOperation?, error: NSError? ) in
                print("failure- ")
                println(error)
                success(success: false)
        })
    }
    
    func createPDF(view: UIView, name: String, success: (Bool) -> Void) {
        let pdfFactory = PDFFactory()
        let uploader = S3FileManager()

        let data = pdfFactory.createPDFFromView(view)
        uploader.uploadFile(data, name: name, completion: success)
    }
    
    
    //MARK: Internal Methods
    //Returns an authenticated, ready to go AFHTTPManager. If a user is not currently signed in, the 
    //authentication fields will silently NOT be filled!
    func generateAuthenticatedClient() -> AFHTTPRequestOperationManager {
        var client = AFHTTPRequestOperationManager(baseURL: NSURL(string: base_url))
        client.requestSerializer = AFJSONRequestSerializer() as AFJSONRequestSerializer
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
    
    func serializeObject(responseObject:AnyObject, jsonKey:String, objectClass:AnyClass) -> AnyObject {
        println("API: \(jsonKey) Success")
        println(responseObject)
        var error: NSError?
        let returnedObject = MTLJSONAdapter.modelOfClass(objectClass, fromJSONDictionary: (responseObject as NSDictionary).objectForKey(jsonKey) as NSDictionary, error: &error) as AnyObject
        
        return returnedObject
    }
    
    func loadImage(product: Product) {
        //async call to load an image using AFNetworking
        let request = NSURLRequest(URL: NSURL(string: product.image_url!)!)
        var operation = AFHTTPRequestOperation(request: request)
        operation.responseSerializer = AFImageResponseSerializer() as AFImageResponseSerializer
        
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
    
    //TESTING TESTING TESTING
    func TEST() {
        let newProduct = Product()
        let newReceipt = ProductReceipt()
        let receipt = Receipt()
        let customer = Customer()
        
        newReceipt.product = newProduct
        receipt.merchandise_receipt_attributes = newReceipt
        receipt.customer = customer
        
        newProduct.name = "New Merchandise"
        
        customer.name = "New Dynamic Customer"
        customer.email = "newCustomerEMail"
        customer.group_id = user!.group_id
        
//        createMerchandise(receipt, success: { (success) -> Void in
//            println("Completed Merchandise")
//        })

        createCustomer(receipt, success:  { (success) -> Void in
            println("Completed Customer")
        })
    }
}

