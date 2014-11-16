//
//  DealTextfieldDelegate.h
//  Grip
//
//  Created by Mickey Barboi on 11/3/14.
//  Copyright (c) 2014 Mickey Barboi. All rights reserved.
//

/**
 Manages all of the textfields for the DealVC, calls back occasionally with updates
 */

#import <Foundation/Foundation.h>
#import "DealViewController.h"

@interface DealTextfieldDelegate : NSObject <UITextFieldDelegate>

@property (weak, nonatomic) DealViewController *parent;

//a container for the product that was slid in. Save in case the textfield opens and the price is changed
@property (weak, nonatomic) ProductReceipt *lastSelectedProduct;

//force all textfields to stop editing, dismiss the keyboard, and repopulate the values
- (void) endEditing;

@end
