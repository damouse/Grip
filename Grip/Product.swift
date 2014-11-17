//
//  User.swift
//  Grip
//
//  Created by Mickey Barboi on 8/6/14.
//  Copyright (c) 2014 Mickey Barboi. All rights reserved.
//

/*
func createdAtJSONTransformer() -> NSValueTransformer {
let _forwardBlock: MTLValueTransformerBlock? = { str in
return self.dateFormatter().dateFromString(str as String!)
}
let _reverseBlock: MTLValueTransformerBlock? = { date in
return self.dateFormatter().stringFromDate(date as NSDate!)
}
return MTLValueTransformer.reversibleTransformerWithForwardBlock(_forwardBlock, reverseBlock: _reverseBlock)
}
*/

import Foundation

class Product : MTLModel, MTLJSONSerializing {
    var id = -1
    var name: String?
    var created_at: NSDate?

    var group_id = -1
    var image_url: String?
    var order_index: String?
    var price = 0.0
    var type: String?
    var updated_at: NSDate?
    
    var image: UIImage?
    var desaturatedImage: UIImage?
    
    var details: [Detail]?
    

    //Boilerplate Mantle code
    class func appURLSchemeJSONTransformer() -> NSValueTransformer {
        return NSValueTransformer(forName: MTLURLValueTransformerName)!
    }
    
    class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
        return [
            "image": NSNull(),
            "desaturatedImage": NSNull()
        ]
    }
    
    class func JSONTransformerForKey(key: String) -> NSValueTransformer? {
        if key == "created_at" || key == "updated_at" {
            return NetworkUtils.dateFormatter()
        }
        if key == "details" {
            return NSValueTransformer.mtl_JSONArrayTransformerWithModelClass(Detail.self)
        }
        
        return nil
    }
    
    func getSummary() -> String {
        //return the summary item from descriptions
        if let udetails = details {
            let summary = udetails.filter {$0.detail_type == "summary"}[0]
            return summary.description_text!
        }
        else {
            return ""
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
}