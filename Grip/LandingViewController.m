//
//  LandingViewController.m
//  Grip
//
//  Created by Mickey Barboi on 4/1/14.
//  Copyright (c) 2014 Mickey Barboi. All rights reserved.
//

// you either black out a hero or drink long enough to see yourself become the villain


#import "LandingViewController.h"
#import "MBViewAnimator.h"
#import "UIView+Utils.h"
#import "DealViewController.h"

#import <QuartzCore/QuartzCore.h>
#import "SignatureViewQuartzQuadratic.h"

#import "UIButton+Utils.h"


@interface LandingViewController () {
    MBViewAnimator *animator;
    
    PGApiManager *apiManager;
    
    //customer and merchandise selection for package presentation dialog
    MerchandiseCollectionViewDelegate *collectionMerchandiseDelegate;
    CustomerCollectionViewDelegate *collectionCustomerDelegate;
  
    BOOL loggedIn;
    
    BOOL firstLayout;
    BOOL displayingLogin;
    BOOL displayingSettings;
    BOOL displayingPackageCustomer;
}

@end

@implementation LandingViewController

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    //default to not logged in
    loggedIn = false;
    displayingLogin = false;
    displayingSettings = false;
    displayingPackageCustomer = false;
	
    animator = [[MBViewAnimator alloc] initWithDuration:ANIMATION_DURATION];
    
    apiManager = [PGApiManager sharedInstance];

    //DEBUG
        [apiManager logInAttempt:@"dealer@test.com" password:@"12345678" view: self.view success:^(void) {
            loggedIn = true;
    
            [self dismissLogin];
            [self showBothLogos];
            [self setLoginButtonState];
    
            collectionCustomerDelegate.customers = apiManager.customers;
            collectionMerchandiseDelegate.merchandises = apiManager.merchandises;
    
            [imageCompanyLogo setImage:apiManager.user.image];
        }];
}

- (void) viewWillAppear:(BOOL)animated {
    //didLayoutSubviews must run before we can init animation views, but we don't want to run the init methods again after
    firstLayout = true;
    
    [self colorize];
    [self setLoginButtonState];
    
    [self setupCollectionViews];
}

- (void) viewDidLayoutSubviews {
    //Called whenever the view changes its views' layouts, the following is the init code which should only be
    //run the first time
    if (firstLayout) {
        //prepare holder views for animation
        [animator initObject:viewMenu inView:self.view forSlideinAnimation:VAAnimationDirectionRight];
        
        //logo images
        [animator initObject:imageGripLogo inView:self.view forSlideinAnimation:VAAnimationDirectionLeft];
        [animator initObject:imageCompanyLogo inView:self.view forSlideinAnimation:VAAnimationDirectionLeft];
        
        //dialogs
        [animator initObject:viewLogin inView:self.view forSlideinAnimation:VAAnimationDirectionDown];
        [animator initObject:viewSettings inView:self.view forSlideinAnimation:VAAnimationDirectionDown];
        [animator initObject:viewPresentDialog inView:self.view forSlideinAnimation:VAAnimationDirectionDown];
    
        firstLayout = false;
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [self initialAnimations];
    
    //DEBUG LOGIN
//    [apiManager logInAttempt:@"dealer@test.com" password:@"12345678" view: self.view success:^(void) {
//        loggedIn = true;
//        
//        [self dismissLogin];
//        [self showBothLogos];
//        [self setLoginButtonState];
//        
//        collectionCustomerDelegate.customers = apiManager.customers;
//        collectionMerchandiseDelegate.merchandises = apiManager.merchandises;
//        
//        [imageCompanyLogo setImage:apiManager.user.image];
//    }];
}

- (void) colorize {
    //Colorize the view based on the constants. Here for quick changing
    self.view.backgroundColor = PRIMARY_LIGHT;
    viewMenu.backgroundColor = PRIMARY_DARK;
    viewLogin.backgroundColor = PRIMARY_DARK;
    viewSettings.backgroundColor = PRIMARY_DARK;
    viewPresentDialog.backgroundColor = PRIMARY_DARK;
    
    collectionviewCustomers.backgroundColor = PRIMARY_DARK;
    collectionviewMerchandise.backgroundColor = PRIMARY_DARK;
    
    for(UIButton *button in buttons) {
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitleColor:HIGHLIGHT_COLOR forState:UIControlStateHighlighted];
        button.adjustsImageWhenHighlighted = YES;
    }
    
    textfieldEmail.backgroundColor = PRIMARY_LIGHT;
    textfieldPassword.backgroundColor = PRIMARY_LIGHT;
}

