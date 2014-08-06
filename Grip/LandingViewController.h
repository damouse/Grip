//
//  LandingViewController.h
//  Grip
//
//  Created by Mickey Barboi on 4/1/14.
//  Copyright (c) 2014 Mickey Barboi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LandingViewController : UIViewController {
    //Views
    __weak IBOutlet UIView *viewMenu;
    __weak IBOutlet UIView *viewLogos;
    
    //Buttons
    IBOutletCollection(UIButton) NSArray *buttons;
}

//buttons
- (IBAction)login:(id)sender;
- (IBAction)viewPackages:(id)sender;
@end
