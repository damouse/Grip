//
//  PGApiManager.swift
//  Grip
//
//  Created by Mickey Barboi on 8/6/14.
//  Copyright (c) 2014 Mickey Barboi. All rights reserved.


import Foundation
import UIKit

private let _singletonInstance = PGApiManager()

@objc class PGApiManager : NSObject {
    let logging = false
    
//    let base_url = "http://packagegrid.com/"
    let base_url = "http://192.168.79.167:3000/"
    
    //stored user information-- hold for future auth requests
    var userPassword: String?
    var userEmail: String?
    
    var user: User?
    var products = NSArray()
    var merchandises = NSArray()
    var packages = NSArray()
    var customers = [Customer]()
    var setting = Setting()
    
    var progressHUD: MBProgressHUD?
    
    //Singleton Accessor: DANGER DANGER RED RANGER
    class var sharedInstance: PGApiManager {
        return _singletonInstance
    }
    
    
    //MARK: Public Interface
    func loadResources(view: UIView, completion: (Bool) -> Void) {
        //load the resources from the backend
        showHUD(view)
        validateCallAndIssue({ () -> Void in
            self.getAllResourcesSequentially(completion)
        }, completion: completion)
        
    }
    
    func setUserCredentials(email: String, password:String) {
        //called when the user enters login details
        self.userEmail = email
        self.userPassword = password
    }
    
