//
//  ProductTableView.m
//  Grip
//
//  Created by Mickey Barboi on 6/3/14.
//  Copyright (c) 2014 Mickey Barboi. All rights reserved.
//

#import "ProductTableView.h"

@implementation ProductTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    [self setDataSource:self];
    [self setDelegate:self];
    return [super initWithCoder:aDecoder];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
