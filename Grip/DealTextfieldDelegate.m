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
    
    //Flavor text, added to each textfield when presented
    NSString *flavorApr;
    NSString *flavorPayment;
    NSString *flavorTerm;
    NSString *flavorDiscount;
    NSString *flavorDown;
}

@synthesize parent;

- (instancetype) init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
        flavorApr = @" Interest";
        flavorPayment = @" Monthly";
        flavorTerm = @" Months";
        flavorDiscount = @" Package Discount";
        flavorDown = @" Down Payment";
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
    parent.textfieldMerchandiseName.delegate = self;
    parent.textfieldMerchandisePrice.delegate = self;
    parent.textfieldTerm.delegate = self;
    parent.textfieldApr.delegate = self;
    parent.textfieldMonthly.delegate = self;
    parent.textfieldPackageDiscount.delegate = self;
    parent.textfieldDownPayment.delegate = self;
    
    parent.textviewProductPrice.delegate = self;
    
    
    //disable customer textfield if the customer is loaded from the backend: i.e. not created
    if (dealmaker.receipt.customer.id != -1) {
        [parent.textfieldCustomerName setUserInteractionEnabled:false];
        [parent.textfieldCustomerEmail setUserInteractionEnabled:false];
    }
    else {
        [parent.textfieldCustomerName setUserInteractionEnabled:true];
        [parent.textfieldCustomerEmail setUserInteractionEnabled:true];
    }
    
    //disable merchandise textfields if the merchandise already exists
    if (dealmaker.receipt.merchandise_receipt_attributes.base_item_id != -1) {
        [parent.textfieldMerchandiseName setUserInteractionEnabled:false];
    }
    else {
        [parent.textfieldMerchandiseName setUserInteractionEnabled:true];
    }
}


#pragma mark Textfields Changing
- (void) updateLabelsWith:(Receipt *) receipt {
    //called when the dealmaker makes changes and needs to update the textfields
    
    [self setTextfield:parent.textfieldCustomerName textWithString: receipt.customer.name];
    
    parent.labelCustomerName.text = receipt.customer.name;
    
    [self setTerm:receipt];
    [self setApr:receipt];
    [self setMonthly:receipt];
    [self setDiscount:receipt];
    
    [self setEmail:receipt];
    [self setName:receipt];
    
    [self setMerchandiseName:receipt];
    [self setMerchandisePrice:receipt];
    [self setDownPayment:receipt];
    
    if (self.lastSelectedProduct != nil) {
        [self setProduct];
    }
}

- (void) textfieldsChanged {
    //note: the methods produce their own alert errors
    if (!([self validApr] && [self validDiscount] & [self validTerm] && [self validProductPrice] && [self validDownPayment] &&
          [self validCustomerEmail] && [self validCustomerName] && [self validMerchandiseName] && [self validMerchandisePrice])) {
        return;
    }
    
    //some of the fields changed. Take all of their values and push the updates to Dealmaker
    dealmaker.receipt.apr = [self getApr];
    dealmaker.receipt.discount = [self getDiscount];
    dealmaker.receipt.term = [self getTerm];
    dealmaker.receipt.customer.name = [self getName];
    dealmaker.receipt.customer.email = [self getEmail];
    
    dealmaker.receipt.merchandise_receipt_attributes.name = [self getMerchandiseName];
    dealmaker.receipt.merchandise_receipt_attributes.price = [self getMerchandisePrice];
    dealmaker.receipt.customer.name = [self getCustomerName];
    dealmaker.receipt.customer.email = [self getCustomerEmail];
    
    dealmaker.receipt.down_payment = [self getDownPayment];
    
    //change the product's price and set the textfield
    if (self.lastSelectedProduct != nil) {
        self.lastSelectedProduct.price = [self getProductPrice];
    }
    
    [dealmaker recalculateTotals];
}

- (void) setLastSelectedProduct:(ProductReceipt *)lastSelectedProduct {
    _lastSelectedProduct = lastSelectedProduct;
    NSString *val = [self stringFromCurrencyDouble:lastSelectedProduct.price];
    [self setTextfield:parent.textviewProductPrice textWithString:val];
}


#pragma mark External Interface
- (void) endEditing {
    [self keyboardWillHide:nil];
}


#pragma mark Textfield Input
- (double) getApr {
    NSString *cleaned = [self removeFlavorApr];
    double result = [cleaned doubleValue] / 100;
    return result;
}

- (double) getDiscount {
    NSString *cleaned = [self removeFlavorDiscount];
    double result = [cleaned doubleValue];
    return result;
}

- (int) getTerm {
    NSString *cleaned = [self removeFlavorTerm];
    double result = [cleaned intValue];
    return result;
}

