//
//  MCCollectionViewDelegate.m
//  Culvers
//
//  Created by Mickey Barboi on 9/27/13.
//  Copyright (c) 2013 HardinDD. All rights reserved.
//

#import "MCCollectionViewDelegate.h"

@implementation MCCollectionViewDelegate

-(void) collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //remember: only 1 dimensional right now!
    DLog(@"didselect");
    //return;
    
    //if(selectHandler != nil)
    //    selectHandler([data objectAtIndex:indexPath.row], [collectionView cellForItemAtIndexPath:indexPath]);
    
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

@end
