//
//  PGApiManager.h
//  Grip
//
//  Created by Mickey Barboi on 8/6/14.
//  Copyright (c) 2014 Mickey Barboi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PGApiManager : NSObject

+ (PGApiManager *) manager;

- (void) login;
@end
