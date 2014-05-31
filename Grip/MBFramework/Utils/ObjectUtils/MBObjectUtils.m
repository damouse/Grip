//
//  MBObjectUtils.m
//  Culvers
//
//  Created by Mickey Barboi on 8/2/13.
//  Copyright (c) 2013 HardinDD. All rights reserved.
//

#import "MBObjectUtils.h"

@implementation MBObjectUtils

- (void) getObjectProperties:(id)object {
    //get all of the object properties of the passed in object
    unsigned int outCount, i;
    
    objc_property_t *properties = class_copyPropertyList([object class], &outCount);
    for(i = 0; i < outCount; i++) {
    	objc_property_t property = properties[i];
    	const char *propName = property_getName(property);
    	
        if(propName) {
    		const char *propType = getPropertyType(property);
    		NSString *propertyName = [NSString stringWithUTF8String:propName];
    		NSString *propertyType = [NSString stringWithUTF8String:propType];
            
            DLog(@"name: %@ type %@", propertyName, propertyType);
    	}
    }
}

- (void) getObjectMethods:(id)object {
    //get all of the methods of an object
}

#pragma mark Misc, util
static const char *getPropertyType(objc_property_t property) {
    const char *attributes = property_getAttributes(property);
    char buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);
    char *state = buffer, *attribute;
    while ((attribute = strsep(&state, ",")) != NULL) {
        if (attribute[0] == 'T') {
            return (const char *)[[NSData dataWithBytes:(attribute + 3) length:strlen(attribute) - 4] bytes];
        }
    }
    return "@";
}
@end
