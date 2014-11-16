//
//  MerchandiseCollectionView.swift
//  Grip
//
//  Created by Mickey Barboi on 11/2/14.
//  Copyright (c) 2014 Mickey Barboi. All rights reserved.
//

import Foundation

class MerchandiseCollectionViewDelegate : NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
    var collection: UICollectionView
    
    var selectedMerchandise: Product?
    var selectedCell: CustomerMerchCollectionCell?
    
    var merchandises: [Product] = [Product]() {
        didSet {
            let blankProduct = Product()
            blankProduct.type = "Merchandise"
            merchandises.insert(blankProduct, atIndex: 0)
            collection.reloadData()
        }
    }


    init(view: UICollectionView) {
        collection = view
        
        super.init()
        
        collection.delegate = self;
        collection.dataSource = self;
        
        merchandises.append(Product())
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return merchandises.count 
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("merchandiseCell", forIndexPath: indexPath) as CustomerMerchCollectionCell
        
        if indexPath.row == 0 {
            cell.labelName.text = ""
            cell.showPlus()
        }
        else {
            let merch = merchandises[indexPath.row]
            cell.labelName.text = merch.name
            
            cell.hidePlus()
        }
        
        //make sure the selected color doesn't go away if the collection scrolls
        if cell == selectedCell {
            cell.backgroundColor = HIGHLIGHT_COLOR
        }
        else {
            cell.backgroundColor = PRIMARY_LIGHT
        }
        
        return cell
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let newCell = collectionView.cellForItemAtIndexPath(indexPath) as? CustomerMerchCollectionCell
        
        //note: cannot deselect a cell, something is always selected
        if newCell != selectedCell {
            if selectedMerchandise != nil {
                selectedCell?.deselectCell()
            }
            
            selectedCell = newCell
            selectedCell?.selectCell()
            selectedMerchandise = merchandises[indexPath.row]
        }
    }
}