//
//  DealViewController.h
//  Grip
//
//  Created by Mickey Barboi on 4/1/14.
//  Copyright (c) 2014 Mickey Barboi. All rights reserved.
//

/**
 Controller responsible for displaying products and packages in pre-assembled flavors. 
 
 Note that the controller delegates most of this work out to other objects, it only coordinates
 between them. 
 
 These objects are the productTable, infoPane, and packagePane.
 
 Successfully finishing a deal transitions to the contract controller. 
 */

#import <UIKit/UIKit.h>

@interface DealViewController : UIViewController {
    //views
    __weak IBOutlet UIView *viewInfo;
    __weak IBOutlet UIView *viewPackages;
    
    __weak IBOutlet UIView *viewBottomLeftContainer; //cancel, complete buttons
    __weak IBOutlet UIView *viewBottomRightContainer; //undo, walkthrough
    
    //table
    __weak IBOutlet UITableView *tableProducts;
}

//bottom buttons
- (IBAction)cancel:(id)sender;
- (IBAction)complete:(id)sender;
- (IBAction)walkthrough:(id)sender;
- (IBAction)undo:(id)sender;

@end
