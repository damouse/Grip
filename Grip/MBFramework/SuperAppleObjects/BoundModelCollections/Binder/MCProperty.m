//
//  MCProperty.m
//  Culvers
//
//  Created by Mickey Barboi on 9/9/13.
//  Copyright (c) 2013 HardinDD. All rights reserved.
//

#import "MCProperty.h"

@implementation MCProperty
@synthesize keyPath, parentObject, propertyObject, strippedPropertyName;

- (id) initWithKey:(NSString *)path fromObject:(NSObject *)object {
    //WILL RETURN NIL IF MODEL PROPERTY OBJECT IS NIL (happens with uninitialized strings)
    
    self = [super init];
    
    //assign all fields
    keyPath = path;
    parentObject = object;
    
    if([object respondsToSelector:NSSelectorFromString(path)])
        propertyObject = [object valueForKey:path];
    else
        return nil;

    
    //depending on if this is a model object or a cell object
    if([object isKindOfClass:[UITableViewCell class]] || [object isKindOfClass:[UICollectionViewCell class]]) {
        strippedPropertyName = [self parseCellProperty:path];

    }
    else {
        //model property, send to the other parser
        keyPath = [self convertUnderScoreToKeyPath:path];
        strippedPropertyName = [self parseModelProperty:path];
        
        if(propertyObject == nil)
            return nil;
    }
    
    //Oh, shit. Strings that aren't assigned will return nil when valueForKey is called
    //on the class with a valid key. So... try to fallthrough and assume nil objects are strings?
    //in reality (that is: working with a xib) this shouldn't happen.
    return self;
}


#pragma mark String Utils
- (NSString *) parseCellProperty:(NSString *)property {
    //given a key value on this class, remove the type formatting at the front
    NSString *ret = nil;
    
    //split an NSString into an array of words based on camelcase
    NSCharacterSet* lower = [NSCharacterSet lowercaseLetterCharacterSet];
    NSCharacterSet* upper = [NSCharacterSet uppercaseLetterCharacterSet];
    
    //find where the camelcase happens. Cut off the descriptive label, return the rest properly camelcased
    for (int i = 0; i < property.length; i++) {
        if (([upper characterIsMember:[property characterAtIndex:i]] && [lower characterIsMember:[property characterAtIndex:i-1]])) {
            ret = [property substringWithRange:NSMakeRange(i, property.length - i)];

            ret = [self lowercaseFirstCharacter:ret];

            break;
        }
    }

    //NSLog(@"Property parser looking for property named %@", ret);
    
    return ret;
}

- (NSString *) lowercaseFirstCharacter:(NSString *)str {
    NSString *firstCapChar = [[str substringToIndex:1] lowercaseString];
    NSString *ret = [str stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:firstCapChar];
    
    return ret;
}

- (NSString *) parseModelProperty:(NSString *)property {
    //remove the dot notation if present, return just the root key
    //if there is no nested path, return the property unchanged
    if ([property rangeOfString:@"_"].location == NSNotFound)
        return property;
    
    NSArray *split = [property componentsSeparatedByString:@"_"];
    
    return [split objectAtIndex:0];
}

- (NSString *) convertUnderScoreToKeyPath:(NSString *) property {
    //convert a nested keypath with underscores into one with periods
    //if there is no nested path, return the property unchanged
    if ([property rangeOfString:@"_"].location == NSNotFound)
        return property;
    
    NSArray *split = [property componentsSeparatedByString:@"_"];
    
    //we want to ignore the first (root) key
    BOOL ignoreFirst = TRUE;
    NSString *ret = @"";
    
    for(NSString *str in split) {
        
        //deal with the first period
        if([ret isEqualToString:@""]) {
            if(ignoreFirst)
                ignoreFirst = NO;
            else
                ret = [NSString stringWithFormat:@"%@", [self lowercaseFirstCharacter:str]];
        }
        else
            ret = [NSString stringWithFormat:@"%@.%@", ret, [self lowercaseFirstCharacter:str]];
    }
    
    return ret;
}
@end
