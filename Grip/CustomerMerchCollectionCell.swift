//
//  CustomerCollectionCell.swift
//  Grip
//
//  Created by Mickey Barboi on 11/2/14.
//  Copyright (c) 2014 Mickey Barboi. All rights reserved.
//

import Foundation

class  CustomerMerchCollectionCell : UICollectionViewCell {
    @IBOutlet weak var labelName: UILabel!

    @IBOutlet weak var imagePlus: UIImageView!
    
    var isNewCell = false
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        colorize()
    }
    
    func colorize() {
        self.backgroundColor = PRIMARY_LIGHT
    }
    
    func selectCell() {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            if self.isNewCell {
                self.imagePlus.image = UIImage(named: "NewWhite")
            }
            else {
                self.imagePlus.image = nil
            }
            
            self.backgroundColor = HIGHLIGHT_COLOR
        })
    }
    
    func deselectCell() {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            if self.isNewCell {
                self.imagePlus.image = UIImage(named: "New")
            }
            else {
                self.imagePlus.image = nil
            }
            
            self.backgroundColor = PRIMARY_LIGHT
        })
    }
    
    func showPlus() {
        //shows the plus sign 
        imagePlus.image = UIImage(named: "New")
        isNewCell = true
    }
    
    func hidePlus() {
        //hides the plus image
        imagePlus.image = nil
        isNewCell = false
    }
}