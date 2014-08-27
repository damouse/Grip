//
//  User.swift
//  Grip
//
//  Created by Mickey Barboi on 8/6/14.
//  Copyright (c) 2014 Mickey Barboi. All rights reserved.
//

import Foundation

class Product : MTLModel, MTLJSONSerializing {
    var id = -1
    var name: String?
    var created_at: String?
    var item_description: String?
    var group_id = -1
    var image_url: String?
    var order_index: String?
    var price = 0.0
    var type: String?
    var updated_at: String?
    
    var image: UIImage?
    
    //simple helper
    func imageUrl() -> NSURL {
        return NSURL(string: image_url)
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