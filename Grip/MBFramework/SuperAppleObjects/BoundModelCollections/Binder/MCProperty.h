//
//  MCProperty.h
//  Culvers
//
//  Created by Mickey Barboi on 9/9/13.
//  Copyright (c) 2013 HardinDD. All rights reserved.
//

/*
 This class represents a property on a cell object.
 
 The class keeps track of all the relevant information having to do with 
 tracking the parent object, the key paths, whatever is mapped to it, etc.
 */

#import <Foundation/Foundation.h>

@interface MCProperty : NSObject

//this is the orignal name of the keypath of the property
//UNLESS ITS A MODEL, in which case its the nested keypath ignoring the root key
@property (strong, nonatomic) NSString *keyPath;

//this is the formatted property name, with the type modifier removed
//for example: labelName becomes name, textviewMyManifesto becomes myManifesto
//when this is used for model properties, detect presence of a period and
//append that to the stripped name as appropriate
//if this is a model property, this is the root name i.e. name_font_size becomes name
@property (strong, nonatomic) NSString *strippedPropertyName;

//generally should refer to the cell class that is being mapped TO
@property (weak, nonatomic) NSObject *parentObject;

//this is the actual object that the keypath refers to.
//This is the thing that is acutally manipulated
@property (weak, nonatomic) NSObject *propertyObject;


//expects the keypath of the property and the object to which it belongs to
- (id) initWithKey:(NSString *)path fromObject:(NSObject *)cell;

@end
