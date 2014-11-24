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
    
    //Google Analytics
    self.screenName = @"Landing Screen";

    //default to not logged in
    loggedIn = false;
    displayingLogin = false;
    displayingSettings = false;
    displayingPackageCustomer = false;
	
    animator = [[MBViewAnimator alloc] initWithDuration:ANIMATION_DURATION];
    
    apiManager = [PGApiManager sharedInstance];
    
    //wide, sweeping appearance changes
    [PGAppearance setAppearance];

    //DEBUG
    textfieldEmail.text = @"demo@test.com";
    textfieldPassword.text = @"12345678";
    [self performLogin];
}

- (void) viewWillAppear:(BOOL)animated {
    //didLayoutSubviews must run before we can init animation views, but we don't want to run the init methods again after
    firstLayout = true;
    
    [self colorize];
    [self setLoginButtonState];
    
    [self setupCollectionViews];
    
    //called regardless if user is logged in or not, the default settings are applied
    [self populateSettings:apiManager.setting];
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
    
    //if user is already logged in, be sure to populate relevant fields
    if (loggedIn) {
        collectionCustomerDelegate.customers = apiManager.customers;
        collectionMerchandiseDelegate.merchandises = apiManager.merchandises;
    }
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
    
    infoProductCosts.tintColor = HIGHLIGHT_COLOR;
}

- (void) setupCollectionViews {
    //set up collection views
    collectionMerchandiseDelegate = [[MerchandiseCollectionViewDelegate alloc] initWithView:collectionviewMerchandise];
    collectionCustomerDelegate = [[CustomerCollectionViewDelegate alloc] initWithView:collectionviewCustomers];
}


#pragma mark Login Flow
- (void) performLogin {
    //actually performs the login with the text in the boxes
    apiManager.userEmail = [textfieldEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    apiManager.userPassword = [textfieldPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    [apiManager loadResources:self.view completion:^(BOOL status) {
        if (status == true) {
            loggedIn = true;
            
            [self dismissLogin];
            [self showBothLogos];
            [self setLoginButtonState];
            [self populateSettings:apiManager.setting];
            
            textfieldPassword.text = @"";
            
            //set the collection views' models
            collectionCustomerDelegate.customers = apiManager.customers;
            collectionMerchandiseDelegate.merchandises = apiManager.merchandises;
            
            [imageCompanyLogo setImage:apiManager.user.image];
            
            if (!apiManager.user.demoUser) {
                [Analytics login];
            }
        }
        else {
            NSLog(@"LOGIN FAILED");
        }
    }];
}


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
    
    //check if the settings changed, and if so attempt to update with backend
    [self changeSettings];
    
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
        
        apiManager.userEmail = @"";
        apiManager.userPassword = @"";
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
    [textfieldEmail resignFirstResponder];
    [textfieldPassword resignFirstResponder];
    
    if ([textfieldEmail.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Login Error"] message:@"Email cannot be blank"  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
    else if  ([textfieldPassword.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Login Error"] message:@"Password cannot be blank"  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
    else {
        [self performLogin];
    }
}

- (IBAction) dialogLoginCancel:(id)sender {
    [textfieldEmail resignFirstResponder];
    [textfieldPassword resignFirstResponder];
    
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
    
    [self presentPackage];
}

- (IBAction) settingsDone:(id)sender {
    [self dismissSettings];
}

- (IBAction) help:(id)sender {
    [self closingAnimations];
    
    [animator animateObjectOffscreen:viewPresentDialog completion:^(BOOL completion){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        TutorialViewController *tutorial = [storyboard instantiateViewControllerWithIdentifier:@"tutorial"];
        [self.navigationController pushViewController:tutorial animated:YES];
    }];
}


#pragma mark IBActions- Settings
- (void) populateSettings:(Setting *) settings {
    //populate the settings fields with settings objects
    [switchCustomizeProductCosts setOn:settings.customize_product_cost];
}

- (void) changeSettings {
    //looks at all of the switches in the settings section and upload a new settings object if they changed
    if (switchCustomizeProductCosts.isOn != apiManager.setting.customize_product_cost) {
        
        //perform changes
        apiManager.setting.customize_product_cost = switchCustomizeProductCosts.isOn;
        
        //issue call
        [apiManager updateSettings:self.view completion:^(BOOL completed) {
            NSLog(@"Settings updated");
        }];
    }
}

- (IBAction)customizeProductCostsInfo:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Settings Info" message:@"Permit product prices to be changed while a package is being presented." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alert show];
}


#pragma mark AlertView Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0)
        return;
    
    if ([alertView.title isEqualToString: @"Login Eror"] || [alertView.title isEqualToString: @"Settings Info"]) {
        return;
    }
}


#pragma mark Textfield Delegate
- (BOOL) textFieldShouldReturn:(UITextField *)textView {
    [textView resignFirstResponder];
    return YES;
}
@end
