//
//  ProductTableViewCell.h
//  Grip
//
//  Created by Mickey Barboi on 6/3/14.
//  Copyright (c) 2014 Mickey Barboi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RMSwipeTableViewCell.h"

@interface ProductTableViewCell : RMSwipeTableViewCell

@property (weak, nonatomic) IBOutlet UIView *viewTitleBar;
@property (weak, nonatomic) IBOutlet UIView *viewHolder;

@property (weak, nonatomic) IBOutlet UILabel *labelTitle;

@property (weak, nonatomic) IBOutlet UITextView *textviewDetails;

@property (weak, nonatomic) IBOutlet UIImageView *imageviewCaption;

//Swipable goodies
@property (nonatomic, assign) id delegate;

-(void) resetContentView;

@end
