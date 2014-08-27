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
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.products count];
}

/*- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 103;
}*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"cell";
    ProductTableViewCell *cell = (ProductTableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    cell.delegate = self;
    cell.maxDisplacement = MAX_DISPLACEMENT;
    
    [cell.textviewDetails setTextColor:P_TEXT_COLOR];
    
    Product *product = [self.products objectAtIndex:indexPath.row];
    
    if (cell == nil)
        cell = [[ProductTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    
    //fill content
    [cell.textviewDetails setText:product.item_description];
    [cell.labelTitle setText:product.name];
    [cell.imageviewCaption setImage:product.image];
    
//    [cell.imageviewCaption sd_setImageWithURL:[product imageUrl] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//        NSLog(@"Loaded");
//    }];
    //[cell.imageView sd_setImageWithURL:[product imageUrl] placeholderImage:nil];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Product *product = [self.products objectAtIndex:indexPath.row];
    [self.parent didSelectProduct:product];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark Cell Swiping
-(void)resetSelectedCell {
    //Dlog(@"Reset cell");
    ProductTableViewCell *cell = (ProductTableViewCell*)[self.tableView cellForRowAtIndexPath:self.selectedIndexPath];
    [cell resetContentView];
    self.selectedIndexPath = nil;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
}

-(void)swipeTableViewCellDidStartSwiping:(RMSwipeTableViewCell *)swipeTableViewCell {
    //Dlog(@"Did start swiping");
    
    NSIndexPath *indexPathForCell = [self.tableView indexPathForCell:swipeTableViewCell];
    if (self.selectedIndexPath.row != indexPathForCell.row) {
        [self resetSelectedCell];
    }
}

-(void)swipeTableViewCell:(ProductTableViewCell*)swipeTableViewCell didSwipeToPoint:(CGPoint)point velocity:(CGPoint)velocity {
    //trigger reset
    if (point.x == MAX_DISPLACEMENT || point.x == (-1 * MAX_DISPLACEMENT)) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:swipeTableViewCell];
        
        //save the old order of the array
        NSMutableArray *oldOrder = [self.products mutableCopy];
        
        //set up the new order
        Product *product = [self.products objectAtIndex:indexPath.row];
        [self.products removeObjectAtIndex:indexPath.row];
        [self.products addObject:product];
        
        [self.tableView beginUpdates];

        for (int i = 0; i < self.products.count; i++) {
            // newRow will get the new row of an object.  i is the old row.
            int newRow = [self.products indexOfObject:[oldOrder objectAtIndex:i]];
            [self.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] toIndexPath:[NSIndexPath indexPathForRow:newRow inSection:0]];
        }

        [self.tableView endUpdates];
        
        //Dlog(@"Removing cell at index %i", indexPath.row);
        [swipeTableViewCell resetContentView];
        swipeTableViewCell.interruptPanGestureHandler = YES;
        
//        [self.tableView beginUpdates];
//        product = [self.products objectAtIndex:indexPath.row];
//        [self.products removeObjectAtIndex:indexPath.row];
//        [self.products addObject:product];
//        [self.tableView reloadData];
//        [self.tableView endUpdates];
        
    }
}

-(void)swipeTableViewCellWillResetState:(RMSwipeTableViewCell *)swipeTableViewCell fromPoint:(CGPoint)point animation:(RMSwipeTableViewCellAnimationType)animation velocity:(CGPoint)velocity {
    
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
    
    // The below behaviour is not normal as of iOS 7 beta seed 1
    // for Messages.app, but it is for Mail.app.
    // The user has to pan/swipe with a certain amount of velocity
    // before the cell goes to delete-state. If the user just pans
    // above the threshold for the button but without enough velocity,
    // the cell will reset.
    // Mail.app will, however allow for the cell to reveal the button
    // even if the velocity isn't high, but the pan translation is
    // above the threshold. I am assuming it'll get more consistent
    // in later seed of the iOS 7 beta
    /*
     else if (velocity.x > -500 && point.x < -80) {
     self.selectedIndexPath = [self.tableView indexPathForCell:swipeTableViewCell];
     swipeTableViewCell.shouldAnimateCellReset = NO;
     swipeTableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
     NSTimeInterval duration = MIN(-point.x / ABS(velocity.x), 0.15f);
     [UIView animateWithDuration:duration
     animations:^{
     swipeTableViewCell.contentView.frame = CGRectOffset(swipeTableViewCell.contentView.bounds, -80, 0);
     }];
     }
     */
}

-(void)swipeTableViewCellDidResetState:(RMSwipeTableViewCell*)swipeTableViewCell fromPoint:(CGPoint)point animation:(RMSwipeTableViewCellAnimationType)animation velocity:(CGPoint)velocity {
    //Dlog(@"Did reset state");
}
@end
