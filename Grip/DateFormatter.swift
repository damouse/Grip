//
//  DateFormatter.swift
//  Grip
//
//  Created by Mickey Barboi on 11/11/14.
//  Copyright (c) 2014 Mickey Barboi. All rights reserved.
//

import UIKit

class GripDateFormatter {
    class func dateFormatter() -> NSValueTransformer {
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        
        return MTLValueTransformer.reversibleTransformerWithForwardBlock( { (date: AnyObject!) -> AnyObject! in
                return formatter.dateFromString(date as String)
            }, reverseBlock: { (date: AnyObject!) -> AnyObject! in
                return formatter.stringFromDate(date as NSDate)
        })
    }
}