- (NSString *) getEmail {
    return [parent.textfieldCustomerEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (NSString *) getName {
    return [parent.textfieldCustomerName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (double) getProductPrice {
    NSString *str = parent.textviewProductPrice.text;
    if ([str containsString:@"$"])
        return [self currencyFromString:parent.textviewProductPrice.text];
    else
        return  [parent.textviewProductPrice.text doubleValue];
}

- (NSString *) getCustomerName {
    return [parent.textfieldCustomerName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (NSString *) getCustomerEmail {
    return [parent.textfieldCustomerEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (NSString *) getMerchandiseName {
    return [parent.textfieldMerchandiseName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (double) getMerchandisePrice {
    NSString *str = parent.textfieldMerchandisePrice.text;
    if ([str containsString:@"$"])
        return [self currencyFromString:parent.textfieldMerchandisePrice.text];
    else
        return  [parent.textfieldMerchandisePrice.text doubleValue];
}

- (double) getDownPayment {
    NSString *str = parent.textfieldDownPayment.text;
    
    if ([str containsString:flavorDown])
        str = [self removeFlavorDownPayment];
    

    if ([str containsString:@"$"])
        return [self currencyFromString:str];
    else
        return  [str doubleValue];
}


#pragma mark Textfield Validation
- (BOOL) validApr {
    double apr = [self getApr];
    
//    let scan = NSScanner(string: str)
//    scan.scanDouble(&ret)
//    println(ret)
    
    if (apr < 0 || apr > 1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Invalid iterest value" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        
        [self updateLabelsWith:dealmaker.receipt];
        return false;
    }
    
    return true;
}

- (BOOL) validDiscount {
    double discount = [self getDiscount];
    
    //    let scan = NSScanner(string: str)
    //    scan.scanDouble(&ret)
    //    println(ret)
    
    if (discount < 0 || discount > 100) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Invalid discount value" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        
        [self updateLabelsWith:dealmaker.receipt];
        return false;
    }
    
    return true;
}

- (BOOL) validTerm {
    double term = [self getTerm];
    
    //    let scan = NSScanner(string: str)
    //    scan.scanDouble(&ret)
    //    println(ret)
    
    if (term < 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Invalid term value" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        
        [self updateLabelsWith:dealmaker.receipt];
        return false;
    }
    
    return true;
}

- (BOOL) validProductPrice {
    double price = [self getProductPrice];
    
    if (price < 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Invalid product price" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        
        self.lastSelectedProduct = self.lastSelectedProduct;
        return false;
    }
    
    return true;
}

- (BOOL) validCustomerName {
    NSString *str = [self getCustomerName];
    
    if (str.length <= 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Invalid customer name" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        
        return false;
    }
    
    return true;
}

- (BOOL) validCustomerEmail {
    NSString *str = [self getCustomerEmail];

    if ([str isEqualToString:@""] || [self NSStringIsValidEmail:str])
        return true;
        
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Invalid customer email" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alert show];
        
        return false;
}

- (BOOL) validMerchandiseName {
    NSString *str = [self getMerchandiseName];
    
    if (str.length <= 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Invalid merchandise name" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        
        return false;
    }
    
    return true;
}

- (BOOL) validMerchandisePrice {
    double price = [self getMerchandisePrice];
    
    if (price < 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Invalid merchandise price" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        
        return false;
    }
    
    return true;
}

- (BOOL) validDownPayment {
    double price = [self getDownPayment];
    
    if (price < 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Invalid down payment value" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        
        return false;
    }
    
    return true;
}


#pragma mark Textfield Flavor Stripping
- (NSString *) removeFlavorApr {
    NSString *temp = [parent.textfieldApr.text stringByReplacingOccurrencesOfString:flavorApr withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"%" withString:@""];
    return temp;
}

- (NSString *) removeFlavorDiscount {
    NSString *temp = [parent.textfieldPackageDiscount.text stringByReplacingOccurrencesOfString:flavorDiscount withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"%" withString:@""];
    return temp;
}

- (NSString *) removeFlavorTerm {
    return [parent.textfieldTerm.text stringByReplacingOccurrencesOfString:flavorTerm withString:@""];
}

- (NSString *) removeFlavorProductPrice {
    return [NSString stringWithFormat:@"%.2f", [self currencyFromString:parent.textviewProductPrice.text]];
}

- (NSString *) removeFlavorMerchandisePrice {
    return [NSString stringWithFormat:@"%.2f", [self currencyFromString:parent.textfieldMerchandisePrice.text]];
}

- (NSString *) removeFlavorDownPayment {
    NSString *temp = [parent.textfieldDownPayment.text stringByReplacingOccurrencesOfString:flavorDown withString:@""];
    temp =  [NSString stringWithFormat:@"%.2f", [self currencyFromString:temp]];
    return temp;
}


#pragma mark Textfield Output Formatting
- (void) setApr:(Receipt *) receipt {
    NSString *result = [NSString stringWithFormat:@"%.3f%%%@", receipt.apr * 100, flavorApr];
    
    [self setTextfield:parent.textfieldApr textWithString: result];
    parent.labelApr.text = result;
}

- (void) setDiscount:(Receipt *) receipt {
    NSString *result =[NSString stringWithFormat:@"%d%%%@", receipt.discount, flavorDiscount];
    
    [self setTextfield:parent.textfieldPackageDiscount textWithString: result];
}

- (void) setMonthly:(Receipt *) receipt {
    
    NSString *result = [NSString stringWithFormat:@"%@%@", [self stringFromCurrencyDouble: receipt.monthly], flavorPayment];
    
    [self setTextfield:parent.textfieldMonthly textWithString: result];
    parent.labelMonthlyPayment.text = result;
}

- (void) setTerm:(Receipt *) receipt {
    NSString *result = [NSString stringWithFormat:@"%d%@", receipt.term, flavorTerm];
    
    [self setTextfield:parent.textfieldTerm textWithString: result];
    parent.labelLoanTerm.text = result;
}

- (void) setEmail:(Receipt *) receipt {
    NSString *str = receipt.customer.email;
    if (str != nil) {
        [self setTextfield:parent.textfieldCustomerEmail textWithString:str];
        [parent.labelCustomerEmail setText:str];
    }
    else {
        parent.textfieldCustomerEmail.text = @"";
        parent.labelCustomerEmail.text = @"";
    }
}

- (void) setName:(Receipt *) receipt {
    NSString *str = receipt.customer.name;
    if (str != nil) {
        [self setTextfield:parent.textfieldCustomerName textWithString:str];
        [parent.labelCustomerName setText:str];
    }
    else {
        parent.textfieldCustomerName.text = @"";
        parent.labelCustomerName.text = @"";
    }
}

- (void) setProduct {
    NSString *val = [self stringFromCurrencyDouble:self.lastSelectedProduct.price];
    [self setTextfield:parent.textviewProductPrice textWithString:val];
}

- (void) setMerchandiseName:(Receipt *) receipt {
    NSString *str = receipt.merchandise_receipt_attributes.name;
    
    if (str != nil) {
        [self setTextfield:parent.textfieldMerchandiseName textWithString:str];
        [parent.labelDetailsMerchandiseName setText:str];
        [parent.labelMerchandiseName setText:str];
    }
    else {
        parent.textfieldMerchandiseName.text = @"";
        parent.labelDetailsMerchandiseName.text = @"";
        parent.labelMerchandiseName.text = @"";
    }
    
}

- (void) setMerchandisePrice:(Receipt *) receipt {
    NSString *val = [self stringFromCurrencyDouble:receipt.merchandise_receipt_attributes.price];
    [self setTextfield:parent.textfieldMerchandisePrice textWithString:val];
    parent.labelMerchandisePrice.text = val;
}

- (void) setDownPayment:(Receipt *) receipt {
    NSString *result = [NSString stringWithFormat:@"%@%@", [self stringFromCurrencyDouble: receipt.down_payment], flavorDown];

    [self setTextfield:parent.textfieldDownPayment textWithString:result];
}


#pragma mark Utilities
- (NSString *) stringFromCurrencyDouble:(double) value {
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    [numberFormatter setRoundingMode:NSNumberFormatterRoundUp];
    NSNumber *temp = [NSNumber numberWithDouble:value];
    return [numberFormatter stringFromNumber:temp];
}

- (double) currencyFromString:(NSString *) string {
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    [numberFormatter setRoundingMode:NSNumberFormatterRoundUp];
    return [[numberFormatter numberFromString:string] doubleValue];
}

- (void) setTextfield:(UITextField *) textfield textWithString: (NSString*) string {
    //utility method to add whitespace to a textfield
    textfield.text = [NSString stringWithFormat:@"%@", string];
}

-(BOOL) NSStringIsValidEmail:(NSString *)checkString {
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}


#pragma mark TextfieldDelegate Methods
- (void) textFieldDidBeginEditing:(UITextField *)sender {
    //animate the details view up to make the textfield visible when the keyboard is up
    if (sender == parent.textfieldTerm || sender == parent.textfieldApr || sender == parent.textfieldPackageDiscount) {
        [parent animateStateShowingInfo:true];
    }
    
    //find the appropriate textview and change the data from "flavored" to normal
    if (sender == parent.textfieldApr)
        parent.textfieldApr.text = [self removeFlavorApr];
    
    if (sender == parent.textfieldTerm)
        parent.textfieldTerm.text = [self removeFlavorTerm];
    
    if (sender == parent.textfieldPackageDiscount)
        parent.textfieldPackageDiscount.text = [self removeFlavorDiscount];
    
    if (sender == parent.textviewProductPrice)
        parent.textviewProductPrice.text = [self removeFlavorProductPrice];
    
    if (sender == parent.textfieldMerchandisePrice)
        parent.textfieldMerchandisePrice.text = [self removeFlavorMerchandisePrice];
    
    if (sender == parent.textfieldDownPayment)
        parent.textfieldDownPayment.text = [self removeFlavorDownPayment];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textView {
    [textView resignFirstResponder];
    return YES;
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
