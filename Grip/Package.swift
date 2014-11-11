//
//  User.swift
//  Grip
//
//  Created by Mickey Barboi on 8/6/14.
//  Copyright (c) 2014 Mickey Barboi. All rights reserved.

import Foundation

class Package : MTLModel, MTLJSONSerializing {
    var created_at: NSDate?
    var discount = -1
    var group_id = -1
    var id = -1
    var name: String?
    var order_index: String?
    var updated_at: NSDate?

    var products = Array<Product>()
    
    //Boilerplate Mantle code
    class func appURLSchemeJSONTransformer() -> NSValueTransformer {
        return NSValueTransformer(forName: MTLURLValueTransformerName)!
    }
    
    class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
        return [
            "products": NSNull()
        ]
    }
    
    class func JSONTransformerForKey(key: String) -> NSValueTransformer? {
        if key == "created_at" || key == "updated_at" {
            return NetworkUtils.dateFormatter()
        }
        
        return nil
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