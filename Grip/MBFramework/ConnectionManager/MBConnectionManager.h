//
//  MBConnectionManager.h
//  Culvers
//
//  Created by Mickey Barboi on 7/23/13.
//  Copyright (c) 2013 HardinDD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit.h>

@interface MBConnectionManager : NSObject

//Singleton call
+ (MBConnectionManager *) manager;

- (void) apiRequestWithMapping:(RKObjectMapping *)mapping atURL:(NSString *)url withKeyPath:(NSString *)path success:(void (^)(RKMappingResult *))success fail:(void (^)(NSError *))failure;
@end
