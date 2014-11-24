//
//  DealViewController.m
//  Grip
//
//  Created by Mickey Barboi on 4/1/14.
//  Copyright (c) 2014 Mickey Barboi. All rights reserved.
//  GOAL: use an HCF somewhere in here


#import "DealViewController.h"
#import "MBViewAnimator.h"
#import "UIView+Utils.h"
#import "ProductTableViewDelegate.h"
#import "DealTextfieldDelegate.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImageView+WebCache.h"

#import "Grip-Swift.h"

@interface DealViewController (){
    MBViewAnimator *animator;
    ProductTableViewDelegate *tableDelegate;
    
    //package table delegates
    PackageTableViewDelegate *userPackageDelegate;
    PackageTableViewDelegate *customerPackageDelegate;
    
    //product info table controller
    AccordionDescriptionTable *productDetails;
    
    //manages all of the textfields and labels, interacts with the maker
    DealTextfieldDelegate *textfieldDelegate;
    
    //two-pane slider
    MBViewPaneSlider *paneSlider;
    
    Rollback *rollback;
    
    //enumed below
    int currentUIState;
    
    //the last discount choosen not from a package
    int lastCustomDiscount;
    
    //stops clicks from passing through to the rest of the views if the edit dialog is up
    UIView *touchBlocker;
}

typedef enum UIState{
    StateNeutral,
    StateShowingInfo,
    StateShowingProduct,
    StateShowingInfoUp,
    StateShowingNewDialog
} UIState;

@end

@implementation DealViewController


#pragma mark Lifecycle Methods
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
    self.screenName = @"Package Screen";
    
    //roll it back now, yall
    rollback = [[Rollback alloc] initWithUndoBlock:^(ProductReceipt * product) {
        [self selectProduct:product];
    }];
    
    //main table init
    tableDelegate = [[ProductTableViewDelegate alloc] init];
    tableDelegate.parent = self;
    tableDelegate.dataSource = self.dealmaker;
    tableDelegate.tableView = tableProducts;
    
    tableProducts.delegate = tableDelegate;
    tableProducts.dataSource = tableDelegate;
    
    //product info
    productDetails = [[AccordionDescriptionTable alloc] initWithTable:tableviewDetails];
    
    //validation, formatting, and whatnot
    textfieldDelegate = [[DealTextfieldDelegate alloc] init];
    textfieldDelegate.parent = self;
    
    //package table inits
    __weak DealViewController *weak_self = self;
    customerPackageDelegate = [[PackageTableViewDelegate alloc] initWithPacks:self.dealmaker.customerPackages tableView:tableCustomerPackages selectBlock:^(Package *package) {
        [weak_self selectPackage:package];
    }];
    
    userPackageDelegate = [[PackageTableViewDelegate alloc] initWithPacks:self.dealmaker.userPackages tableView:tablePresetPackages selectBlock:^(Package *package) {
        [weak_self selectPackage:package];
    }];
    
    //dealmaker package match callback (note: work around to avoid the circular dependancies when requiring the swift files with this deal controller)
    self.dealmaker.packageMatch = ^(Package* package) {
        [weak_self packageMatch:package];
    };
}

- (void) viewWillAppear:(BOOL)animated {
    [self initAnimations];
    [self setInitialLabels];
    
    touchBlocker = nil;
    
    //weird bug. The table is overlapping the option bars for unknown reasons. Because
    //clipsSubviews is turned off,
    [self.view bringSubviewToFront:viewBottomLeftContainer];
    [self.view bringSubviewToFront:viewBottomRightContainer];
}

- (void) viewDidAppear:(BOOL)animated {
    [self colorize];
    [self introAnimations];
    
    //if a new customer or merchandise was created slide the dialog onscreen
    if (![self.dealmaker validCustomerMerchandise]) {
        [self showEditCustomerDialog];
    }
    
    paneSlider = [[MBViewPaneSlider alloc] initWithView1:viewPresetPackageSlidein button1:buttonStockPackages view2:viewCustomerPackageSlideIn button2:buttonCustomerPackages];
    
    //if there are customer packages, show the first one. Else show the first user package. Else do nothing
    if ([self.dealmaker.customerPackages count] > 0) {
        [self selectPackage:[self.dealmaker.customerPackages objectAtIndex:0]];
    }
    else if ([self.dealmaker.userPackages count] > 0) {
        [self selectPackage:[self.dealmaker.userPackages objectAtIndex:0]];
        
        //there are no user packages. Hide the user package side.
        [paneSlider onlyShowView:viewPresetPackageSlidein];
    }
}


