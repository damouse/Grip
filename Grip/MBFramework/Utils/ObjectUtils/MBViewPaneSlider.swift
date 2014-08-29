//
//  MBViewPaneSlider.swift
//  Grip
//
//  Created by Mickey Barboi on 8/29/14.
//  Copyright (c) 2014 Mickey Barboi. All rights reserved.
//

/**
An animation utility class that controls two panes and two buttons. Each of the panes should be presented when the button is selected, 
with an animation transitioning between the two.

Add support for infinitely many views at once.
*/

import Foundation
import QuartzCore

class MBViewPaneSlider : NSObject {
    var view1: UIView?
    var view2: UIView?
    
    var button1: UIButton?
    var button2: UIButton?
    
    var activeButton: UIButton?
    
    
    init(view1: UIView, button1: UIButton, view2: UIView, button2: UIButton) {
        super.init()
        
        self.view1 = view1
        self.view2 = view2
        self.button1 = button1
        self.button2 = button2
        
        button1.addTarget(self, action: "buttonPress:", forControlEvents: .TouchUpInside)
        button2.addTarget(self, action: "buttonPress:", forControlEvents: .TouchUpInside)
        
        //start with view1 as initial view
        view2.hidden = true
        activeButton = button1
        button1.setTitleColor(HIGHLIGHT_COLOR, forState: .Normal)
    }
    
    func buttonPress(sender: UIButton) {
        if activeButton == sender {
            return
        }
        
        var transition = CATransition()
        transition.duration = 0.4
        transition.type = kCATransitionPush
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        
        if sender == button1 {
            transition.subtype = kCATransitionFromLeft
            view1?.hidden = false
            view2?.hidden = true
            button1?.setTitleColor(HIGHLIGHT_COLOR, forState: .Normal)
            button2?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            activeButton = button1
        }
        else {
            transition.subtype = kCATransitionFromRight
            view2?.hidden = false
            view1?.hidden = true
            button2?.setTitleColor(HIGHLIGHT_COLOR, forState: .Normal)
            button1?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            activeButton = button2
        }
        
        view1?.layer.addAnimation(transition, forKey: nil)
        view2?.layer.addAnimation(transition, forKey: nil)
    }
}