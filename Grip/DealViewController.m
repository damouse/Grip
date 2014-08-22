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

@interface DealViewController (){
    MBViewAnimator *animator;
    ProductTableViewDelegate *tableDelegate;
    
    int currentUIState;
}

typedef enum UIState{
    StateNeutral,
    StateShowingInfo,
    StateShowingProduct
} UIState;

@end

@implementation DealViewController


#pragma mark Lifecycle Methods
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    //table init
    tableDelegate = [[ProductTableViewDelegate alloc] init];
    tableDelegate.parent = self;
    tableDelegate.products = self.products;
    tableDelegate.tableView = tableProducts;
    tableProducts.delegate = tableDelegate;
    tableProducts.dataSource = tableDelegate;
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
        [button setTitleColor:HIGHLIGHT_COLOR forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    }
}

- (void) setInitialLabels {
    //set merchandise and customer labels
    labelCustomerName.text = self.customer.name;
    labelDetailsCustomerName.text = self.customer.name;
    labelMerchandiseName.text = self.merchandise.name;
    labelDetailsMerchandiseName.text = self.merchandise.name;
    labelDetailsMerchandiseDescription.text = self.merchandise.item_description;
    
    [imageDetailsMerchandise sd_setImageWithURL:[self.merchandise imageUrl]];
    [imageMerchandise sd_setImageWithURL:[self.merchandise imageUrl]];
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


#pragma mark Delegate Methods
- (void) didSelectProduct:(Product *) product {
    //triggered from the table
    if (currentUIState == StateNeutral)
        [self animateProductPaneIn];

    labelProductName.text = product.name;
    labelProductDescription.text = product.item_description;
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    labelProductPrice.text = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:product.price]];
    
    [imageProductImage sd_setImageWithURL:[product imageUrl]];
}


#pragma mark IBActions
- (IBAction)cancel:(id)sender {
    [self outroAnimations:^(BOOL completion){
        [self.navigationController popViewControllerAnimated:NO];
    }];
}

- (IBAction)complete:(id)sender {

}

- (IBAction)walkthrough:(id)sender {

}

- (IBAction)undo:(id)sender {

}

- (IBAction)infoTapped:(id)sender {
    [self animateInfoPaneIn];
}

- (IBAction)infoDetailsExit:(id)sender {
    [self animateInfoPaneOut];
}

- (IBAction)productDetailsExit:(id)sender {
    //dismiss product pane, return to normal
    [self animateProductPaneOut];
}
@end