#pragma mark View Setup and Teardown
- (void) colorize {
    //Colorize the view based on the constants. Here for quick changing
    viewPackages.backgroundColor = PRIMARY_DARK;
    viewProductDetails.backgroundColor = PRIMARY_DARK;
    viewInfo.backgroundColor = PRIMARY_DARK;
    viewInfoDetails.backgroundColor = PRIMARY_DARK;
    viewBottomLeftContainer.backgroundColor = PRIMARY_LIGHT;
    viewBottomRightContainer.backgroundColor = PRIMARY_LIGHT;
    
    self.view.backgroundColor = PRIMARY_LIGHT;
    tableProducts.backgroundColor = PRIMARY_LIGHT;
    
    for(UIButton *button in buttons) {
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitleColor:HIGHLIGHT_COLOR forState:UIControlStateHighlighted];
    }
}

- (void) setInitialLabels {
    //set merchandise and customer labels
    labelDetailsMerchandiseDescription.text = [self.dealmaker.receipt.merchandise_receipt_attributes.product getSummary];

    [imageDetailsMerchandise setImage:self.dealmaker.receipt.user.image];
    [imageMerchandise setImage:self.dealmaker.receipt.user.image];
}


#pragma mark Animations
- (void) initAnimations {
    //animations init
    
    //views that end offscreen at the end of the previous transition will no longer appear here-- only init the offscreen ones if needed
    if (animator == nil) {
        animator = [[MBViewAnimator alloc] initWithDuration:ANIMATION_DURATION];
        
        //slidein details panes
        [animator initObject:viewInfoDetails inView:self.view forSlideinAnimation:VAAnimationDirectionRight];
        [animator initObject:viewProductDetails inView:self.view forSlideinAnimation:VAAnimationDirectionLeft];
        
        [animator initObject:viewEditDialog inView:self.view forSlideinAnimation:VAAnimationDirectionDown];
    }
    
    //WARNING-- Force is a hack! click through to read bug description on animator class
    [animator initObjectForce:viewInfo inView:self.view forSlideinAnimation:VAAnimationDirectionRight];
    [animator initObjectForce:viewPackages inView:self.view forSlideinAnimation:VAAnimationDirectionLeft];
    
    //side in buttons
    [animator initObjectForce:viewBottomLeftContainer inView:self.view forSlideinAnimation:VAAnimationDirectionUp];
    [animator initObjectForce:viewBottomRightContainer inView:self.view forSlideinAnimation:VAAnimationDirectionUp];
    
    //relative animations
    [animator initObjectForRelativeAnimation:tableProducts inView:self.view];
    
    tableProducts.alpha = 0.0;
}

- (void) introAnimations {
    //left and right panes
    [animator animateObjectOnscreen:viewInfo completion:nil];
    [animator animateObjectOnscreen:viewPackages completion:nil];
    
    //bottom buttons
    [animator animateObjectOnscreen:viewBottomRightContainer completion:nil];
    [animator animateObjectOnscreen:viewBottomLeftContainer completion:nil];
    
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{tableProducts.alpha = 1.0;}];
    
    currentUIState = StateNeutral;
}

- (void) outroAnimations:(void (^)())completion  {
    if (currentUIState == StateShowingNewDialog) {
//        [touchBlocker removeFromSuperview];
        [animator animateObjectOffscreen:viewEditDialog completion:nil];
    }
        
    //left and right panes
    [animator animateObjectOffscreen:viewInfo completion:nil];
    [animator animateObjectOffscreen:viewPackages completion:nil];
    
    //bottom buttons
    [animator animateObjectOffscreen:viewBottomRightContainer completion:nil];
    [animator animateObjectOffscreen:viewBottomLeftContainer completion:completion];
    
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{tableProducts.alpha = 0.0;}];
}

