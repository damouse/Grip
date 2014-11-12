//
//  GripLabel.swift
//  Grip
//
//  Created by Mickey Barboi on 11/11/14.
//  Copyright (c) 2014 Mickey Barboi. All rights reserved.
//

import Foundation

class GripLabel: UITextField {
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
    }
}
