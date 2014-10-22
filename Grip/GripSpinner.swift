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
    var squares = [CALayer]()
    var animationStep = 0
    var timer : NSTimer?
    
    let squareColor = PRIMARY_DARK
    let highlightColor = HIGHLIGHT_COLOR
    
    let animationDuration = 0.4
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    func setup() {
        self.drawInitialShapes()
        self.colorize()
        self.hidden = true
    }
    
    
    //MARK: initial setup
    func drawInitialShapes() {
        var rootLayer = self.layer
        
        var width = self.frame.width
        var height = self.frame.height
        
        //make 9 blocks, evenly spaced in the view's size
        var blockHeight = height / 4
        var blockWidth = width / 4
        var verticalSpacing = height / 8
        var horizontalSpacing = width / 8
        
        for column in 0...2 {
            for row in 0...2 {
                var square = CALayer()
                square.backgroundColor = squareColor.CGColor
                
                //Overly verbose assignments because thanks, swift
                let x = CGFloat(Double(column) * 3 * Double(horizontalSpacing))
                let y = CGFloat(Double(row) * 3 * Double(verticalSpacing))
                
                square.frame = CGRectMake(x, y, blockWidth, blockHeight)
                
                self.squares += [square]
                rootLayer.addSublayer(square)
            }
        }
    }
    
    func colorize() {
        self.backgroundColor = UIColor.clearColor()
    }
    
    
    //MARK: Timing Methods
    func startAnimating() {
        timer = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: Selector("updateAnimation"), userInfo: nil, repeats: true)
        self.animateHidden(false)
    }
    
    func stopAnimating() {
        timer?.invalidate()
        self.animateHidden(true)
        self.animationStep = 0
    }
    
    func updateAnimation() {
        //Step 0: animate first block
        var blocks = self.getAnimatingBlocks()
        self.animateBlocks(blocks)
        self.animationStep = self.animationStep + 1
    }
    
    func getAnimatingBlocks() -> [CALayer] {
        switch animationStep {
        case 4:
            return [squares[6]]
        case 3:
            return [squares[3], squares[7]]
        case 2:
            return [squares[0], squares[4], squares[8]]
        case 1:
            return [squares[1], squares[5]]
        case 0:
            return [squares[2]]
        default:
            animationStep = -1
            return []
        }
    }
    
    func animateBlocks(blocks: [CALayer]) {
        var colorAnimation = CABasicAnimation(keyPath: "backgroundColor")
        colorAnimation.fromValue = squareColor.CGColor
        colorAnimation.toValue = highlightColor.CGColor

        var scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 1.0
        scaleAnimation.toValue = 1.2

        var animationGroup = CAAnimationGroup()
        animationGroup.autoreverses = true
        animationGroup.duration = animationDuration

        animationGroup.animations = [colorAnimation, scaleAnimation]
        
        for block in blocks {
            block.addAnimation(animationGroup, forKey: "backgroundColor")
        }
    }
    
    func animateHidden(hidden: Bool) {
        UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            if hidden {
                self.alpha = 0
            }
            else {
                self.alpha = 1
            }
        }) { (completion: Bool) -> Void in
            self.hidden = hidden
        }
    }
}