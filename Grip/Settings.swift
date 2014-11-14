//
//  Settings.swift
//  Grip
//
//  Created by Mickey Barboi on 11/13/14.
//  Copyright (c) 2014 Mickey Barboi. All rights reserved.
//

import Foundation

import Foundation

class Setting : MTLModel, MTLJSONSerializing {
    var id = -1
    
    var show_inherited_products = true
    var show_inherited_packages = true
    var customize_product_cost = true
    
    var created_at: NSDate?
    var updated_at: NSDate?

    
    
    //Boilerplate Mantle code
    class func appURLSchemeJSONTransformer() -> NSValueTransformer {
        return NSValueTransformer(forName: MTLURLValueTransformerName)!
    }
    
    class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
        return [:]
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

