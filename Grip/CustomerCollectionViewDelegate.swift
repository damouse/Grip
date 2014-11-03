//
//  CustomerCollectionView.swift
//  Grip
//
//  Created by Mickey Barboi on 11/2/14.
//  Copyright (c) 2014 Mickey Barboi. All rights reserved.
//

import Foundation

class CustomerCollectionViewDelegate : NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
    var collection: UICollectionView
    
    var selectedCustomer: Customer?
    var selectedCell: CustomerMerchCollectionCell?
    
    var customers: [Customer] = [Customer]() {
        didSet {
            customers.insert(Customer(), atIndex: 0)
            collection.reloadData()
        }
    }
    
    
    init(view: UICollectionView) {
        collection = view
        
        super.init()

        collection.delegate = self;
        collection.dataSource = self;
        
        customers.append(Customer())
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return customers.count
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("customerCell", forIndexPath: indexPath) as CustomerMerchCollectionCell
        
        //if first cell, this is the cell that signifies a new customer
        if indexPath.row == 0 {
            cell.labelName.text = ""
            cell.showPlus()
        }
        else {
            let customer = customers[indexPath.row]
            
            cell.labelName.text = customer.name
            
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
            if selectedCustomer != nil {
                selectedCell?.deselectCell()
            }
            
            selectedCell = newCell
            selectedCell?.selectCell()
            selectedCustomer = customers[indexPath.row]
        }
    }
}