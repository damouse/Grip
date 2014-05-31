//
//  MCCollectionView.h
//  test
//
//  Created by Mickey Barboi on 9/2/13.
//  Copyright (c) 2013 HardinDD. All rights reserved.
//

#import <UIKit/UIKit.h>

//assign this to the tableview if you need touch callbacks
typedef void (^MCDidSelectCollectionCell)(NSObject *modelObject, UICollectionViewCell *cell);
typedef void (^MCCollectionCellForRow)(NSObject *modelObject, UICollectionViewCell *cell, NSIndexPath *index);

@interface MCCollectionView : UICollectionView <UICollectionViewDataSource, UICollectionViewDelegate>

// the contents of the UICollectionView
@property (weak, nonatomic) NSArray *data;

//register class for use as a cell
@property (weak, nonatomic) Class cellClass;

@property (weak, nonatomic) NSString *reuseIdentifier;

//DELEGATE CALLBACKS
//didselectcellatindexpath
@property (strong, nonatomic) MCDidSelectCollectionCell selectHandler;
@property (strong, nonatomic) MCCollectionCellForRow cellForRowHandler;
@end
