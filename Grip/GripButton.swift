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
let PRIMARY_DARK = UIColor(red:35/255, green: 38/255, blue: 44/255, alpha: 1)
let PRIMARY_LIGHT = UIColor(red:47/255, green: 50/255, blue: 56/255, alpha: 1)
let PRIMARY_BRIGHT = UIColor(red:60/255, green: 63/255, blue: 69/255, alpha: 1)

let HIGHLIGHT_COLOR = UIColor(red:222/255, green: 94/255, blue: 96/255, alpha: 1)
let P_TEXT_COLOR = UIColor(red:127/255, green: 130/255, blue: 137/255, alpha: 1)

let ANIMATION_DURATION = 0.4

class GripButton : UIButton {    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        println("subclass 1")
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        colorize()
        self.addTarget(self, action: "buttonTouched", forControlEvents: UIControlEvents.TouchUpInside)
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
    
    func buttonTouched() {
        
//        let buttonLayer = self.titleLabel!.layer
//        
//        var colorAnimation = CABasicAnimation(keyPath: "backgroundColor")
//        colorAnimation.fromValue = UIColor.whiteColor()
//        colorAnimation.toValue = HIGHLIGHT_COLOR
//        
//        var animationGroup = CAAnimationGroup()
//        animationGroup.autoreverses = true
//        animationGroup.duration = 1
//        
//        animationGroup.animations = [colorAnimation]
//        
//        buttonLayer.addAnimation(animationGroup, forKey: "backgroundColor")
        
    }
}