//
//  ProductReceipt.swift
//  Grip
//
//  Created by Mickey Barboi on 8/27/14.
//  Copyright (c) 2014 Mickey Barboi. All rights reserved.
//

/**
Product or Merchandise converted for sale/manipulation. Uploaded to the API when completed. 

*/

import Foundation


class ProductReceipt : MTLModel, MTLJSONSerializing {
    //API Model Fields
    var base_item_id = -1
    var name: String?
    var price = 0.0
    var type: String?

    //Non API Fields
    var product: Product?
    
    var active = false
    
    
    //create a Receipt from a Product
    //needs another method that creates a brand new receipt from user input
    class func createWith(product: Product) -> ProductReceipt {
        let receipt = ProductReceipt()
        
        receipt.base_item_id = product.id
        receipt.name = product.name
        receipt.price = product.price
        receipt.type = product.type! + "Receipt"
        receipt.product = product
        
        return receipt
    }
    
    //Boilerplate Mantle code
    class func appURLSchemeJSONTransformer() -> NSValueTransformer {
        return NSValueTransformer(forName: MTLURLValueTransformerName)
    }
    
    class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
        return [
            "item_description" : "description",
            "product" : NSNull(),
            "active" : NSNull()
        ]
    }
    
    class func productJSONTransformer() -> NSValueTransformer {
        return NSValueTransformer.mtl_JSONDictionaryTransformerWithModelClass(Product.self)
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