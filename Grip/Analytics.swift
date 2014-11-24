//
//  Analytics.swift
//  Grip
//
//  Created by Mickey Barboi on 11/23/14.
//  Copyright (c) 2014 Mickey Barboi. All rights reserved.
//

import Foundation

class Analytics : NSObject {
    class func login() {
        let tracker = GAI.sharedInstance().defaultTracker
        if tracker == nil {
            return
        }

        tracker.send(GAIDictionaryBuilder.createEventWithCategory("session", action: "login", label:"Login", value:nil).build())
    }
    
    class func madeDeal() {
        let tracker = GAI.sharedInstance().defaultTracker
        if tracker == nil {
            return
        }
        
        tracker.send(GAIDictionaryBuilder.createEventWithCategory("deal", action: "completed_deal", label:"Completed Deal", value:nil).build())
    }
}