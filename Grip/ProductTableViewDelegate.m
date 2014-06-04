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

@implementation ProductTableViewDelegate

#pragma mark Data and Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

/*- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 103;
}*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"cell";
    ProductTableViewCell *cell = (ProductTableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil)
        cell = [[ProductTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    
    //fill content
    [cell.textviewDetails setText:@"Test"];
    [cell.labelTitle setText:[NSString stringWithFormat:@"Cell %i", indexPath.row]];
    
    //sliding testing
    
    
    //set border
    [cell.viewHolder addDefaultBorder];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
