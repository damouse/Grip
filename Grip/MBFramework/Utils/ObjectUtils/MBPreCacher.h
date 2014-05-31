//
//  MBPreCacher.h
//  Culvers
//
//  Created by Mickey Barboi on 9/12/13.
//  Copyright (c) 2013 HardinDD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MBPreCacher : NSObject


/**
 This class creates a plist file when used in the simulator. This file should
 be copied back into the project as a permanent store in the situation where data from
 the operation of the app needs to be submitted in with the project.
 
 For example: in Culver's the restaurant call takes 15 seconds to run and requires
 500 stores be forwards geocoded. This simple cannot be done while the app is running,
 so the data is encoded into a plist to be included with the app storing a "first call"
 to the API, essentially a precache.
 */


+ (void) createPListWithObjects:(NSArray *)data withName:(NSString *)name;

+ (NSArray *) loadPListNamed:(NSString *)name;

@end