- (void) animateInfoPaneIn {
    //the info pane on the left side of the screen. Perform animations in two ticks
    void (^secondStep)() = ^() {
        [animator animateObjectToRelativePosition:tableProducts direction:VAAnimationDirectionRight withMargin:50 completion:nil];
        [animator animateObjectOnscreen:viewInfoDetails completion:nil];
    };
    
    //bottom buttons
    [animator animateObjectOffscreen:viewBottomRightContainer completion:nil];
    [animator animateObjectOffscreen:viewBottomLeftContainer completion:nil];
    
    //small package view
    [animator animateObjectOffscreen:viewInfo completion:nil];
    [animator animateObjectOffscreen:viewPackages completion:secondStep];
    
    currentUIState = StateShowingInfo;
}

- (void) animateInfoPaneOut {
    //dismiss the info pane, return to normal
    void (^secondStep)() = ^() {
        //bottom buttons
        [animator animateObjectOnscreen:viewBottomRightContainer completion:nil];
        [animator animateObjectOnscreen:viewBottomLeftContainer completion:nil];
        
        //small package view
        [animator animateObjectOnscreen:viewInfo completion:nil];
        [animator animateObjectOnscreen:viewPackages completion:nil];
    };
    
    [animator animateObjectToStartingPosition:tableProducts completion:nil];
    [animator animateObjectOffscreen:viewInfoDetails completion:secondStep];
    
    currentUIState = StateNeutral;
}

- (void) animateProductPaneIn {
    //the product pane on the right side of the screen. Perform animations in two ticks
    void (^secondStep)() = ^() {
        [animator animateObjectToRelativePosition:tableProducts direction:VAAnimationDirectionLeft withMargin:50 completion:nil];
        [animator animateObjectOnscreen:viewProductDetails completion:nil];
    };
    
    //bottom buttons
    [animator animateObjectOffscreen:viewBottomRightContainer completion:nil];
    [animator animateObjectOffscreen:viewBottomLeftContainer completion:nil];
    
    //small package view
    [animator animateObjectOffscreen:viewInfo completion:nil];
    [animator animateObjectOffscreen:viewPackages completion:secondStep];
    
    currentUIState = StateShowingProduct;
}

- (void) animateProductPaneOut {
    void (^secondStep)() = ^() {
        //bottom buttons
        [animator animateObjectOnscreen:viewBottomRightContainer completion:nil];
        [animator animateObjectOnscreen:viewBottomLeftContainer completion:nil];
        
        //small package view
        [animator animateObjectOnscreen:viewInfo completion:nil];
        [animator animateObjectOnscreen:viewPackages completion:nil];
    };
    
    [animator animateObjectToStartingPosition:tableProducts completion:nil];
    [animator animateObjectOffscreen:viewProductDetails completion:secondStep];
    
    currentUIState = StateNeutral;
}

- (void) animateStateShowingInfo:(bool) info {
    //called from the textfield delegate. Slide the info pane up or not

    //when called with true, the delegate wants to slide the pane up
    if (info) {
        [animator animateObjectToRelativePosition:viewInfoDetails direction:VAAnimationDirectionUp withMargin:-300 completion:nil];
        currentUIState = StateShowingInfoUp;
    }
    
    //if called with false, the delegate thinks the textfields are done and the pane should be slid down. Only do this if we are not already slid down
    else {
        if (currentUIState == StateShowingInfoUp) {
            [animator animateObjectToStartingPosition:viewInfoDetails completion:nil];
            currentUIState = StateShowingInfo;
        }
    }
}


#pragma mark Edit Customer Merchandise Dialog
- (void) showEditCustomerDialog {
    //show the dialog on the screen. This should be called first thing
    touchBlocker = [[UIView alloc] initWithFrame:self.view.frame];
    touchBlocker.backgroundColor = [UIColor blackColor];
    touchBlocker.alpha = 0.5;
    
    [self.view addSubview:touchBlocker];
    [self.view bringSubviewToFront:viewEditDialog];
    
    [animator animateObjectOnscreen:viewEditDialog completion:^() {
        currentUIState = StateShowingNewDialog;
    }];
}