    func uploadReceipt(view: UIView, superview: UIView, receipt: Receipt, completion: (success: Bool) -> Void) {
        showHUD(superview)
        updateHUDText("Uploading Receipt Document")
        
        //special case-- demo users should not be able to post receipts
        if user!.demoUser() {
            dispatch_after(3000, dispatch_get_main_queue(), {
                self.removeHUD()
                
                let alert = UIAlertView()
                alert.title = "Success"
                alert.message = "Receipt uploaded to packagegrid.com!"
                alert.addButtonWithTitle("Ok")
                alert.show()
                
                completion(success: true)
            })
            
            println("Demo user faking it")
            return
        }
        
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
        let merchandiseExists = receipt.merchandise_receipt_attributes?.product != nil
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
                self.createReceipt(receipt, success: receiptSuccess)
            }
        }
        
        validateCallAndIssue({ () -> Void in
            startBlock()
        }, completion: completion)
    }
    
    func updateSettings(view: UIView, completion: (success: Bool) -> Void) {
        if user!.demoUser() {
            return
        }
        //update the settings object. Rely on Landing to change the fields of the object
        updateSettings(setting, success: completion)
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
        if progressHUD != nil {
            progressHUD?.hide(true)
            progressHUD = nil
        }
    }
    
    func updateHUDText(newText:String) {
        progressHUD?.detailsLabelText = newText
    }
    
    
    //MARK: Batch Login Tasks
    func getAllResourcesSequentially(completion: (Bool) -> Void) {
        //gets all of the resources sequentially-- waits for the previous one to finished before starting the next
        
        //success blocks
        let packageSuccess = { (id: Int, packages: AnyObject) -> Void in
            self.packages = packages as NSArray
            self.removeHUD()
            completion(true)
        }
        
        let settingSuccess = { () -> Void in
            self.loadPackages(self.user!.group_id, packageSuccess)
        }
        
        let productSuccess = { () -> Void in
            self.loadSettings(self.user!.group_id, settingSuccess)
        }
        
        let merchandiseSuccess = { () -> Void in
            self.loadProducts(productSuccess)
        }
        
        let customerSuccess = { () -> Void in
            self.loadMerchandises(merchandiseSuccess)
            
            //load customer packages for each customer
            for customer in self.customers {
                self.loadPackages(customer.group_id, success: { (id: Int, packages: AnyObject) -> Void in
                    let customer = self.customers.filter({$0.group_id == id})[0] as Customer
                    customer.packages = packages as? [Package]
                    println(packages)
                })
            }
        }
        
        self.loadCustomers(customerSuccess)
    }
    
    
    // MARK: Download
    func logIn(completion: (Bool) -> Void) -> Void {
        updateHUDText("Logging in")
        
        generateAuthenticatedClient().GET("api/v1/auth?user_email=\(self.userEmail!)&password=\(self.userPassword!)", parameters: nil,
            
            success: { ( operation: AFHTTPRequestOperation?, responseObject: AnyObject? ) in
                self.optionalLog("API: User Success")
                
                var error: NSError?
                let json = responseObject as Dictionary<String, AnyObject>
                let userDictionary = json["user"] as Dictionary<String, AnyObject>
                
                self.user = MTLJSONAdapter.modelOfClass(User.self, fromJSONDictionary: userDictionary, error: &error) as? User
                self.user?.image_url = json["image_url"] as? String
                
                self.loadUserImage(self.user!, completion: { () -> Void in
                    completion(true)
                })
            },
            
            failure: { ( operation: AFHTTPRequestOperation?, error: NSError? ) -> Void in
                self.apiFailed(operation, error: error)
                completion(false)
        })
    }
    
    func loadSettings(id:Int, success:(() -> Void)?) -> Void {
        //load the user settings from the backend
        updateHUDText("Loading Settings")
        
        generateAuthenticatedClient().GET("dashboard/\(id)/settings.json", parameters: nil,
            
            success: { ( operation: AFHTTPRequestOperation?, responseObject: AnyObject? ) in
                self.optionalLog("API: Settings Success")
                self.setting = self.serializeObject(responseObject!, jsonKey: "setting", objectClass: Setting.self) as Setting
                success?()
            },
            
            failure: { ( operation: AFHTTPRequestOperation?, error: NSError? ) -> Void in
                self.apiFailed(operation, error: error)
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
            
            failure:  { ( operation: AFHTTPRequestOperation?, error: NSError? ) -> Void in
                self.apiFailed(operation, error: error)
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
            
            failure:  { ( operation: AFHTTPRequestOperation?, error: NSError? ) -> Void in
                self.apiFailed(operation, error: error)
        })
    }
    
    func loadPackages(id:Int, success:((Int, AnyObject) -> Void)?) -> Void {
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
                
                success?(id, packages)
            },
            
            failure:  { ( operation: AFHTTPRequestOperation?, error: NSError? ) -> Void in
                self.apiFailed(operation, error: error)
        })
    }
    
    func loadCustomers(success:(() -> Void)?) -> Void {
        updateHUDText("Updating Customers")
        
        generateAuthenticatedClient().GET("dashboard/\(self.user!.group_id)/customers", parameters: nil,
            
            success: { ( operation: AFHTTPRequestOperation?, responseObject: AnyObject? ) in
                self.customers = self.serializeObjects(responseObject!, jsonKey: "customers", objectClass: Customer.self) as [Customer]
                success?()
            },
            
            failure:  { ( operation: AFHTTPRequestOperation?, error: NSError? ) -> Void in
                self.apiFailed(operation, error: error)
        })
        
        optionalLog("API: Customer Success")
    }
    
    
    //MARK: Upload
    func createCustomer(receipt: Receipt, success:(success: Bool) -> Void) {
        updateHUDText("Creating Customer")
        let json = MTLJSONAdapter.JSONDictionaryFromModel(receipt.customer)
        
        generateAuthenticatedClient().POST("dashboard/\(user!.group_id)/customers", parameters: json,
            
            success: { ( operation: AFHTTPRequestOperation?, responseObject: AnyObject? ) in
                self.optionalLog("API: Customer Success")
                
                //asign the returned customer object as the receipt's custoemr
                let customer = self.serializeObject(responseObject!, jsonKey: "customer", objectClass: Customer.self) as? Customer
                
                receipt.customer = customer
                receipt.customer_id = receipt.customer!.id
                
                //add the new customer to the local list of customers
                self.customers.append(receipt.customer!)
                
                success(success: true)
            },
            
            failure:  { ( operation: AFHTTPRequestOperation?, error: NSError? ) -> Void in
                self.apiFailed(operation, error: error)
        })
    }
    
    func createMerchandise(receipt: Receipt, success:(success: Bool) -> Void) {
        updateHUDText("Creating Merchandise")
        let json = MTLJSONAdapter.JSONDictionaryFromModel(receipt.merchandise_receipt_attributes?.product)
        
        generateAuthenticatedClient().POST("dashboard/\(user!.group_id)/merchandise", parameters: json,
            
            success: { ( operation: AFHTTPRequestOperation?, responseObject: AnyObject? ) in
                self.optionalLog("API: Merchandise Success")
                
                //asign the returned merchandise object as the receipts merchandise root object
                let merchandise = self.serializeObject(responseObject!, jsonKey: "merchandise", objectClass: Product.self)
                receipt.merchandise_receipt_attributes?.product = merchandise as Product
                
                //add the new customer to the local list of customers
                let temp = NSMutableArray(array: self.merchandises)
                temp.addObject(merchandise)
                self.merchandises = temp
                
                success(success: true)
            },
            
            failure:  { ( operation: AFHTTPRequestOperation?, error: NSError? ) -> Void in
                self.apiFailed(operation, error: error)
        })
    }
    
    func createReceipt(receipt: Receipt, success:(success: Bool) -> Void) {
        updateHUDText("Uploading Receipt")
        let json = MTLJSONAdapter.JSONDictionaryFromModel(receipt)
        
        optionalLog(json)
        
        generateAuthenticatedClient().POST("dashboard/\(user!.group_id)/receipts", parameters: json,
            
            success: { ( operation: AFHTTPRequestOperation?, responseObject: AnyObject? ) in
                self.optionalLog("API: Receipt Success")
                
                //need the receipt ID in order to create the pdf path on S3
                receipt.id = (responseObject as NSDictionary).objectForKey("receipt") as Int
                
                success(success: true)
            },
            
            failure:  { ( operation: AFHTTPRequestOperation?, error: NSError? ) -> Void in
                self.apiFailed(operation, error: error)
                success(success: false)
        })
    }
    
    func createPDF(view: UIView, name: String, success: (Bool) -> Void) {
        let pdfFactory = PDFFactory()
        let uploader = S3FileManager()

        let data = pdfFactory.createPDFFromView(view)
        uploader.uploadFile(data, name: name, completion: success)
    }
    
    func updateSettings(settings: Setting, success: (Bool) -> Void) {
        //update the user's settings. Patch to the backend
        let json = MTLJSONAdapter.JSONDictionaryFromModel(settings)
        optionalLog(json)
        
        generateAuthenticatedClient().PUT("dashboard/\(user!.group_id)/settings", parameters: json,
            
            success: { ( operation: AFHTTPRequestOperation?, responseObject: AnyObject? ) in
                self.optionalLog("API: Setting update Success")
                success(true)
            },
            
            failure:  { ( operation: AFHTTPRequestOperation?, error: NSError? ) -> Void in
                success(false)
                self.apiFailed(operation, error: error)
        })
    }
    
    
    //MARK: Internal Methods
    func generateAuthenticatedClient() -> AFHTTPRequestOperationManager {
        var client = AFHTTPRequestOperationManager(baseURL: NSURL(string: base_url))
        client.requestSerializer = AFJSONRequestSerializer() as AFJSONRequestSerializer
        
        client.requestSerializer.setValue("application/json", forHTTPHeaderField: "Accept")
        client.requestSerializer.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if user != nil {
            client.requestSerializer.setValue(String(user!.id), forHTTPHeaderField: "X-USER-ID")
            client.requestSerializer.setValue(user?.authentication_token, forHTTPHeaderField: "X-AUTHENTICATION-TOKEN")
        }
        
        return client
    }
    
    func validateCallAndIssue(call: () -> Void, completion: (Bool) -> Void) {
        //ensure we are online and authenticated and then issue the  passed API call
        //calls the completion block regardless of what happens to the API call. The completion block
        //is largely independant of the API call-- assume its a callback from an external object
        
        //check for internet connection
        if !NetworkUtils.isConnectedToNetwork() {
            let alert = UIAlertView()
            alert.title = "Error"
            alert.message = "It appears Grip can't access the internet. Please make sure you are connected to WiFi or Cellular."
            alert.addButtonWithTitle("Ok")
            alert.show()
            
            self.removeHUD()
            
            completion(false)
        }
        
        //check time authenticity of user token. If invalid, reauthenticate
        else if self.user == nil || self.user?.token_expiration?.compare(NSDate()) == NSComparisonResult.OrderedDescending {
            self.logIn({ (status: Bool) -> Void in
                if !status { //will the controller know why the completion failed? Need to pass an error message back up
                    completion(false)
                    return
                }
                
                call()
            })
            
            return
        }
        
        //issue call if everything is ok
        else {
            call()
        }
    }
    
    func apiFailed(operation: AFHTTPRequestOperation?, error: NSError?) {
        print("failure- ")
        println(error)
//        println(operation)
        println(operation!.responseObject)
        
        var message = "An error occured communinicating with the server"
        
        //conditionally display errors if they are presented
        let responseDict = operation!.responseObject as? [String: String]
        if responseDict != nil {
            let errorMessage = responseDict!["message"]
            if errorMessage != nil {
                message = errorMessage!
            }
        }
        
        PGApiManager.sharedInstance.removeHUD()
        
        //show alert!
        let alert = UIAlertView()
        alert.title = "Error"
        alert.message = message
        alert.addButtonWithTitle("Ok")
        alert.show()
    }
    
    func serializeObjects(responseObject:AnyObject, jsonKey:String, objectClass:AnyClass) -> NSArray {
        optionalLog("API: \(jsonKey) Success")
        optionalLog(responseObject)
        var error: NSError?
        let cocoaArray: NSArray = MTLJSONAdapter.modelsOfClass(objectClass, fromJSONArray: (responseObject as NSDictionary).objectForKey(jsonKey) as NSArray, error: &error) as NSArray
        return cocoaArray
    }
    
    func serializeObject(responseObject:AnyObject, jsonKey:String, objectClass:AnyClass) -> AnyObject {
        optionalLog("API: \(jsonKey) Success")
        optionalLog(responseObject)
        var error: NSError?
        let returnedObject = MTLJSONAdapter.modelOfClass(objectClass, fromJSONDictionary: (responseObject as NSDictionary).objectForKey(jsonKey) as NSDictionary, error: &error) as AnyObject
        
        return returnedObject
    }
    
    func loadImage(product: Product) {
        if product.image_url == "default.png" {
            product.image = UIImage(named: "Placeholder")
            product.desaturatedImage = product.image!.desaturate()
            return
        }
        
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
                
                self.optionalLog("Image failure for product \(product.name)")
                println(error)
        })
        
        operation.start()
    }
    
    func loadUserImage(user: User, completion:() ->Void) {
        updateHUDText("Loading Logo");
        //async call to load an image using AFNetworking
        if user.image_url == "default.png" {
            user.image = UIImage(named: "Placeholder")
            completion()
            return
        }
        
        let request = NSURLRequest(URL: NSURL(string: user.image_url!)!)
        var operation = AFHTTPRequestOperation(request: request)
        operation.responseSerializer = AFImageResponseSerializer() as AFImageResponseSerializer
        
        operation.setCompletionBlockWithSuccess({ (operation: AFHTTPRequestOperation!, object: AnyObject!) -> Void in
                user.image = object as? UIImage
                println("User finished loading picture")
                completion()
            },
            
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) ->Void in
                user.image = UIImage(named: "Placeholder")
                
                self.optionalLog("Image failure for product \(user.name)")
                println(error)
                completion()
        })
        
        operation.start()
    }
    
    func optionalLog(contents: AnyObject) {
        if logging {
            println(contents)
        }
    }
}

