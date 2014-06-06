//
//  Product.h
//  Grip
//
//  Created by Mickey Barboi on 6/5/14.
//  Copyright (c) 2014 Mickey Barboi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Product : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *descripton;

@property bool selected;

@end
