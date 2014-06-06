//
//  ProductTableViewDelegate.h
//  Grip
//
//  Created by Mickey Barboi on 6/4/14.
//  Copyright (c) 2014 Mickey Barboi. All rights reserved.
//

/**
 Class is responsible for management of the table and associated model object. Owned solely by 
 DealViewController, but pulled aside for the sake of encapsulation. 
 
 Must provide an interface to expose selected package information, such as cumulative price, to 
 the owning controller for feeding into the other modules of the controller.
 
 NOTES:
    Making cells draggable: http://stackoverflow.com/questions/16266907/trying-to-make-uitableviewcell-slideable-and-tappable-while-also-keeping-the-ui
 */

#import <Foundation/Foundation.h>
#import "DealViewController.h"


@interface ProductTableViewDelegate : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) NSMutableArray *products;
@property (weak, nonatomic) DealViewController *parent;
@property (weak, nonatomic) UITableView *tableView;

//TESTING SWIPING CELLS
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@end
