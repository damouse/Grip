//
//  MCCollectionView.m
//  test
//
//  Created by Mickey Barboi on 9/2/13.
//  Copyright (c) 2013 HardinDD. All rights reserved.
//

#import "MCCollectionView.h"
#import "MCBinder.h"

@implementation MCCollectionView {
    MCBinder *binder;
}

@synthesize cellClass, data, selectHandler, cellForRowHandler, reuseIdentifier;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


#pragma mark Setup
- (void) initCollection {
    if(binder == nil)
        binder = [[MCBinder alloc] init];
    
    NSAssert(reuseIdentifier != nil && cellClass != nil, @"Reuse Identifier or Cell Class were not assigned prior to setting the data. Setting the data reloads the collection, please set the properties before calling");

    [self setDataSource:self];
    [self setDelegate:self];
    [self reloadData];
}

#pragma mark Collection Data Delegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    //NSInteger c = _columns;
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [data count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    NSObject *model = [data objectAtIndex:indexPath.row];
    
    [binder bindPropertiesFrom:model toObject:cell];
    
    if(cellForRowHandler) cellForRowHandler(model, cell, indexPath);
    
    return cell;
    
}

-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //remember: only 1 dimensional right now!
    DLog(@"didselect");
    //return;
    
    if(selectHandler != nil)
        selectHandler([data objectAtIndex:indexPath.row], [collectionView cellForItemAtIndexPath:indexPath]);
    
        [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

/*- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
 return CGSizeMake(self.frame.size.width, self.frame.size.height);
 }*/


#pragma mark Overridden Synthesis
- (void) setData:(NSArray *)dataNew {
    //trigger the collection view to load and display when the data is set
    data = dataNew;
    
    [self initCollection];
}
@end
