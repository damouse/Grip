//
//  TutorialViewController.swift
//  Grip
//
//  Created by Mickey Barboi on 11/22/14.
//  Copyright (c) 2014 Mickey Barboi. All rights reserved.
//

import UIKit

class TutorialViewController: GAITrackedViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak var collectionMain: UICollectionView!
    var images : [UIImage]
    var showAll = true
    
    
    override func viewDidLoad() {\
        if showAll {
        images = [UIImage(named:"1")!, UIImage(named:"2")!, UIImage(named:"3")!, UIImage(named:"4")!, UIImage(named:"5")!, UIImage(named:"6")!, UIImage(named:"7")!, UIImage(named:"8")!, UIImage(named:"9")!]
        }
        else {
            
        }
        
        super.viewDidLoad()
        
        //Google Analytics
        self.screenName = "Tutorial";
    }
    
    required init(coder aDecoder: NSCoder) {
        images = []
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    
    //MARK: IBActions
    @IBAction func done(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    
    //MARK: Delegate methods
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count;
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as TutorialCollectionViewCell
        cell.imageviewScene.image = images[indexPath.row]
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

    }
}

class TutorialCollectionViewCell : UICollectionViewCell {
    @IBOutlet weak var imageviewScene: UIImageView!
}