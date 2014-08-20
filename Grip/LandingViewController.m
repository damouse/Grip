//
//  LandingViewController.m
//  Grip
//
//  Created by Mickey Barboi on 4/1/14.
//  Copyright (c) 2014 Mickey Barboi. All rights reserved.
//

// you either black out a hero or drink long enough to see yourself become the villain

/*
 On button press, make button turn white and drop down/slide in "modal" screen.
 Actions: 
 
 Login
    Top-down Modal, Move logos to bottom of screen for duration of login. Drop the keyboard while the 
    progress HUD spins, leave the grip logo on the bottom. On sucessful login, move the grip logo to the 
    bottom and animate in the company logo.
 About
    Slide the logos down or right, slide in an about section on the right side of the screen
 Present Package
    Animate logos and side bar out, switch controllers
 Help
    Same as about
 Settings
    Same as About
 
 */

#import "LandingViewController.h"
#import "MBViewAnimator.h"
#import "UIView+Utils.h"
#import "MBConnectionManager.h"

#import "Grip-Swift.h"


@interface LandingViewController () {
    MBViewAnimator *animator;
    
    PGApiManager *apiManager;
    
    BOOL loggedIn;
    
    BOOL firstLayout;
}

@end

@implementation LandingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //default to not logged in
    loggedIn = false;
	
    animator = [[MBViewAnimator alloc] initWithDuration:ANIMATION_DURATION];
    
    apiManager = [[PGApiManager alloc] init];
    [apiManager logIn:@"test@test.com" password:@"12345678" success:^(void) {
        NSLog(@"I Fired!");
    }];
    
//    apiManager.products

}

- (void) viewWillAppear:(BOOL)animated {
    //didLayoutSubviews must run before we can init animation views, but we don't want to run the init methods again after
    firstLayout = true;
    
    [self colorize];
}


- (void) colorize {
    //Colorize the view based on the constants. Here for quick changing
    self.view.backgroundColor = PRIMARY_LIGHT;
    viewMenu.backgroundColor = PRIMARY_DARK;
    viewLogin.backgroundColor = PRIMARY_DARK;
    
    for(UIButton *button in buttons) {
        [button setTitleColor:HIGHLIGHT_COLOR forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    }
    
    textfieldEmail.backgroundColor = PRIMARY_LIGHT;
    textfieldPassword.backgroundColor = PRIMARY_LIGHT;
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
        
        [animator initObject:viewLogin inView:self.view forSlideinAnimation:VAAnimationDirectionDown];
    
        firstLayout = false;
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [self initialAnimations];
}


#pragma mark View Batch Methods
- (void) initialAnimations {
    //bring the buttons onscreen
    [animator animateObjectOnscreen:viewMenu completion:nil];
    [animator animateObjectOnscreen:imageGripLogo completion:nil];
    
    //register resizing and moving animations with animator
    [animator registerCustomAnimationForView:imageGripLogo key:@"initial login position" size:.6 x:0 y:200];
    [animator registerCustomAnimationForView:imageCompanyLogo key:@"initial login position" size:.6 x:0 y:-200];
    
    //clear the top of the screen so the dialogs have space
    [animator registerCustomAnimationForView:imageGripLogo key:@"clear top" size:.3 x:200 y:300];
    [animator registerCustomAnimationForView:imageCompanyLogo key:@"clear top" size:.3 x:-200 y:300];
}

- (void) closingAnimations {
    //animations the occur when the
    
    //move both logos offscreen
    [animator animateObjectOffscreen:imageCompanyLogo completion:nil];
    [animator animateObjectOffscreen:imageGripLogo completion:nil];
}

- (void) logosToBottom {
    //move the logos to the bottom of the screen, clearing space for the top section
    [animator animateCustomAnimationForView:imageCompanyLogo andKey:@"clear top" completion:nil];
    [animator animateCustomAnimationForView:imageGripLogo andKey:@"clear top" completion:nil];
}

- (void) showBothLogos {
    //animate second logo onto the view
    //shrink the first logo and animate it down
    [animator animateCustomAnimationForView:imageGripLogo andKey:@"initial login position" completion:nil];
    [animator animateCustomAnimationForView:imageCompanyLogo andKey:@"initial login position" completion:nil];
}

- (void) showOnlyGripLogo {
    //reset logos
    [animator animateObjectToStartingPosition:imageGripLogo completion:nil];
    [animator animateObjectOffscreen:imageCompanyLogo completion:nil];
}


#pragma mark IBActions
- (IBAction)login:(id)sender {
    [animator animateObjectOnscreen:viewLogin completion:nil];
    
    [self logosToBottom];
    //on completon, move the logos to their respective places
    //[self loginAnimations];
    
    //API testing code
//    NSData *save = [NSKeyedArchiver archivedDataWithRootObject:apiManager.user];
//    [[NSUserDefaults standardUserDefaults] setObject:save forKey:@"save"];
//    
//    save = [[NSUserDefaults standardUserDefaults] objectForKey:@"save"];
//    NSLog(@"DUMP- %@", [NSKeyedUnarchiver unarchiveObjectWithData:save]);
}

- (IBAction)viewPackages:(id)sender {

    [animator animateObjectOffscreen:viewMenu completion:^(BOOL completion){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"dealViewController"];
        [self.navigationController pushViewController:vc animated:NO];
    }];
}

- (IBAction)settings:(id)sender {
    [self logosToBottom];
}

- (IBAction)dialogLogin:(id)sender {
}

- (IBAction)dialogLoginCancel:(id)sender {
    [animator animateObjectOffscreen:viewLogin completion:nil];
    
    //bring logos back
    [self showOnlyGripLogo];
}

- (IBAction)help:(id)sender {
    
}
@end
