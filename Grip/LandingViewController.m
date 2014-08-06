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
#import "MBConnectionManager.h"

#import "Grip-Swift.h"



@interface LandingViewController () {
    MBViewAnimator *animator;
    
    PGApiManager *apiManager;
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
	
    animator = [[MBViewAnimator alloc] initWithDuration:ANIMATION_DURATION];
    
    apiManager = [[PGApiManager alloc] init];
    [apiManager auth];
}

- (void) viewWillAppear:(BOOL)animated {   
    [self colorize];
}


- (void) colorize {
    //Colorize the view based on the constants. Here for quick changing
    self.view.backgroundColor = PRIMARY_LIGHT;
    viewMenu.backgroundColor = PRIMARY_DARK;
    viewLogos.backgroundColor = PRIMARY_DARK;
    
    for(UIButton *button in buttons) {
        [button setTitleColor:HIGHLIGHT_COLOR forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    }
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
    NSData *save = [NSKeyedArchiver archivedDataWithRootObject:apiManager.user];
    [[NSUserDefaults standardUserDefaults] setObject:save forKey:@"save"];
    
    save = [[NSUserDefaults standardUserDefaults] objectForKey:@"save"];
    NSLog(@"DUMP- %@", [NSKeyedUnarchiver unarchiveObjectWithData:save]);
}

- (IBAction)viewPackages:(id)sender {
    [animator animateObjectOffscreen:viewMenu completion:nil];
    [animator animateObjectOffscreen:viewLogos completion:^(BOOL completion){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"dealViewController"];
        [self.navigationController pushViewController:vc animated:NO];
    }];
}
@end
