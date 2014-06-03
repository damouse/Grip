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

@interface DealViewController (){
    MBViewAnimator *animator;
}

@end

@implementation DealViewController

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
    [viewPackages addDefaultBorder];
    [viewInfo addDefaultBorder];
    
    [animator initObject:viewInfo inView:self.view forSlideinAnimation:VAAnimationDirectionRight];
    [animator initObject:viewPackages inView:self.view forSlideinAnimation:VAAnimationDirectionLeft];
}

- (void) viewDidLayoutSubviews {
    //prepare holder views for animation
}

- (void) viewDidAppear:(BOOL)animated {
    [animator animateObjectOnscreen:viewInfo completion:nil];
    [animator animateObjectOnscreen:viewPackages completion:nil];
}


@end
