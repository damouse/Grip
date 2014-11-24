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

#import "Grip-Swift.h"

@interface DealViewController : GAITrackedViewController {
    //views
    __weak IBOutlet UIView *viewInfo;
    __weak IBOutlet UIView *viewInfoDetails;
    __weak IBOutlet UIView *viewProductDetails;
    __weak IBOutlet UIView *viewPackages;

    __weak IBOutlet UIView *viewBottomLeftContainer; //cancel, complete buttons
    __weak IBOutlet UIView *viewBottomRightContainer; //undo, walkthrough
    
    __weak IBOutlet UIView *viewPresetPackageSlidein;
    __weak IBOutlet UIView *viewCustomerPackageSlideIn;
    
    __weak IBOutlet UIView *viewEditDialog;
    
    //tables
    __weak IBOutlet UITableView *tableProducts;
    __weak IBOutlet UITableView *tableCustomerPackages;
    __weak IBOutlet UITableView *tablePresetPackages;
    
    //Buttons
    IBOutletCollection(UIButton) NSArray *buttons;
    __weak IBOutlet UIButton *buttonStockPackages;
    __weak IBOutlet UIButton *buttonCustomerPackages;
    
    //Package Details Views
    __weak IBOutlet UILabel *labelProductName;
    __weak IBOutlet UIImageView *imageProductImage;
    __weak IBOutlet UITableView *tableviewDetails;

    
    //User and Merchandise Details
    __weak IBOutlet UITextView *labelDetailsMerchandiseDescription;
    __weak IBOutlet UIImageView *imageDetailsMerchandise;
    __weak IBOutlet UIImageView *imageMerchandise;
}

//passed in from the landing controller
@property (strong, nonatomic) Dealmaker *dealmaker;


//buttons within slidein info panes
- (IBAction)infoDetailsExit:(id)sender;
- (IBAction)productDetailsExit:(id)sender;

//bottom buttons
- (IBAction)cancel:(id)sender;
- (IBAction)complete:(id)sender;
- (IBAction)walkthrough:(id)sender;
- (IBAction)undo:(id)sender;

//gesture recognizers
- (IBAction)infoTapped:(id)sender;

//delegate methods
- (void) didTouchProduct:(ProductReceipt *) product;
- (void) didSelectProduct:(ProductReceipt *) product;

//callbacks from TextfieldDelegate
- (void) animateStateShowingInfo:(bool) info;


//labels and textfields-- managed by DealTextfieldDelegate
@property (weak, nonatomic) IBOutlet UITextField *textfieldTerm;
@property (weak, nonatomic) IBOutlet UITextField *textfieldApr;
@property (weak, nonatomic) IBOutlet UITextField *textfieldMonthly;
@property (weak, nonatomic) IBOutlet UITextField *textfieldPackageDiscount;

@property (weak, nonatomic) IBOutlet UITextField *textviewProductPrice;
@property (weak, nonatomic) IBOutlet UITextField *textfieldDownPayment;

@property (weak, nonatomic) IBOutlet UILabel *labelApr;
@property (weak, nonatomic) IBOutlet UILabel *labelMonthlyPayment;
@property (weak, nonatomic) IBOutlet UILabel *labelLoanTerm;
@property (weak, nonatomic) IBOutlet UILabel *labelCustomerName;

@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *textfields;

//Edit Dialog for customers and merchandise
@property (weak, nonatomic) IBOutlet UITextField *textfieldCustomerName;
@property (weak, nonatomic) IBOutlet UITextField *textfieldCustomerEmail;
@property (weak, nonatomic) IBOutlet UITextField *textfieldMerchandisePrice;
@property (weak, nonatomic) IBOutlet UITextField *textfieldMerchandiseName;

@property (weak, nonatomic) IBOutlet UILabel *labelMerchandiseName;
@property (weak, nonatomic) IBOutlet UILabel *labelDetailsMerchandiseName;
@property (weak, nonatomic) IBOutlet UILabel *labelMerchandisePrice;
@property (weak, nonatomic) IBOutlet UILabel *labelCustomerEmail;

- (IBAction)editCustomerMerchandiseDone:(id)sender;
- (IBAction)editCustomerMerchandise:(id)sender;

@end
