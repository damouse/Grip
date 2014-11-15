//
//  File.swift
//  Grip
//
//  Created by Mickey Barboi on 11/14/14.
//  Copyright (c) 2014 Mickey Barboi. All rights reserved.
//

/**
Collapsable cell used for displaying product descriptions in the accordion table.
*/

import Foundation

class DetailsCell : UITableViewCell {
    
    @IBOutlet weak var viewTitleBar: UIView!
    @IBOutlet weak var viewArrow: UIView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var textviewDescription: UITextView!
    
    @IBOutlet weak var viewVideo: YTPlayerView!
    
    var chevron: CAShapeLayer?
    
    func showVideo(show: Bool, url: String?) {
        
        textviewDescription.hidden = show
        viewVideo.hidden = !show
        
        //optionally show or hide the video
        if show {
            viewVideo.loadWithVideoId(url!)
        }
        else {
            viewVideo.clearVideo()
        }
    }
    
    func animateColor(active: Bool) {
        //animate the top view to color, or not to colo
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            if active {
                self.viewTitleBar.backgroundColor = HIGHLIGHT_COLOR
                self.labelTitle.textColor = UIColor.whiteColor()
                self.chevron?.fillColor = UIColor.whiteColor().CGColor
                self.viewArrow.transform = CGAffineTransformMakeRotation(-CGFloat(M_PI))
                
                //while this doesn't work, its pretty funny
                //self.chevron?.transform = CATransform3DMakeRotation(CGFloat(M_PI_2), 0.0, 0.0, 1.0)
            }
            else {
                self.viewTitleBar.backgroundColor = PRIMARY_LIGHT
                self.labelTitle.textColor = PRIMARY_DARK
                self.chevron?.fillColor = PRIMARY_DARK.CGColor
                self.viewArrow.transform = CGAffineTransformMakeRotation(CGFloat(-0))
            }
        }, completion:nil)
    }
    
    func colorize() {
        viewTitleBar.backgroundColor = PRIMARY_LIGHT
        self.contentView.backgroundColor = PRIMARY_LIGHT
        
        textviewDescription.textColor = P_TEXT_COLOR
        
        labelTitle.textColor = PRIMARY_DARK
        
        if chevron == nil {
            //draw the arrow on the right of the cell
            let length = viewArrow.frame.size.width
            let path = UIBezierPath()
            chevron = CAShapeLayer()
            let thickness : CGFloat = 7.0
            
            path.moveToPoint(CGPointMake(0, length / 2))
            path.addLineToPoint(CGPointMake(length / 2, 0))
            path.addLineToPoint(CGPointMake(length, length / 2))
            
            path.addLineToPoint(CGPointMake(length - thickness, length / 2))
            path.addLineToPoint(CGPointMake(length / 2, thickness))
            path.addLineToPoint(CGPointMake(thickness, length / 2))
            
            path.closePath()
            chevron!.path = path.CGPath
            chevron?.fillColor = PRIMARY_DARK.CGColor
            
            //these two lines don't work because you're not drawing using CG, but using CA.
            //CG directly draws onto the current context using graphics commands, and is a little lower level
            //CA handles the drawing itself, you just pass it the shape
            //            PRIMARY_DARK.setFill()
            //            path.fill()
            
            
            viewArrow.layer.addSublayer(chevron!)
        }
    }
}