//
//  DealTextfieldDelegate.m
//  Grip
//
//  Created by Mickey Barboi on 11/3/14.
//  Copyright (c) 2014 Mickey Barboi. All rights reserved.
//

/**
    Handles all the textfields owned by DealVC
 
    Connected to the VC and the dealmaker-- changes will only come from the dealmaker
 
    Validates and prettifies input
    Calls the Dealmaker when a field changes
    Gets called when the dealmaker gets updated values
    Calls the VC when an animation is needed
 */

#import "DealTextfieldDelegate.h"


@implementation DealTextfieldDelegate {
    Dealmaker *dealmaker;
}

@synthesize parent;

- (instancetype) init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
    }
    return self;
}

- (void) setParent:(DealViewController *)newParent {
    parent = newParent;
    dealmaker = parent.dealmaker;
    
    //set self up as the callback from Dealmaker
    __weak DealTextfieldDelegate *weakself = self;
    dealmaker.totalChanged = ^(Receipt *receipt) {
        [weakself updateLabelsWith:receipt];
    };
    
    //assign delegates
    parent.textfieldCustomerName.delegate = self;
    parent.textfieldCustomerEmail.delegate = self;
    parent.textfieldTerm.delegate = self;
    parent.textfieldApr.delegate = self;
    parent.textfieldMonthly.delegate = self;
    parent.textfieldPackageDiscount.delegate = self;
    
    parent.textviewProductPrice.delegate = self;
}


#pragma mark Textfields Changing
- (void) updateLabelsWith:(Receipt *) receipt {
    //called when the dealmaker makes changes and needs to update the textfields
    [self setTextfield:parent.textfieldCustomerEmail textWithString: receipt.customer.email];
    [self setTextfield:parent.textfieldCustomerName textWithString: receipt.customer.name];
    
    parent.labelCustomerName.text = receipt.customer.name;
    
    [self setTerm:receipt];
    [self setApr:receipt];
    [self setMonthly:receipt];
    [self setDiscount:receipt];
}

- (void) textfieldsChanged {
    //some of the fields changed. Take all of their values and push the updates to Dealmaker
    dealmaker.receipt.apr = [self getApr];
    dealmaker.receipt.discount = [self getDiscount];
    dealmaker.receipt.term = [self getTerm];
    dealmaker.receipt.customer.name = [self getName];
    dealmaker.receipt.customer.email = [self getEmail];
    
    if (self.lastSelectedProduct != nil) {
        self.lastSelectedProduct.price = [self getProductPrice];
    }
    
    //check for errors here and show alert
    
    [dealmaker recalculateTotals];
}


#pragma mark Textfield Input and Validation
- (double) getApr {
    return [parent.textfieldApr.text doubleValue];
}

- (double) getDiscount {
    return [parent.textfieldPackageDiscount.text doubleValue];
}

- (int) getTerm {
    return [parent.textfieldTerm.text intValue];
}

- (NSString *) getEmail {
    return parent.textfieldCustomerEmail.text;
}

- (NSString *) getName {
    return parent.textfieldCustomerName.text;
}

- (double) getProductPrice {
    return [parent.textviewProductPrice.text doubleValue];
}


#pragma mark Textfield Output Formatting
- (void) setApr:(Receipt *) receipt {
    NSString *result = [NSString stringWithFormat:@"%.3f%% Interest", receipt.apr * 100];
    
    [self setTextfield:parent.textfieldApr textWithString: result];
    parent.labelApr.text = result;
}

- (void) setDiscount:(Receipt *) receipt {
    NSString *result =[NSString stringWithFormat:@"%d%% Package Discount", receipt.discount];
    
    [self setTextfield:parent.textfieldPackageDiscount textWithString: result];
}

- (void) setMonthly:(Receipt *) receipt {
    
    NSString *result = [NSString stringWithFormat:@"%@ Monthly", [self stringFromCurrencyDouble: receipt.monthly]];
    
    [self setTextfield:parent.textfieldMonthly textWithString: result];
    parent.labelMonthlyPayment.text = result;
}

- (void) setTerm:(Receipt *) receipt {
    NSString *result = [NSString stringWithFormat:@"%d Months", receipt.term];
    
    [self setTextfield:parent.textfieldTerm textWithString: result];
    parent.labelLoanTerm.text = result;
}

- (void) setEmail:(Receipt *) receipt {
    [self setTextfield:parent.textfieldCustomerEmail textWithString:receipt.customer.email];
}


#pragma mark Utilities
- (NSString *) stringFromCurrencyDouble:(double) value {
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    return [numberFormatter stringFromNumber:[NSNumber numberWithDouble:value]];
}

- (void) setTextfield:(UITextField *) textfield textWithString: (NSString*) string {
    //utility method to add whitespace to a textfield
    textfield.text = [NSString stringWithFormat:@"  %@", string];
}


#pragma mark TextfieldDelegate Methods
- (void) textFieldDidBeginEditing:(UITextField *)sender {
    //animate the details view up to make the textfield visible when the keyboard is up
    if (sender == parent.textfieldTerm || sender == parent.textfieldApr || sender == parent.textfieldPackageDiscount) {
        [parent animateStateShowingInfo:true];
    }
}

- (BOOL) textFieldShouldReturn:(UITextField *)textView {
    //value setting- for each textfield
    [self textfieldsChanged];
    
    //end animation for textviews not normally visible to the user
    [parent animateStateShowingInfo:false];

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

- (void) keyboardWillHide:(id)sender {
    //call parent animation action
    [parent animateStateShowingInfo:false];
    [self textfieldsChanged];
    
    //remove cursor from the textfields
    for (UITextField *field in parent.textfields)
        [field endEditing:YES];
}
@end
