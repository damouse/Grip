//
//  ProductTableViewCell.m
//  Grip
//
//  Created by Mickey Barboi on 6/3/14.
//  Copyright (c) 2014 Mickey Barboi. All rights reserved.
//

#import "ProductTableViewCell.h"

#define BUTTON_THRESHOLD 80

@implementation ProductTableViewCell

- (void) initialize {
    [super initialize];
    [self colorize];
    
    self.revealDirection = RMSwipeTableViewCellRevealDirectionBoth;
    self.animationType = RMSwipeTableViewCellAnimationTypeEaseOut;
    self.panElasticityStartingPoint = BUTTON_THRESHOLD;
}

- (void) colorize {
//    self.viewTitleBar.backgroundColor = HIGHLIGHT_COLOR;
    self.viewHolder.backgroundColor = PRIMARY_DARK;
    self.contentView.backgroundColor = PRIMARY_LIGHT;
    self.textviewDetails.backgroundColor = PRIMARY_DARK;
    self.labelTitle.backgroundColor = PRIMARY_DARK;
    
    self.backViewbackgroundColor = PRIMARY_LIGHT;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(void)resetContentView {
    [UIView animateWithDuration:0.15f
                     animations:^{
                         self.contentView.frame = CGRectOffset(self.contentView.bounds, 0, 0);
                     }
                     completion:^(BOOL finished) {
                         self.shouldAnimateCellReset = YES;
                         [self cleanupBackView];
                     }];
}

@end
