//
//  MCImageViewInterpreter.m
//  test
//
//  Created by Mickey Barboi on 9/9/13.
//  Copyright (c) 2013 HardinDD. All rights reserved.
//

#import "MCImageViewInterpreter.h"

@implementation MCImageViewInterpreter



- (BOOL) bindProperty:(MCProperty *) model toProperty:(MCProperty *) cell {
    //overridden binder for this uielement
    
    //if the super implementation (which covers general cases) was able to bind, move on
    if([super bindProperty:model toProperty:cell])
        return YES;
    
    UIImageView *receiver = (UIImageView *)[cell propertyObject];
    
    //simple, naive implementation for now while this gets off the ground... just assign string to label
    if([[model propertyObject] isKindOfClass:[NSString class]]) {
        NSString *image = (NSString *)[model propertyObject];
        [receiver setImage:[UIImage imageNamed:image]];
        
        return YES;
    }
    //simple, naive implementation for now while this gets off the ground... just assign string to label
    else if([[model propertyObject] isKindOfClass:[UIImage class]]) {
        UIImage *image = (UIImage *)[model propertyObject];
        [receiver setImage:image];
        
        return YES;
    }
    
    //return NO if a binding was not successfully made
    return NO;
}

@end
