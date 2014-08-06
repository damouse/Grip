//
//  MBConnectionManager.m
//  Culvers
//
//  Created by Mickey Barboi on 7/23/13.
//  Copyright (c) 2013 HardinDD. All rights reserved.
//

/**
 v2.0
 
 This class will do three things
 
 - leverage RK to load objects from an API with one line and send them in the same way 
 - use AF to replace the NSURLConnection functionality of MBCM v1.0
 - miscelanious: manage MBHUD for children, cache objects if necesary, connect to Core Data to store objects, etc
 
 NOTE: DOCUMENTATION IS EXTERNAL. If your name is Mickey and you forgot this, then check Drive. If your name is 
 not Mickey and you want to see the notes, go ahead and ask mickey
 */

#import "MBConnectionManager.h"
#import <AFNetworking/AFNetworking.h>


@implementation MBConnectionManager

#pragma mark Initialization
+ (MBConnectionManager *) manager {
    // Persistent instance.
    static MBConnectionManager *conMan = nil;
    
    if (conMan != nil)
        return conMan;
    
    static dispatch_once_t safer;
    dispatch_once(&safer, ^(void)
                  {
                      conMan = [[MBConnectionManager alloc] init];
                      
                  });
    
    return conMan;
}

@end
