//
//  MCTableView.h
//  test
//
//  Created by Mickey Barboi on 9/2/13.
//  Copyright (c) 2013 HardinDD. All rights reserved.
//

#import <UIKit/UIKit.h>


//callback blocks for talbleview delegate
//assign this to the tableview if you need touch callbacks
typedef void (^MCDidSelectTableCell) (NSObject *modelObject, UITableViewCell *cell);
typedef void (^MCTableCellForRow) (NSObject *modelObject, UITableViewCell *cell, NSIndexPath *index);

@interface MCTableView : UITableView <UITableViewDataSource, UITableViewDelegate>

// the contents of the UICollectionView
@property (weak, nonatomic) NSArray *data;

@property (weak, nonatomic) NSString *reuseIdentifier;

- (void)reloadData:(BOOL)animated;

//DELEGATE CALLBACKS
//didselectcellatindexpath
@property (strong, nonatomic) MCDidSelectTableCell selectHandler;
@property (strong, nonatomic) MCTableCellForRow cellForRowHandler;
@end
