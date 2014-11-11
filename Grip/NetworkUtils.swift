//
//  DateFormatter.swift
//  Grip
//
//  Created by Mickey Barboi on 11/11/14.
//  Copyright (c) 2014 Mickey Barboi. All rights reserved.
//


import UIKit
import SystemConfiguration

class NetworkUtils {
    
    //returns a date formatter usable by Mantle in changing Dates to Strings and visaversa
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

    //Simple network check. Returns true if you have access to the internet and false otherwise
    class func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0)).takeRetainedValue()
        }
        
        var flags: SCNetworkReachabilityFlags = 0
        if SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) == 0 {
            return false
        }
        
        let isReachable = (flags & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        
        return (isReachable && !needsConnection) ? true : false
    }
}


