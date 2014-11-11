//
//  User.swift
//  Grip
//
//  Created by Mickey Barboi on 8/6/14.
//  Copyright (c) 2014 Mickey Barboi. All rights reserved.
//

import Foundation

class User : MTLModel, MTLJSONSerializing {
    var id = -1
    var name: String?
    var group_id = -1
    var email: String?
    var authentication_token: String?
    var token_expiration: NSDate?
    var created_at: NSDate?
    var updated_at: NSDate?
    var image_url: String?
    
    var image: UIImage?


    //Boilerplate Mantle code
    class func appURLSchemeJSONTransformer() -> NSValueTransformer {
        return NSValueTransformer(forName: MTLURLValueTransformerName)!
    }
    
    class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
        return [
            "image": NSNull()
        ]
    }
    
    class func JSONTransformerForKey(key: String) -> NSValueTransformer? {
        if key == "token_expiration" || key == "created_at" || key == "updated_at" {
            return GripDateFormatter.dateFormatter()
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

