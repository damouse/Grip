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

#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImageView+WebCache.h"

#import "Grip-Swift.h"

@interface DealViewController (){
    MBViewAnimator *animator;
    ProductTableViewDelegate *tableDelegate;
    
    //package table delegates
    PackageTableViewDelegate *userPackageDelegate;
    PackageTableViewDelegate *customerPackageDelegate;
    
    //two-pane slider
    MBViewPaneSlider *paneSlider;
    
    Rollback *rollback;
    
    ProductReceipt *lastSelectedProductReceipt;
    
    //enumed below
    int currentUIState;
    
    //the last discount choosen not from a package
    int lastCustomDiscount;
}

typedef enum UIState{
    StateNeutral,
    StateShowingInfo,
    StateShowingProduct,
    StateShowingInfoUp
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
    
    //called when the dealmaker has determined that the monthly cost of the deal has changed
    self.dealmaker.totalChanged = ^(double newTotal) {
        [weak_self changeMonthlyPaymentTo:newTotal];
    };
    
    //register to be notified if the keyboard is dismissed
    [self listenForKeyboardHide];
}

- (void) viewWillAppear:(BOOL)animated {
    [self initAnimations];
    [self setInitialLabels];
    [self colorize];
}

- (void) viewDidAppear:(BOOL)animated {
    [self introAnimations];
    
    //DEBUG TESTING
    NSURL *url = [NSURL URLWithString:@"http://www.youtube.com/watch?v=fDXWW5vX-64"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webviewVideo loadRequest:request];
    
    paneSlider = [[MBViewPaneSlider alloc] initWithView1:viewPresetPackageSlidein button1:buttonStockPackages view2:viewCustomerPackageSlideIn button2:buttonCustomerPackages];
    
    //if there are customer packages, show the first one. Else show the first user package. Else do nothing
//    if ([self.dealmaker.customerPackages count] > 0) {
//        [self selectPackage:[self.dealmaker.customerPackages objectAtIndex:0]];
//    }
//    else if ([self.dealmaker.userPackages count] > 0) {
//        [self selectPackage:[self.dealmaker.userPackages objectAtIndex:0]];
//    }
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
    
    [labelProductDescription setTextColor:P_TEXT_COLOR];
    
    for(UIButton *button in buttons) {
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitleColor:HIGHLIGHT_COLOR forState:UIControlStateHighlighted];
    }
    
    for (UITextField *textfield in textfields) {
        textfield.backgroundColor = PRIMARY_LIGHT;
    }
}

- (void) setInitialLabels {
    //set merchandise and customer labels
    labelCustomerName.text = self.dealmaker.receipt.customer.name;
    labelMerchandiseName.text = self.dealmaker.receipt.merchandise_receipt_attributes.name;
    labelMerchandiseName.text = self.dealmaker.receipt.merchandise_receipt_attributes.name;
    labelDetailsMerchandiseDescription.text = self.dealmaker.receipt.merchandise_receipt_attributes.product.item_description;
    
    [imageDetailsMerchandise setImage:self.dealmaker.receipt.merchandise_receipt_attributes.product.image];
    [imageMerchandise setImage:self.dealmaker.receipt.merchandise_receipt_attributes.product.image];
    
    [self setTextfield:textfieldCustomerName textWithString:self.dealmaker.receipt.customer.name];
}


