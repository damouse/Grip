//
//  MBPreCacher.m
//  Culvers
//
//  Created by Mickey Barboi on 9/12/13.
//  Copyright (c) 2013 HardinDD. All rights reserved.
//

#import "MBPreCacher.h"

@implementation MBPreCacher


+ (void) createPListWithObjects:(NSArray *)data withName:(NSString *)name {
    NSLog(@"PRECACHER: Saving objects");
    
    NSString *fname = [NSString stringWithFormat:@"%@.plist", name];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:fname];
    
    NSLog(@"PRECACHER: %@.plist was saved at directory: %@ \nCopy this file into the project for later use.", name, path);
    
    NSData *save = [NSKeyedArchiver archivedDataWithRootObject:data];
    [save writeToFile:path atomically:NO];
}

+ (NSArray *) loadPListNamed:(NSString *)name {
    NSLog(@"PRECACHER: loading objects");
    NSBundle* bundle = [NSBundle mainBundle];
	NSString* plistPath = [bundle pathForResource:name ofType:@"plist"];
    
    
    NSData *save = [[NSData alloc] initWithContentsOfFile:plistPath];
    NSArray *data = [NSKeyedUnarchiver unarchiveObjectWithData:save];
    
    return data;
    //NSLog(@"data post-save: %@", data);
}

@end
