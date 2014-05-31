//
//  UILabel.m
//  Culvers
//
//  Created by Mickey Barboi on 10/2/13.
//  Copyright (c) 2013 HardinDD. All rights reserved.
//

#import "UILabel+Utils.h"

@implementation UILabel (Utils)

- (void) underline {
    NSMutableAttributedString *commentString = [self.attributedText mutableCopy];
    [commentString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [commentString length])];
    [self setAttributedText:commentString];
}


@end
