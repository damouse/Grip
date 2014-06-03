//
//  DealViewController.h
//  Grip
//
//  Created by Mickey Barboi on 4/1/14.
//  Copyright (c) 2014 Mickey Barboi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DealViewController : UIViewController {
    //views
    __weak IBOutlet UIView *viewInfo;
    __weak IBOutlet UIView *viewPackages;
    
    //table
    __weak IBOutlet UITableView *tableProducts;
}

@end
