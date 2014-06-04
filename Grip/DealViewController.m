//
//  DealViewController.m
//  Grip
//
//  Created by Mickey Barboi on 4/1/14.
//  Copyright (c) 2014 Mickey Barboi. All rights reserved.
//

#import "DealViewController.h"
#import "MBViewAnimator.h"
#import "UIView+Utils.h"
#import "ProductTableViewDelegate.h"

@interface DealViewController (){
    MBViewAnimator *animator;
    
    ProductTableViewDelegate *tableDelegate;
}

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
    tableProducts.delegate = tableDelegate;
    tableProducts.dataSource = tableDelegate;
}

- (void) viewWillAppear:(BOOL)animated {
    //minor init on views: add a border
    [viewPackages addDefaultBorder];
    [viewInfo addDefaultBorder];
    
    [self initAnimations];
}

- (void) viewDidAppear:(BOOL)animated {
    [self introAnimations];
}


#pragma mark Animations
- (void) initAnimations {
    //animations init
    animator = [[MBViewAnimator alloc] init];
    [animator initObject:viewInfo inView:self.view forSlideinAnimation:VAAnimationDirectionRight];
    [animator initObject:viewPackages inView:self.view forSlideinAnimation:VAAnimationDirectionLeft];
    
    //side in buttons
    [animator initObject:viewBottomLeftContainer inView:self.view forSlideinAnimation:VAAnimationDirectionUp];
    [animator initObject:viewBottomRightContainer inView:self.view forSlideinAnimation:VAAnimationDirectionUp];
}

- (void) introAnimations {
    //left and right panes
    [animator animateObjectOnscreen:viewInfo completion:nil];
    [animator animateObjectOnscreen:viewPackages completion:nil];
    
    //bottom buttons
    [animator animateObjectOnscreen:viewBottomRightContainer completion:nil];
    [animator animateObjectOnscreen:viewBottomLeftContainer completion:nil];
}

- (void) outroAnimations:(void (^)(BOOL))completion  {
    //left and right panes
    [animator animateObjectOffscreen:viewInfo completion:nil];
    [animator animateObjectOffscreen:viewPackages completion:nil];
    
    //bottom buttons
    [animator animateObjectOffscreen:viewBottomRightContainer completion:nil];
    [animator animateObjectOffscreen:viewBottomLeftContainer completion:completion];
}


#pragma mark IBActions
- (IBAction)cancel:(id)sender {
    [self outroAnimations:^(BOOL completion){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"dealViewController"];
        [self presentViewController:vc animated:NO completion:nil];
    }];
}

- (IBAction)complete:(id)sender {
    
}

- (IBAction)walkthrough:(id)sender {
    
}

- (IBAction)undo:(id)sender {
    
}
@end
