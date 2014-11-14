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
    __weak IBOutlet UIView *viewPresentDialog;

    __weak IBOutlet UICollectionView *collectionviewMerchandise;
    __weak IBOutlet UICollectionView *collectionviewCustomers;
    
    //settings fields
    __weak IBOutlet UISwitch *switchCustomizeProductCosts;
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

//present screen dialog
- (IBAction)customerMerchandiseDialogCancel:(id)sender;
- (IBAction)dialogPresent:(id)sender;

//settings
- (IBAction)customizeProductCostsInfo:(id)sender;

@end
