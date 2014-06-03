//
//  UIView+Utils.m
//  Grip
//
//  Created by Mickey Barboi on 6/3/14.
//  Copyright (c) 2014 Mickey Barboi. All rights reserved.
//

#import "UIView+Utils.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (Utils)

- (void) addBorderWithColor:(UIColor *)color andWidth:(float)width {
    self.layer.borderColor = color.CGColor;
    self.layer.borderWidth = width;
}

- (void) addDefaultBorder {
    self.layer.borderColor = [UIColor blackColor].CGColor;
    self.layer.borderWidth = 3.0f;
}

@end
