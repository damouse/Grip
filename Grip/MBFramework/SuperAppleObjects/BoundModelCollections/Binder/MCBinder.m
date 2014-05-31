//
//  MCBinder.m
//  test
//
//  Created by Mickey Barboi on 9/2/13.
//  Copyright (c) 2013 HardinDD. All rights reserved.
//

#import "MCBinder.h"
#import "MCProperty.h"
#import <objc/runtime.h>

//interpereters-- responsible for handling bindings between specific uielements
#import "MCUIElementInterpreter.h"
#import "MCLabelInterpreter.h"
#import "MCTextFieldInterpreter.h"
#import "MCTextViewInterpreter.h"
#import "MCImageViewInterpreter.h"
#import "MCButtonInterpreter.h"

@implementation MCBinder {
    NSMutableArray *modelProperties;
}

- (void) bindPropertiesFrom:(NSObject *)model toObject:(NSObject *)cell {
    //creates an array of property wrapper objects for the cell's properties and the model.
    //currently ignores nil properties on the model (strings that have not been initialized)
    //finally, calls the actual binding method for each cell property
    
    //inform the cell a binding will occurr
    [self preCallbackFrom:model to:cell];
    
    
    //set properties to our properties
    NSArray *cellPropertyStrings = [self getPropertiesForClass:[cell class]];
    NSArray *modelPropertyStrings = [self getPropertiesForClass:[model class]];
    
    NSMutableArray *cellProperties = [NSMutableArray array];
    modelProperties = [NSMutableArray array];
    
    //create the property wrapper objects from the strings
    for(NSString *prop in cellPropertyStrings) {
        MCProperty *wrapper = [[MCProperty alloc] initWithKey:prop fromObject:cell];
        [cellProperties addObject:wrapper];
    }
    
    //create the property wrappe objects for the model's properties
    for(NSString *prop in modelPropertyStrings) {
        MCProperty *wrapper = [[MCProperty alloc] initWithKey:prop fromObject:model];
        
        //this happens if the object the property refers to is an uninitialized string
        if(wrapper != nil)
            [modelProperties addObject:wrapper];
    }
    
    //consider multithreading at this point
    for(MCProperty *property in cellProperties) {
        [self bindProperty:property];
    }
    
    
    //inform the cell a binding occured
    [self postCallbackFrom:model to:cell];
}

- (void) bindProperty:(MCProperty *)property {
    //this method actually binds fields from the model to the property by checking for matching keypaths on the model
    
    //note: the property wrapper being passed in is one created from the cell object
    //the model's properties are floating around as instance variables because multiple
    //model properties can match to one cell property
    
    //find the matching model properties for this cell property
    NSArray *model = [self getPropertiesMatchingProperty:property];
    
    //determine the type of the cell property, create the correct handler and pass it off (for each model property)
    for(MCProperty *modelProperty in model) {
        //determine type of property the cell object has and pass off both properties to a handler
        
        //this is the superclass of all the interperetrs.
        MCUIElementInterpreter *interpreter = nil;
        
        //uh oh. Uninit strings may be nil, try that...
        if([property propertyObject] == nil) {
            if([[modelProperty propertyObject] isKindOfClass:[NSString class]]) {
                //whew, had me worried. Assign the string from the model to the cell
                [[property parentObject] setValue:[modelProperty propertyObject] forKey:[property keyPath]];
                continue;
            }
            else
                NSAssert(false, @"Something has gone wrong. The reciever property is nil and the model property is not an NSString. Throwing in the towel, boss.");
        }
        
        //BRANCH: this is where the property logic happens: this chunk decides what type
        //the receiver is and passes off binding to the appropriate
        //check the type of the reciever object, assign the appropriate interpreter
        if([[property propertyObject] isKindOfClass:[UILabel class]])
            interpreter = [[MCLabelInterpreter alloc] init];
        
        if([[property propertyObject] isKindOfClass:[UITextView class]])
            interpreter = [[MCTextViewInterpreter alloc] init];
        
        if([[property propertyObject] isKindOfClass:[UITextField class]])
            interpreter = [[MCTextFieldInterpreter alloc] init];
        
        if([[property propertyObject] isKindOfClass:[UIButton class]])
            interpreter = [[MCButtonInterpreter alloc] init];
        
        if([[property propertyObject] isKindOfClass:[UIImageView class]])
            interpreter = [[MCImageViewInterpreter alloc] init];
        
        if([[property propertyObject] isKindOfClass:[NSString class]]) {
            [[property parentObject] setValue:[modelProperty propertyObject] forKey:[property keyPath]];
            continue;
        }
        
        
        //interpreter has been assigned, hand off execution to it
        NSAssert(interpreter != nil, @"The object type handler has fallen through; no interpreter was asssigned to deal with property %@", modelProperty);
        if(![interpreter bindProperty:modelProperty toProperty:property]) {
            NSLog(@"Interpreter %@ was unable to bind %@ model property to %@ cell property. Check to make sure the desired conversion has been implemented", interpreter, [modelProperty propertyObject], [property propertyObject]);
        }
        else
            MCLog(@"Bound %@ to %@", [modelProperty keyPath], [property keyPath]);
    }
}


- (void) preCallbackFrom:(NSObject *)model to:(NSObject *)cell{
    //inform model and cell before binding
    if([cell respondsToSelector:@selector(willBindModel:)])
        [cell performSelector:@selector(willBindModel:) withObject:model];
    
    if([model respondsToSelector:@selector(willBindToCell:)])
        [model performSelector:@selector(willBindToCell:) withObject:cell];
}

- (void) postCallbackFrom:(NSObject *)model to:(NSObject *)cell {
    //inform model and cell after binding
    if([cell respondsToSelector:@selector(didBindModel:)])
        [cell performSelector:@selector(didBindModel:) withObject:model];
    
    if([model respondsToSelector:@selector(didBindToCell:)])
        [model performSelector:@selector(didBindToCell:) withObject:cell];
}


#pragma mark Property Utilities
- (NSArray *) getPropertiesForClass:(id)class {
    //returns a list of the properties of the given class as an array of strings
    
    unsigned count;
    objc_property_t *properties = class_copyPropertyList([class class], &count);
    
    NSMutableArray *rv = [NSMutableArray array];
    
    unsigned i;
    for (i = 0; i < count; i++) {
        objc_property_t property = properties[i];
        NSString *name = [NSString stringWithUTF8String:property_getName(property)];
        [rv addObject:name];
    }
    
    free(properties);
    
    return rv;
}

- (NSArray *) getPropertiesMatchingProperty:(MCProperty *)property {
    //Returns array of property paths in the model object that match the passed in keypath
    //note that underscores in the model object's properties are treated as delimeters
    //signifying a key-path walk and not a key value
    
    NSMutableArray *parsed = [NSMutableArray array];
    
    //these are model property wrappers
    for(MCProperty *modelProperty in modelProperties) {

        if([[modelProperty strippedPropertyName] isEqualToString:[property strippedPropertyName]])
            [parsed addObject:modelProperty];
    }
    
    return parsed;
}


@end
