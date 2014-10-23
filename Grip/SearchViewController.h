//
//  TPSMasterViewController.h
//  Sample-UISearchController
//
//  Created by James Dempsey on 7/4/14.
//  Copyright (c) 2014 Tapas Software. All rights reserved.
//
//  Based on Apple sample code TableSearch version 2.0
//

#import <UIKit/UIKit.h>
#import "LandingViewController.h"

@interface SearchViewController : UITableViewController

@property (nonatomic, strong) NSArray *customers;
@property (nonatomic, weak) LandingViewController *parent;

@property (nonatomic, strong) Customer *selectedCustomer;
@end

