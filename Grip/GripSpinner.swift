//
//  GripSpinner.swift
//  Grip
//
//  Created by Mickey Barboi on 10/21/14.
//  Copyright (c) 2014 Mickey Barboi. All rights reserved.
//

import Foundation
import QuartzCore

class GripSpinner : UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.drawInitialShapes()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        
        self.drawInitialShapes()
    }
    
    
    //MARK: initial setup
    func drawInitialShapes() {
        var rootLayer = self.layer
//        rootLayer.
        
        var square = CALayer()
        square.backgroundColor = UIColor.redColor().CGColor
        square.frame = CGRectMake(20, 20, 10, 10)
        
        var square2 = CALayer()
        square2.backgroundColor = UIColor.redColor().CGColor
        square2.frame = CGRectMake(40, 40, 10, 10)
        
        
        var colorAnimation = CABasicAnimation(keyPath: "backgroundColor")
        colorAnimation.fromValue = UIColor.redColor().CGColor
        colorAnimation.toValue = UIColor.greenColor().CGColor
        
        var scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 1.0
        scaleAnimation.toValue = 1.5
        
        var animationGroup = CAAnimationGroup()
        animationGroup.autoreverses = true
        animationGroup.duration = 0.5
        
        animationGroup.animations = [colorAnimation, scaleAnimation]
        
        square.addAnimation(animationGroup, forKey: "backgroundColor")
        
        rootLayer.addSublayer(square)
        rootLayer.addSublayer(square2)
        
        
        
//        CALayer *sublayer = [CALayer layer];
//        sublayer.backgroundColor = [UIColor blueColor].CGColor;
//        sublayer.shadowOffset = CGSizeMake(0, 3);
//        sublayer.shadowRadius = 5.0;
//        sublayer.shadowColor = [UIColor blackColor].CGColor;
//        sublayer.shadowOpacity = 0.8;
//        sublayer.frame = CGRectMake(30, 30, 128, 192);
//        [self.view.layer addSublayer:sublayer];
    }
}