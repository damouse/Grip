//
//  NSString+Contains.m
//  Culvers
//
//  Created by Mickey Barboi on 9/21/13.
//  Copyright (c) 2013 HardinDD. All rights reserved.
//

#import "NSString+Utils.h"

@implementation NSString (Utils)

- (BOOL) contains:(NSString *)string {
    //sick and tired of the STUPID way apple has to check contains for string. Have
    //yourself a wrapper.
    if ([self rangeOfString:string].location == NSNotFound)
        return NO;
    return YES;
}

@end
