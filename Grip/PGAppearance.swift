//
//  Colorizer.swift
//  Grip
//
//  Created by Mickey Barboi on 11/11/14.
//  Copyright (c) 2014 Mickey Barboi. All rights reserved.
//

/**
    Responsible for all colors and appearane in the app
*/

import UIKit
import Foundation

class PGAppearance: NSObject {
    
    class func setAppearance() {
        //sets the appearance of app-wide UI elements
        
        setColors()
        setFonts()
    }
    
    class func setColors() {
        //sets the color-- light or dark
        UITextField.appearance().keyboardAppearance = UIKeyboardAppearance.Dark
        UISwitch.appearance().onTintColor = HIGHLIGHT_COLOR
    }
    
    class func setFonts() {
        //sets font for all labels in the app
        UILabel.appearance()
    }
}
