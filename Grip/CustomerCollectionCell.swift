//
//  CustomerCollectionCell.swift
//  Grip
//
//  Created by Mickey Barboi on 11/2/14.
//  Copyright (c) 2014 Mickey Barboi. All rights reserved.
//

import Foundation

class  CustomerCollectionCell : UICollectionViewCell {
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelPackages: UILabel!
    @IBOutlet weak var labelDate: UILabel!
    
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
    }}