//
//  MBUtils.swift
//  Grip
//
//  Created by Mickey Barboi on 11/11/14.
//  Copyright (c) 2014 Mickey Barboi. All rights reserved.
//

/**
    Random, simple utilities
*/

import Foundation

class MBUtils {
    class func uuid() -> String {
        return UIDevice.currentDevice().identifierForVendor.UUIDString
    }
}