- (void) dismissEditCustomerDialog {
    //check to make sure the dialog can be removed appropriately
    if (![self.dealmaker validCustomerMerchandise]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Customer must have a valid name and Merchandise must have valid name and price" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    //remove the dialog from the screen
    [animator animateObjectOffscreen:viewEditDialog completion:^() {
        currentUIState = StateShowingInfoUp;
        [touchBlocker removeFromSuperview];
    }];
}


#pragma mark Table Delegate Methods
- (void) didTouchProduct:(ProductReceipt *) product {
    //triggered from the table
    if (currentUIState == StateNeutral)
        [self animateProductPaneIn];
    
    textfieldDelegate.lastSelectedProduct = product;

    labelProductName.text = product.name;
    
    //load the details into the details table
    productDetails.details = product.product.details;

    
//    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
//    [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
//    [self setTextfield:textviewProductPrice textWithString:[numberFormatter stringFromNumber:[NSNumber numberWithFloat:product.price]]];

    [imageProductImage setImage:product.product.image];
}

- (void) didSelectProduct:(ProductReceipt *)product {
    //called from the table when a product selection occurs. Inform Rollback
    
    //Create new rollbackAction indicating a selection, add to rollback queue
    [rollback actionProductSelection:product];
}

- (void) selectProduct:(ProductReceipt *) product {
    [tableDelegate selectProduct:product];
}

- (void) selectPackage:(Package *) package {
    //assign list to a rollback
    NSArray *originalOrder = self.dealmaker.currentProductOrdering;
    NSArray *changedProducts = [self.dealmaker selectPackage:package];
    NSArray *newOrder = self.dealmaker.currentProductOrdering;
    
    [tableDelegate updateTableRowOrder:originalOrder toNewOrder:newOrder];
    [rollback actionPackageSelection:changedProducts];
}

- (void) packageMatch:(Package *) package {
    //called from dealmaker when a user's selection, rollback, or package selection matches an existing pakage
    // method receives nil if no package matches the content-- unhighlight the selected package
    bool userPack = [userPackageDelegate highlighCellForPackage:package];
    bool customerPack = [customerPackageDelegate highlighCellForPackage:package];
    
    //swich the pane slider
    if (userPack)
        [paneSlider activateView:viewPresetPackageSlidein];
    
    if (customerPack)
        [paneSlider activateView:viewCustomerPackageSlideIn];
        
    
    //change the label for discount
//    if (package != nil) {
//        [self setTextfield:textfieldPackageDiscount textWithString:[NSString stringWithFormat:@"%u", package.discount]];
//    }
//    
//    if (package == nil) {
//        [self setTextfield:textfieldPackageDiscount textWithString:@"0"];
//    }
}


#pragma mark IBActions
- (IBAction) cancel:(id)sender {
    [self outroAnimations:^(){
        [self.navigationController popViewControllerAnimated:NO];
    }];
}

- (IBAction) complete:(id)sender {
    if ([self.dealmaker validPackage]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        SigningViewController *signController = [storyboard instantiateViewControllerWithIdentifier:@"signViewController"];

        //dealmaker will take the current state of the package, generate a receipt object, and pass that object along to the signing controller for rendering, siging, and uploading
        signController.receipt = [self.dealmaker completeReceipt];
        
        [self.navigationController pushViewController:signController animated:YES];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You must select at least one product in a packge." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
    }
}

- (IBAction) walkthrough:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    TutorialViewController *tutorial = [storyboard instantiateViewControllerWithIdentifier:@"tutorial"];
    tutorial.showAll = false;
    [self.navigationController pushViewController:tutorial animated:YES];
}

- (IBAction) undo:(id)sender {
    [rollback undo];
}

- (IBAction) infoTapped:(id)sender {
    [self animateInfoPaneIn];
}

- (IBAction) infoDetailsExit:(id)sender {
    [self animateInfoPaneOut];
}

- (IBAction) productDetailsExit:(id)sender {
    //dismiss product pane, return to normal
    textfieldDelegate.lastSelectedProduct = nil;
    [self animateProductPaneOut];
}

- (IBAction) editCustomerMerchandiseDone:(id)sender {
    [textfieldDelegate endEditing];
    [self dismissEditCustomerDialog];
}

- (IBAction) editCustomerMerchandise:(id)sender {
    [self showEditCustomerDialog];
}
@end
