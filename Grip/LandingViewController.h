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
    __weak IBOutlet UIView *viewLogin;
    
    //Buttons
    IBOutletCollection(UIButton) NSArray *buttons;
    
    //Images
    __weak IBOutlet UIImageView *imageGripLogo;
    __weak IBOutlet UIImageView *imageCompanyLogo;
    
    //TextFields
    
    __weak IBOutlet UITextField *textfieldEmail;
    __weak IBOutlet UITextField *textfieldPassword;
}

//buttons
- (IBAction)login:(id)sender; //login button on the menu
- (IBAction)viewPackages:(id)sender;
- (IBAction)settings:(id)sender;
- (IBAction)help:(id)sender;

//the login button on the dialog
- (IBAction)dialogLogin:(id)sender;
- (IBAction)dialogLoginCancel:(id)sender;

@end
