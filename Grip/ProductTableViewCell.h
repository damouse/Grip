//
//  ProductTableViewCell.h
//  Grip
//
//  Created by Mickey Barboi on 6/3/14.
//  Copyright (c) 2014 Mickey Barboi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *viewTitleBar;
@property (weak, nonatomic) IBOutlet UIView *viewHolder;

@property (weak, nonatomic) IBOutlet UILabel *labelTitle;

@property (weak, nonatomic) IBOutlet UITextView *textviewDetails;

@property (weak, nonatomic) IBOutlet UIImageView *imageviewCaption;

@end
