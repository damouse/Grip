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
    
    init(view: UICollectionView) {
        collection = view
        
        super.init()
        
        collection.delegate = self;
        collection.dataSource = self;
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("merchandiseCell", forIndexPath: indexPath) as MerchandiseCollectionCell
        
        cell.labelName.text = "Cell \(indexPath.row)"
        
        return cell
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        println("Touch on Merch")
    }
}