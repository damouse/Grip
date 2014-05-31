//
//  MCCollectionViewDelegate.h
//  Culvers
//
//  Created by Mickey Barboi on 9/27/13.
//  Copyright (c) 2013 HardinDD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCCollectionViewDelegate : NSObject

-(void) collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath;
@end