#pragma mark Animations
- (void) initAnimations {
    //animations init
    animator = [[MBViewAnimator alloc] initWithDuration:ANIMATION_DURATION];
    [animator initObject:viewInfo inView:self.view forSlideinAnimation:VAAnimationDirectionRight];
    [animator initObject:viewPackages inView:self.view forSlideinAnimation:VAAnimationDirectionLeft];
    
    //side in buttons
    [animator initObject:viewBottomLeftContainer inView:self.view forSlideinAnimation:VAAnimationDirectionUp];
    [animator initObject:viewBottomRightContainer inView:self.view forSlideinAnimation:VAAnimationDirectionUp];
    
    //slidein details panes
    [animator initObject:viewInfoDetails inView:self.view forSlideinAnimation:VAAnimationDirectionRight];
    [animator initObject:viewProductDetails inView:self.view forSlideinAnimation:VAAnimationDirectionLeft];
    
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

- (void) outroAnimations:(void (^)(BOOL))completion  {
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
    void (^secondStep)(BOOL) = ^(BOOL completion) {
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
    void (^secondStep)(BOOL) = ^(BOOL completion) {
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
    void (^secondStep)(BOOL) = ^(BOOL completion) {
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
    void (^secondStep)(BOOL) = ^(BOOL completion) {
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


#pragma mark Payment View
- (void) changeMonthlyPaymentTo:(double) value {
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    NSString *textValue = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:value]];
    
    labelMonthlyPayment.text = textValue;
    textfieldMonthly.text = textValue;
}


#pragma mark Table Delegate Methods
- (void) didTouchProduct:(ProductReceipt *) product {
    //triggered from the table
    if (currentUIState == StateNeutral)
        [self animateProductPaneIn];
    
    lastSelectedProductReceipt = product;

    labelProductName.text = product.name;
    labelProductDescription.text = product.product.item_description;
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    [self setTextfield:textviewProductPrice textWithString:[numberFormatter stringFromNumber:[NSNumber numberWithFloat:product.price]]];

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
    //change or set the package data
    NSLog(@"Package Match! Package: %@", package.name);
    [userPackageDelegate highlighCellForPackage:package];
}


#pragma mark IBActions
- (IBAction)cancel:(id)sender {
    [self outroAnimations:^(BOOL completion){
        [self.navigationController popViewControllerAnimated:NO];
    }];
}

- (IBAction)complete:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SigningViewController *signController = [storyboard instantiateViewControllerWithIdentifier:@"signViewController"];

    //dealmaker will take the current state of the package, generate a receipt object, and pass that object along to the signing controller for rendering, siging, and uploading
    signController.receipt = [self.dealmaker completeReceipt];
    
    [self.navigationController pushViewController:signController animated:YES];
}

- (IBAction)walkthrough:(id)sender {

}

- (IBAction)undo:(id)sender {
    [rollback undo];
}

- (IBAction)infoTapped:(id)sender {
    [self animateInfoPaneIn];
}

- (IBAction)infoDetailsExit:(id)sender {
    [self animateInfoPaneOut];
}

- (IBAction)productDetailsExit:(id)sender {
    //dismiss product pane, return to normal
    lastSelectedProductReceipt = nil;
    [self animateProductPaneOut];
}


#pragma mark Textview Delegate
- (void) textFieldDidBeginEditing:(UITextField *)sender {
    //animate the details view up to make the textfield visible when the keyboard is up
    
    //term, and loan are the two that both can be edited and can't be seen
    if (sender == textfieldTerm || sender == textfieldApr) {
        [animator animateObjectToRelativePosition:viewInfoDetails direction:VAAnimationDirectionUp withMargin:-300 completion:nil];
        currentUIState = StateShowingInfoUp;
    }
    
}

- (BOOL) textFieldShouldReturn:(UITextField *)textView {
    //value setting- for each textfield
    if (textviewProductPrice == textView) {
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
        lastSelectedProductReceipt.price  = [[numberFormatter numberFromString:textView.text] floatValue];
        
        //ask dealmaker to recalculate values
    }
    
    if (textView == textfieldTerm) {
        [self.dealmaker termChanged:[textView.text intValue]];
    }
    
    if (textView == textfieldApr) {
        [self.dealmaker aprChanged:[textfieldApr.text doubleValue]];
    }
    
    if (textView == textfieldCustomerEmail) {
        self.dealmaker.receipt.customer.email = textView.text;
    }
    
    //should this be allowed if the customer is imported from the backend?
    if (textView == textfieldCustomerName) {
        self.dealmaker.receipt.customer.name = textView.text;
    }
    
    //end animation for textviews not normally visible to the user
    if (currentUIState == StateShowingInfoUp) {
        [animator animateObjectToStartingPosition:viewInfoDetails completion:nil];
        currentUIState = StateShowingInfo;
    }
    
    [textView resignFirstResponder];
    return YES;
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *newString =[textField.text stringByReplacingCharactersInRange:range withString:string];
    
    //strip/check leading whitespace
    newString = [newString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    newString = [NSString stringWithFormat:@"  %@", newString];
    
    [textField setText:newString];
    return NO;
}

- (void) setTextfield:(UITextField *) textfield textWithString: (NSString*) string {
    //utility method to add whitespace to a textfield
    textfield.text = [NSString stringWithFormat:@"  %@", string];
}

- (void) listenForKeyboardHide {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void) keyboardWillHide:(id)sender {
    if (currentUIState == StateShowingInfoUp) {
        [animator animateObjectToStartingPosition:viewInfoDetails completion:nil];
        currentUIState = StateShowingInfo;
    }
    
    //remove cursor from the textfields
    for (UITextField *field in textfields)
         [field endEditing:YES];
}
@end
