//
//  Receipt.swift
//  Grip
//
//  Created by Mickey Barboi on 8/27/14.
//  Copyright (c) 2014 Mickey Barboi. All rights reserved.
//

/**
A package that has been converted and ready for presentation/finalization. This is the ultimate model object that
is uploaded to the backend, but it is also used to store intermediary steps as to avoid polluting package objects with changed data
*/

import Foundation

class Receipt : MTLModel, MTLJSONSerializing {
    //API model Fields
    var product_receipts_attributes: [ProductReceipt]?
    var merchandise_receipt_attributes: ProductReceipt?
    
    var package_id = -1
    var customer_id = -1
    
    var discount = 0
    var cost = 0.0
    var apr = 0.1
    var term = 36
    
    //non API fields
    var user: User?
    var customer: Customer?
    
    var id = -1
    
    var package: Package? {
        didSet {
            if package == nil {
                self.discount = 0
            }
            else {
                self.package_id = package!.id
                self.discount = package!.discount
            }
        }
    }
    
    
    //class init
    class func createWith(user: User, customer: Customer, merchandise: Product) -> Receipt {
        let receipt = Receipt()
        
        receipt.merchandise_receipt_attributes = ProductReceipt.createWith(merchandise)
        receipt.user = user
        receipt.customer = customer
        receipt.customer_id = customer.id
        
        return receipt
    }
    
    
    //Boilerplate Mantle code
    class func appURLSchemeJSONTransformer() -> NSValueTransformer {
        return NSValueTransformer(forName: MTLURLValueTransformerName)!
    }
    
    class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
        return [
            "item_description" : "description",
            "package": NSNull(),
            "user" : NSNull(),
            "customer" : NSNull(),
            "id": NSNull()
        ]
    }
    
    class func JSONTransformerForKey(key: String!) -> NSValueTransformer! {
        var otherKey: String = key
        
        switch otherKey {
        case "merchandise_receipt_attributes":
            return NSValueTransformer.mtl_JSONDictionaryTransformerWithModelClass(ProductReceipt.self)
        case "product_receipts_attributes":
            return NSValueTransformer.mtl_JSONArrayTransformerWithModelClass(ProductReceipt.self)
        default:
            return nil
        }
    }
    

    //Boilerplate, compulsory overrides. Kinda stupid, isn't it?
    //The following four methods allow this class access to its superclass' inherited methods
    override func encodeWithCoder(coder: NSCoder!) {
        super.encodeWithCoder(coder)
    }
    
    required init(coder:NSCoder) {
        super.init(coder: coder)
    }
    
    override init() {
        super.init()
    }
    
    override init(dictionary dictionaryValue: [NSObject : AnyObject]!, error: NSErrorPointer) {
        super.init(dictionary: dictionaryValue!, error: error)
    }
    
    
    //
}