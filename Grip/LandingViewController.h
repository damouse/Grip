//
//  LandingViewController.h
//  Grip
//
//  Created by Mickey Barboi on 4/1/14.
//  Copyright (c) 2014 Mickey Barboi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Grip-Swift.h"

@interface LandingViewController : UIViewController {
    //Views
    __weak IBOutlet UIView *viewMenu;
    __weak IBOutlet UIView *viewLogin;
    __weak IBOutlet UIView *viewSettings;
    
    //Buttons
    IBOutletCollection(UIButton) NSArray *buttons;
    __weak IBOutlet UIButton *buttonLogin;
    
    //Images
    __weak IBOutlet UIImageView *imageGripLogo;
    __weak IBOutlet UIImageView *imageCompanyLogo;
    
    //TextFields
    __weak IBOutlet UITextField *textfieldEmail;
    __weak IBOutlet UITextField *textfieldPassword;
    
    //Searching, Customers, and Present Dialog
    __weak IBOutlet UIView *containerSearchController;
    __weak IBOutlet UIView *viewPresentDialog;
    
    //labels
    __weak IBOutlet UILabel *labelCustomerName;
    __weak IBOutlet UILabel *labelCustomerCreated;
    __weak IBOutlet UILabel *labelPackageCount;
    
    //Spinner
    __weak IBOutlet GripSpinner *spinnerCustomer;
}

//buttons
- (IBAction)login:(id)sender; //login button on the menu
- (IBAction)viewPackages:(id)sender;
- (IBAction)settings:(id)sender;
- (IBAction)help:(id)sender;

//the login button on the dialog
- (IBAction)dialogLogin:(id)sender;
- (IBAction)dialogLoginCancel:(id)sender;

- (IBAction)settingsDone:(id)sender;

//present package dialog buttons
- (IBAction)existingCustomer:(id)sender;
- (IBAction)newCustomer:(id)sender;



- (void) packageSelectedCustomer:(Customer *) customer;
- (void) packageDeselectedCustomer;
@end
