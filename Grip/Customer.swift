//
//  Customer.swift
//  Grip
//
//  Created by Mickey Barboi on 10/21/14.
//  Copyright (c) 2014 Mickey Barboi. All rights reserved.
//

import Foundation
/*
Remember! Customer models do not match the backend strictly! Whats recorded here is really the group that 
wraps the customer and the glued on email for that customer. The id is not for the customer object, but rather the group.

The name of the group should always match the customer. Group ownership should also match up fine. Be careful when posting
new customers-- can't just post this object!
*/
class Customer : MTLModel, MTLJSONSerializing {
    var id = -1
    var name: String?
    var group_id = -1
    var email: String?
    var created_at = NSDate()
    var updated_at = NSDate()
    
    //used to check package downloads
    var packages: [Package]?
    
    
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
    
    required override init() {

        super.init()
    }
    
    override init(dictionary dictionaryValue: [NSObject : AnyObject]!, error: NSErrorPointer) {
        super.init(dictionary: dictionaryValue!, error: error)
    }
}
