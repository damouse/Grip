//
//  LandingViewController.m
//  Grip
//
//  Created by Mickey Barboi on 4/1/14.
//  Copyright (c) 2014 Mickey Barboi. All rights reserved.
//

#import "LandingViewController.h"
#import "MBViewAnimator.h"
#import "UIView+Utils.h"

@interface LandingViewController () {
    MBViewAnimator *animator;
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
	
    animator = [[MBViewAnimator alloc] init];
}

- (void) viewWillAppear:(BOOL)animated {
    //add the colored border to the view. Method is in a category in the frameworks folder. 
    [viewLogos addDefaultBorder];
    [viewMenu addDefaultBorder];
}

- (void) viewDidLayoutSubviews {
    //prepare holder views for animation
    [animator initObject:viewMenu inView:self.view forSlideinAnimation:VAAnimationDirectionRight];
    [animator initObject:viewLogos inView:self.view forSlideinAnimation:VAAnimationDirectionLeft];
}

- (void) viewDidAppear:(BOOL)animated {
    [animator animateObjectOnscreen:viewMenu completion:nil];
    [animator animateObjectOnscreen:viewLogos completion:nil];
}

- (IBAction)login:(id)sender {
    [animator animateObjectOffscreen:viewMenu completion:nil];
    [animator animateObjectOffscreen:viewLogos completion:nil];
}

- (IBAction)viewPackages:(id)sender {
    [animator animateObjectOffscreen:viewMenu completion:nil];
    [animator animateObjectOffscreen:viewLogos completion:^(BOOL completion){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"dealViewController"];
        [self presentViewController:vc animated:NO completion:nil];
    }];
}

- (IBAction)DEBUGin:(id)sender {
    [animator animateObjectOnscreen:viewMenu completion:nil];
    [animator animateObjectOnscreen:viewLogos completion:nil];
}
- (IBAction)DEBUGout:(id)sender {
    [animator animateObjectOffscreen:viewMenu completion:nil];
    [animator animateObjectOffscreen:viewLogos completion:nil];
}
@end
