//
//  ProductTableViewDelegate.m
//  Grip
//
//  Created by Mickey Barboi on 6/4/14.
//  Copyright (c) 2014 Mickey Barboi. All rights reserved.
//

#import "ProductTableViewDelegate.h"
#import "ProductTableViewCell.h"

#import "UIView+Utils.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImageView+WebCache.h"

#define MAX_DISPLACEMENT 70

@implementation ProductTableViewDelegate

- (id) init {
    self = [super init];
    
    return self;
}

#pragma mark Data and Delegate
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource numberOfProducts];
}

/*- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 103;
}*/

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"cell";
    ProductTableViewCell *cell = (ProductTableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    cell.delegate = self;
    cell.maxDisplacement = MAX_DISPLACEMENT;
    
    [cell.textviewDetails setTextColor:P_TEXT_COLOR];
    
    ProductReceipt *product = [self.dataSource productForIndex:indexPath.row];
    
    if (cell == nil)
        cell = [[ProductTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    
    //fill content
    [cell.textviewDetails setText:product.product.item_description];
    [cell.labelTitle setText:product.name];
    
    //indicate the cell is either active or not
    [self setupProductCell:cell withProduct:product];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ProductReceipt *product = [self.dataSource productForIndex:indexPath.row];
    [self.parent didTouchProduct:product];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark Cell Status
- (void) setupProductCell:(ProductReceipt *) product {
    int index = [self.dataSource.currentProductOrdering indexOfObject:product];
    ProductTableViewCell *cell = (ProductTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    
    [self setupProductCell:cell withProduct:product];
}

- (void) setupProductCell:(ProductTableViewCell *) cell withProduct:(ProductReceipt *) product {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (product.active) {
            [cell.imageviewCaption setImage:product.product.image];
            cell.viewHolder.alpha = 1.0;
        }
        else {
            [cell.imageviewCaption setImage:product.product.desaturatedImage];
            cell.viewHolder.alpha = 0.3;
//            [cell setNeedsDisplay];
        }
    });
}

- (void) setupProductCells {
    for (ProductReceipt *product in self.dataSource.currentProductOrdering) {
        [self setupProductCell:product];
    }
}


#pragma mark Cell Swiping
-(void) resetSelectedCell {
    //Dlog(@"Reset cell");
    ProductTableViewCell *cell = (ProductTableViewCell*)[self.tableView cellForRowAtIndexPath:self.selectedIndexPath];
    [cell resetContentView];
    self.selectedIndexPath = nil;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
}

-(void) swipeTableViewCellDidStartSwiping:(RMSwipeTableViewCell *)swipeTableViewCell {
    //Dlog(@"Did start swiping");
    
    NSIndexPath *indexPathForCell = [self.tableView indexPathForCell:swipeTableViewCell];
    if (self.selectedIndexPath.row != indexPathForCell.row) {
        [self resetSelectedCell];
    }
}

-(void) swipeTableViewCell:(ProductTableViewCell*)swipeTableViewCell didSwipeToPoint:(CGPoint)point velocity:(CGPoint)velocity {
    //reset the trigger for the cell, change the order and style of the cell where needed, and get a new cell ordering from the dealmaker
    //reflecting the changed state of the slid cell
    if (point.x == MAX_DISPLACEMENT || point.x == (-1 * MAX_DISPLACEMENT)) {
        ProductReceipt *selectedProduct = [self.dataSource productForIndex:[self.tableView indexPathForCell:swipeTableViewCell].row];
        [self selectProduct:selectedProduct];
        
        [swipeTableViewCell resetContentView];
        swipeTableViewCell.interruptPanGestureHandler = YES;
        
        [self.parent didSelectProduct:selectedProduct];
    }
    
}

-(void) swipeTableViewCellWillResetState:(RMSwipeTableViewCell *)swipeTableViewCell fromPoint:(CGPoint)point animation:(RMSwipeTableViewCellAnimationType)animation velocity:(CGPoint)velocity {
    
    //Dlog(@"Will reset state");
    return;
    
    if (velocity.x <= -500) {
        self.selectedIndexPath = [self.tableView indexPathForCell:swipeTableViewCell];
        swipeTableViewCell.shouldAnimateCellReset = NO;
        swipeTableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSTimeInterval duration = MAX(-point.x / ABS(velocity.x), 0.10f);
        
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             swipeTableViewCell.contentView.frame = CGRectOffset(swipeTableViewCell.contentView.bounds, point.x - (ABS(velocity.x) / 150), 0);
                         }
                         completion:^(BOOL finished) {
                             [UIView animateWithDuration:duration
                                                   delay:0
                                                 options:UIViewAnimationOptionCurveEaseOut
                                              animations:^{
                                                  swipeTableViewCell.contentView.frame = CGRectOffset(swipeTableViewCell.contentView.bounds, -80, 0);
                                              }
                                              completion:^(BOOL finished) {
                                              }];
                         }];
    }
}

-(void) swipeTableViewCellDidResetState:(RMSwipeTableViewCell*)swipeTableViewCell fromPoint:(CGPoint)point animation:(RMSwipeTableViewCellAnimationType)animation velocity:(CGPoint)velocity {
    //Dlog(@"Did reset state");
}


#pragma mark External Interface
- (void) updateTableRowOrder:(NSArray *)oldProducts toNewOrder:(NSArray *)newProducts {
    [self.tableView beginUpdates];
    
    for (int i = 0; i < newProducts.count; i++) {
        int newRow = [newProducts indexOfObject:[oldProducts objectAtIndex:i]];
        [self.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] toIndexPath:[NSIndexPath indexPathForRow:newRow inSection:0]];
    }
    
    [self.tableView endUpdates];
    
    [self setupProductCells];
}

- (void) selectProduct:(ProductReceipt *) product {
    //the method above triggers the slide, but the deal controller itself is what makes the magic happen. This is to allow external calls
    //to this method, i.e. from rollback
    
    int index = [self.dataSource.currentProductOrdering indexOfObject:product];
    NSArray *oldProducts = [self.dataSource.currentProductOrdering mutableCopy];
    NSArray *newProducts = [self.dataSource selectProductAtIndex:index];
    
//    ProductTableViewCell *cell = (ProductTableViewCell *) [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    
    [self updateTableRowOrder:oldProducts toNewOrder:newProducts];
}
@end
