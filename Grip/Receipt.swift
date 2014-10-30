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
    var id = -1
    var productReceipts: [ProductReceipt]?
    var merchandise: ProductReceipt?
    var user: User?
    var customer: Customer?
    var discount = 0
    var base_package_id = -1
    var signature: AnyObject?
    
    var package: Package?
    
    //class init
    class func createWith(user: User, customer: Customer, merchandise: Product) -> Receipt {
        let receipt = Receipt()
        
        receipt.merchandise = ProductReceipt.createWith(merchandise)
        receipt.user = user
        receipt.customer = customer
        
        return receipt
    }
    
    
    //Boilerplate Mantle code
    class func appURLSchemeJSONTransformer() -> NSValueTransformer {
        return NSValueTransformer(forName: MTLURLValueTransformerName)
    }
    
    class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
        return [
            "item_description" : "description",
        ]
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
}