//
//  UIButton.m
//  Culvers
//
//  Created by Mickey Barboi on 9/30/13.
//  Copyright (c) 2013 HardinDD. All rights reserved.
//

#import "UIButton+Utils.h"

@implementation UIButton (Utils)

- (void) setTitleAndResize:(NSString *)title {
    CGSize stringsize = [title sizeWithFont:[UIFont systemFontOfSize:14]];
    
    CGRect frame = self.frame;
    frame.size = CGSizeMake(stringsize.width, stringsize.height);
    //self.frame = frame;
    
    //god do we hate autolayout
    //[self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:stringsize.width]];
    [self setTitle:title forState:UIControlStateNormal];
}

- (void) underline {
    NSMutableAttributedString *commentString = [self.titleLabel.attributedText mutableCopy];
    [commentString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [commentString length])];
    
    [self.titleLabel setAttributedText:commentString];
}

//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    self.titleLabel.textColor = HIGHLIGHT_COLOR;
//}
//
//-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [UIView animateWithDuration:10 animations:^{
//        self setTitle
//        self.titleLabel.textColor = [UIColor whiteColor];
//    }];
//    
//}
@end
