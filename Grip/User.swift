//
//  User.swift
//  Grip
//
//  Created by Mickey Barboi on 8/6/14.
//  Copyright (c) 2014 Mickey Barboi. All rights reserved.
//

import Foundation

class User : MTLModel, MTLJSONSerializing {
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
    
    
    //NSCoding adoption
    override func encodeWithCoder(coder: NSCoder!) {
        coder.encodeObject(name, forKey: "name")
        coder.encodeObject(group_id, forKey: "group_id")
        coder.encodeObject(email, forKey: "email")
        coder.encodeObject(authentication_token, forKey: "authentication_token")
        coder.encodeObject(token_expiration, forKey: "token_expiration")
        coder.encodeObject(created_at, forKey: "created_at")
        coder.encodeObject(updated_at, forKey: "updated_at")

    }
    
    required init(coder:NSCoder) {
        super.init()
        name = coder.decodeObjectForKey("name") as? String
        group_id = coder.decodeObjectForKey("group_id") as Int
        email = coder.decodeObjectForKey("email") as? String
        authentication_token = coder.decodeObjectForKey("authentication_token") as? String
        token_expiration = coder.decodeObjectForKey("token_expiration") as? String
        created_at = coder.decodeObjectForKey("created_at") as? String
        updated_at = coder.decodeObjectForKey("updated_at") as? String
    }
    
    
    //Init calls
    override init() {
        super.init()
    }
    
    override init(dictionary dictionaryValue: [NSObject : AnyObject]!, error: NSErrorPointer) {
        super.init(dictionary: dictionaryValue!, error: error)
    }
}