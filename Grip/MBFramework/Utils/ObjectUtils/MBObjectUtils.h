//
//  MBObjectUtils.h
//  Culvers
//
//  Created by Mickey Barboi on 8/2/13.
//  Copyright (c) 2013 HardinDD. All rights reserved.
//

/*
 This class will provide a set of helper functions that automate common busywork that needs to be done with classes. 
 MBBoilerplateUtils is a similar class in that it provides helped functions to deal with objects; the difference is that this 
 class deals with general helpers for classes that are made for projects, where Boilerplate provides helper functions for Apple's 
 stock objects.
 
 Features
 - AutoCoder- automaticaly implement and add NSCoding protocol to a given object at runtime
 - LogHelper- help track the variables and changes in the variables of an object. Tracks children if they implement the protocol
 - PropertyMirror- helps objects exchange information. For example, if People objects have Bike objects, and bikes have property 
 information that mirrors that of their parents, this removes the need to have to manually set them. 
 - FrameManipulator- provides helper functions to make playing with frames a lot easier
 */
#import <Foundation/Foundation.h>

@interface MBObjectUtils : NSObject

- (void) getObjectProperties:(id)object;
@end
