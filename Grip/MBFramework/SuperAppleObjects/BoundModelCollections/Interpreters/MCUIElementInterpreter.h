//
//  MCUIElementInterpreter.h
//  test
//
//  Created by Mickey Barboi on 9/9/13.
//  Copyright (c) 2013 HardinDD. All rights reserved.
//

//superclass just for the sake of import

#import <Foundation/Foundation.h>
#import "MCProperty.h"

@interface MCUIElementInterpreter : NSObject

- (BOOL) bindProperty:(MCProperty *) model toProperty:(MCProperty *) cell;

@end
