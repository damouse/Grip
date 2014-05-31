//
//  MCUIElementInterpreter.m
//  test
//
//  Created by Mickey Barboi on 9/9/13.
//  Copyright (c) 2013 HardinDD. All rights reserved.
//

#import "MCUIElementInterpreter.h"
//#import "MCInterpreterHub.h"

@implementation MCUIElementInterpreter

- (BOOL) bindProperty:(MCProperty *) model toProperty:(MCProperty *) cell {
    //All Interpreters must override this method, however you can use this method to store
    // interpretations of property strings/types that are universal to all/many/most uielements
    //best example: anything having to do with a layer, background colors, opacity, etc.
    
    //Return TRUE if a binding was successfully established so the children know to skip, else false
    
    
    //this is a failed attempt to apply the existing infrastructure recursively to the problem of nested keypaths. Yeeeaaah.
    /*if (![[model keyPath] isEqualToString:@""]) {
        //we have a nested keypath; dive into the receiver object, following the keyPath until the terminal object is found
        
        NSMutableArray *paths = [NSMutableArray arrayWithArray:[[model keyPath] componentsSeparatedByString:@"."]];

        //spin through keys, reassigning the cell every time
        while([paths count] != 0) {
            cell = [[MCProperty alloc] initWithKey:[paths objectAtIndex:0] fromObject:[cell propertyObject]];
            [paths removeObjectAtIndex:0];
        }
        
        //create a new interpreter hub for what is (hopefully) the terminal level of uielement
        MCInterpreterHub *hub = [[MCInterpreterHub alloc] init];
        [hub findInterpreterAndBind:model toObject:cell];
    }*/
    

//WARNING: keypaths only one level deep are supported currently, due to a nasty issue with certain uielements beng nil (im looking at you, backgroundColor) as default
        //First, and most importantly, determine if the keypath is nested; if so chase it down and recreate the model and receiver objects
    
    //everything has a background color, no?
    if([[model keyPath] isEqualToString:@"backgroundColor"]) {
        NSAssert([[cell propertyObject] respondsToSelector:@selector(setBackgroundColor:)], @"Cell property %@ does not have a backgroundColor, but had something mapped to that. Quitting.", [cell propertyObject]);
        
        [[cell propertyObject]performSelector:@selector(setBackgroundColor:) withObject:[model propertyObject]];
        
        return YES;
    }
    
    return false;
}

@end
