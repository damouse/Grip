//
//  GripLabel.swift
//  Grip
//
//  Created by Mickey Barboi on 11/11/14.
//  Copyright (c) 2014 Mickey Barboi. All rights reserved.
//

/**
    Colors itself and draws an extra large border behind it
*/

import Foundation

class GripTextfield: UITextField {
    override init(frame: CGRect) {
        super.init(frame: frame)
        colorize()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        colorize()
    }
    
    override init() {
        super.init()
        colorize()
    }
    
    func colorize() {
        //add an offset grey view behind this view
        self.clipsToBounds = false
        
        //change the display of the plaeholder font
        self.attributedPlaceholder = NSAttributedString(string:self.placeholder!, attributes: [
                NSForegroundColorAttributeName: PRIMARY_DARK,
                NSFontAttributeName : UIFont(name: "Titillium-Regular", size:18)!
            ])
        
        //see all font names
        //println(UIFont.fontNamesForFamilyName("Titillium"))
        
    }
    
    override func drawRect(rect: CGRect) {
        //draws a light backgroud color border
        let layer = CALayer()
        let frame = self.frame
        
        layer.frame = CGRectMake(-10, -10, frame.size.width + 20, frame.size.height + 20)
    
        layer.backgroundColor = PRIMARY_LIGHT.CGColor
        
        self.layer.addSublayer(layer)
        self.layer.insertSublayer(layer, atIndex:0)
        
        super.drawRect(rect)
    }
}
