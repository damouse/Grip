//
//  Detail.swift
//  Grip
//
//  Created by Mickey Barboi on 11/14/14.
//  Copyright (c) 2014 Mickey Barboi. All rights reserved.
//

import Foundation

class Detail : MTLModel, MTLJSONSerializing {
    //API Model Fields
    var id = -1
    var detail_type: String?
    
    var detail_name: String?
    var description_text: String?

    
    //Boilerplate Mantle code
    class func appURLSchemeJSONTransformer() -> NSValueTransformer {
        return NSValueTransformer(forName: MTLURLValueTransformerName)!
    }
    
    class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
        return [:]
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