- (void) setupCollectionViews {
    //set up collection views
    collectionMerchandiseDelegate = [[MerchandiseCollectionViewDelegate alloc] initWithView:collectionviewMerchandise];
    collectionCustomerDelegate = [[CustomerCollectionViewDelegate alloc] initWithView:collectionviewCustomers];
}


#pragma mark Login Flow


#pragma mark Search, Customers, and Merchandise
- (void) presentPackage {
    [self closingAnimations];
    
    [animator animateObjectOffscreen:viewPresentDialog completion:^(BOOL completion){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        DealViewController *dealController = [storyboard instantiateViewControllerWithIdentifier:@"dealViewController"];
        
        Product *merchandise = collectionMerchandiseDelegate.selectedMerchandise;
        Customer *customer = collectionCustomerDelegate.selectedCustomer;
        
        Dealmaker *dealmaker = [[Dealmaker alloc] initWithAllProducts:apiManager.products user:apiManager.user customer:customer merchandise:merchandise];
        
        dealmaker.customerPackages = customer.packages;
        dealmaker.userPackages = apiManager.packages;
        
        dealController.dealmaker = dealmaker;
        
        [self.navigationController pushViewController:dealController animated:NO];
    }];
}

- (void) checkCustomerAndMerchandise {
    //check the customer and the merchandise fields from the dialog table, filling them in if needed
    //this method is recalled at the end of every completed alert
    
    if (collectionMerchandiseDelegate.selectedMerchandise.name == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New Merchandise" message:@"Please enter a name for the new Merchandise" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Done", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alert show];
    }
    else if (collectionCustomerDelegate.selectedCustomer.name == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New Customer" message:@"Please enter a name for the new Customer" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Done", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alert show];
    }
    else
        [self presentPackage];
}


#pragma mark Delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

    NSString *newString =[textField.text stringByReplacingCharactersInRange:range withString:string];
    
    //strip/check leading whitespace
    newString = [newString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    newString = [NSString stringWithFormat:@"  %@", newString];
    
    [textField setText:newString];
    return NO;
}


#pragma mark General Animations
- (void) initialAnimations {
//    bring the buttons onscreen
    [animator animateObjectOnscreen:viewMenu completion:nil];
//    [animator animateObjectOnscreen:imageGripLogo completion:nil];

    //register resizing and moving animations with animator
    [animator registerCustomAnimationForView:imageGripLogo key:@"initial login position" size:.6 x:0 y:200];
    [animator registerCustomAnimationForView:imageCompanyLogo key:@"initial login position" size:.6 x:0 y:-200];
    
    //clear the top of the screen so the dialogs have space
    [animator registerCustomAnimationForView:imageGripLogo key:@"clear top" size:.5 x:200 y:230];
    [animator registerCustomAnimationForView:imageCompanyLogo key:@"clear top" size:.5 x:-120 y:230];
    
    [self showBothLogos];
}

- (void) closingAnimations {
    [self logosOffScreen];
}

- (void) setLoginButtonState {
    if (loggedIn)
        [buttonLogin setTitle:@"LOG OUT" forState:UIControlStateNormal];
    else
        [buttonLogin setTitle:@"LOGIN" forState:UIControlStateNormal];
}


#pragma mark Logo Animations
- (void) logosToBottom {
    //move the logos to the bottom of the screen, clearing space for the top section
    [animator animateCustomAnimationForView:imageGripLogo andKey:@"clear top" completion:nil];
    
    if(loggedIn)
        [animator animateCustomAnimationForView:imageCompanyLogo andKey:@"clear top" completion:nil];
}

- (void) showBothLogos {
    //animate second logo onto the view
    //shrink the first logo and animate it down
    if (loggedIn) {
        [animator animateCustomAnimationForView:imageGripLogo andKey:@"initial login position" completion:nil];
        [animator animateCustomAnimationForView:imageCompanyLogo andKey:@"initial login position" completion:nil];
    }
    
    //if not logged in put the grip logo back into place
    else {
        [animator animateObjectToStartingPosition:imageGripLogo completion:nil];
    }
}

- (void) showOnlyGripLogo {
    //reset logos
    [animator animateObjectToStartingPosition:imageGripLogo completion:nil];
    [animator animateObjectOffscreen:imageCompanyLogo completion:nil];
}

