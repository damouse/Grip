//
//  MCLabelInterpreter.m
//  test
//
//  Created by Mickey Barboi on 9/9/13.
//  Copyright (c) 2013 HardinDD. All rights reserved.
//

#import "MCLabelInterpreter.h"


@implementation MCLabelInterpreter

- (BOOL) bindProperty:(MCProperty *) model toProperty:(MCProperty *) cell {
    //overridden binder for this uielement
    
    //if the super implementation (which covers general cases) was able to bind, move on
    if([super bindProperty:model toProperty:cell])
        return YES;
    
    UILabel *receiver = (UILabel *)[cell propertyObject];
    
    //simple, naive implementation for now while this gets off the ground... just assign string to label
    if([[model propertyObject] isKindOfClass:[NSString class]]) {
        NSString *content = (NSString *)[model propertyObject];
        [receiver setText:content];
        
        return YES;
    }
    else if([[model propertyObject] isKindOfClass:[NSNumber class]]) {
        NSNumber *content = (NSNumber *)[model propertyObject];
        [receiver setText:[NSString stringWithFormat:@"%3.2f", [content floatValue]]];
        
        return YES;
    }
    else if([[model propertyObject] isKindOfClass:[UIColor class]]) {
        UIColor *content = (UIColor *)[model propertyObject];
        
        //I don't like this. It's not dynamic and its fraught with danger
        if([[model keyPath] isEqualToString:@"textColor"]) {
            [receiver setTextColor:content];
        }
        
        
        return YES;
    }
    
    //return NO if a binding was not successfully made
    return NO;
}

@end
