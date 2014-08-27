//
//  GripButton.swift
//  Grip
//
//  Created by Mickey Barboi on 8/26/14.
//  Copyright (c) 2014 Mickey Barboi. All rights reserved.
//

/*
An overridden button to handle custom colors and actions

Sets its colors on init
*/

import Foundation

//Color Constants
let PRIMARY_DARK = UIColor(red:123, green: 123, blue: 123, alpha: 1)
let PRIMARY_LIGHT = UIColor(red:47, green: 50, blue: 56, alpha: 1)
let HIGHLIGHT_COLOR = UIColor(red:222, green: 94, blue: 96, alpha: 1)
let P_TEXT_COLOR = UIColor(red:127, green: 130, blue: 137, alpha: 1)

class GripButton : UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        println("subclass 1")
    }
    
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
        
        colorize()
    }
    
    override init() {
        super.init()
        println("subclass 3")
    }
    
    func colorize() {
        //custom colors for Grip themes
        super.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        super.setTitleColor(HIGHLIGHT_COLOR, forState: UIControlState.Highlighted)
        super.adjustsImageWhenHighlighted = true
    }
}