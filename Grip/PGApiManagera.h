//
//  PGApiManager.h
//  Grip
//
//  Created by Mickey Barboi on 8/6/14.
//  Copyright (c) 2014 Mickey Barboi. All rights reserved.
//

/**
 Wraps the api calls needed to set up the local cache for modal upates. 
 
 A login or regfresh call will trigger a full reload, completely wiping the cache of saved objects. 
 
 If the login fails due to an auth error, this class automatically retries. 
 
 Puts a spinner on the screen for the controller that's running the API calls. 
 
 */

#import <Foundation/Foundation.h>

@interface PGApiManager : NSObject

+ (PGApiManager *) manager;

- (void) login;

- (void) completeDeal;
@end