- (void) logosOffScreen {
    [animator animateObjectOffscreen:imageCompanyLogo completion:nil];
    [animator animateObjectOffscreen:imageGripLogo completion:nil];
}


#pragma mark Pane Animations
- (void) presentLogin {
    if (displayingSettings)
        [self dismissSettings];
    
    [animator animateObjectOnscreen:viewLogin completion:nil];
    
    [self logosToBottom];
    displayingLogin = true;
}

- (void) dismissLogin {
    if (!displayingLogin) {
        NSLog(@"Landing: WARN: asked to dismiss login, but login is not visible!");
        return;
    }
    
    [animator animateObjectOffscreen:viewLogin completion:nil];
    displayingLogin = false;
    [self showBothLogos];
}

- (void) presentSettings {
    if (displayingLogin)
        [self dismissLogin];
    
    if (displayingPackageCustomer)
        [self dismissPackageCustomer];
    
    [animator animateObjectOnscreen:viewSettings completion:nil];
    [self logosToBottom];
    displayingSettings = true;
}

- (void) dismissSettings {
    if (!displayingSettings) {
        NSLog(@"Landing: WARN: asked to dismiss settings, but settings is not visible!");
        return;
    }
    
    [animator animateObjectOffscreen:viewSettings completion:nil];
    displayingSettings = false;
    [self showBothLogos];
}

- (void) presentPackageCustomer {
    if(displayingSettings)
        [self dismissSettings];
    
    [self logosOffScreen];
    [animator animateObjectOffscreen:viewMenu completion:^(BOOL completed) {
        [animator animateObjectOnscreen:viewPresentDialog completion:nil];
    }];
    
    displayingPackageCustomer = true;
}

- (void) dismissPackageCustomer {
    if (!displayingPackageCustomer) {
        NSLog(@"Landing: WARN: asked to dismiss packagecustomers, but settings is not visible!");
        return;
    }
    
    [animator animateObjectOffscreen:viewPresentDialog completion:^(BOOL done) {
        [animator animateObjectOnscreen:viewMenu completion:nil];
        [self showBothLogos];
    }];
        
    displayingPackageCustomer = false;
    
}


#pragma mark IBActions
- (IBAction) login:(id)sender {
    if (loggedIn) {
        loggedIn = false;
        [self setLoginButtonState];
        [self showOnlyGripLogo];
        [self dismissSettings];
        [self dismissPackageCustomer];
    }
    else {
        [self presentLogin];
    }
}

- (IBAction) viewPackages:(id)sender {
    if (!loggedIn) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Error"] message:@"You must log in first!"  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [self presentPackageCustomer];
}

- (IBAction) settings:(id)sender {
    [self presentSettings];
}

- (IBAction) dialogLogin:(id)sender {
    NSString *email = [textfieldEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *password = [textfieldPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    [apiManager logInAttempt:email password:password view: self.view success:^(void) {
        loggedIn = true;
        
        [self dismissLogin];
        [self showBothLogos];
        [self setLoginButtonState];
        
        //set the collection views' models
        collectionCustomerDelegate.customers = apiManager.customers;
        collectionMerchandiseDelegate.merchandises = apiManager.merchandises;
        
        [imageCompanyLogo setImage:apiManager.user.image];
    }];
}

- (IBAction) dialogLoginCancel:(id)sender {
    [self dismissLogin];
}

- (IBAction) customerMerchandiseDialogCancel:(id)sender {
    [self dismissPackageCustomer];
}

- (IBAction) dialogPresent:(id)sender {
    if (collectionMerchandiseDelegate.selectedMerchandise == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Error"] message:@"Please select an existing merchandise item or create a new one"  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if (collectionCustomerDelegate.selectedCustomer == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Error"] message:@"Please select an existing customer or create a new one"  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [self checkCustomerAndMerchandise];
}

- (IBAction) settingsDone:(id)sender {
    [self dismissSettings];
}

- (IBAction) help:(id)sender {
//    [apiManager TEST];
}


#pragma mark AlertView Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0)
        return;
    
    if ([alertView.title isEqualToString: @"New Merchandise"]) {
        collectionMerchandiseDelegate.selectedMerchandise.name = [alertView textFieldAtIndex:0].text;
    }
    else if ([alertView.title isEqualToString: @"New Customer"]) {
        collectionCustomerDelegate.selectedCustomer.name = [alertView textFieldAtIndex:0].text;
    }

    [self checkCustomerAndMerchandise];
}
@end
