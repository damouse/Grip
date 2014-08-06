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
    var token_expiration: String?
    var created_at: String?
    var updated_at: String?
    
    //Boilerplate method for Mantle-- informs the framework how the JSON fields map to the model fields
    class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
        return [
            "id": "id",
            "name": "name",
            "group_id": "group_id",
            "email": "email",
            "authentication_token": "authentication_token",
            "token_expiration": "token_expiration",
            "created_at": "created_at",
            "updated_at": "updated_at"  ]
    }
    

    //Boilerplate Mantle code
    class func appURLSchemeJSONTransformer() -> NSValueTransformer {
        return NSValueTransformer(forName: MTLURLValueTransformerName)
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