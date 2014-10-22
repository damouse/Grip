//
//  TPSMasterViewController.m
//  Sample-UISearchController
//
//  Created by James Dempsey on 7/4/14.
//  Copyright (c) 2014 Tapas Software. All rights reserved.
//
//  Based on Apple sample code TableSearch version 2.0
//

#import "SearchViewController.h"

#import "Grip-Swift.h"


@interface SearchViewController () <UISearchResultsUpdating>

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NSMutableArray *searchResults; // Filtered search results

@end

#pragma mark -

@implementation SearchViewController

- (void)viewDidLoad {

    [super viewDidLoad];

    // Create a mutable array to contain products for the search results table.
    self.searchResults = [NSMutableArray arrayWithCapacity:[self.customers count]];

    UITableViewController *searchResultsController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    searchResultsController.tableView.dataSource = self;
    searchResultsController.tableView.delegate = self;

    self.searchController = [[UISearchController alloc] initWithSearchResultsController:searchResultsController];

    self.searchController.searchResultsUpdater = self;

    self.searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x, self.searchController.searchBar.frame.origin.y, self.searchController.searchBar.frame.size.width, 44.0);
    self.searchController.searchBar.barTintColor = PRIMARY_DARK;
    self.searchController.searchBar.tintColor = [UIColor whiteColor];
    
    self.tableView.tableHeaderView = self.searchController.searchBar;

    self.definesPresentationContext = YES;
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    /*  If the requesting table view is the search controller's table view, return the count of
        the filtered list, otherwise return the count of the main list.
     */
    if (tableView == ((UITableViewController *)self.searchController.searchResultsController).tableView) {
        return [self.searchResults count] + 1;
    } else {
        return [self.customers count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ProductCell";

    // Dequeue a cell from self's table view.
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];

    /*  If the requesting table view is the search controller's table view, configure the cell using the search results array, otherwise use the product array.
     */
    Customer *customer;

    
    if (tableView == ((UITableViewController *)self.searchController.searchResultsController).tableView) {
        //the first cell is a dummy cell to get around the strange overlap that the search bar does over the table
        if (indexPath.row != 0) {
            customer = [self.searchResults objectAtIndex:indexPath.row - 1];
            cell.textLabel.text = customer.name;
        }
        else {
            cell.textLabel.text = @"";
        }
    } else {
        customer = [self.customers objectAtIndex:indexPath.row];
        cell.textLabel.text = customer.name;
    }
    
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor clearColor];

    return cell;
}


#pragma mark - UISearchResultsUpdating
-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {

    NSString *searchString = [self.searchController.searchBar text];

    NSString *scope = nil;

    NSInteger selectedScopeButtonIndex = [self.searchController.searchBar selectedScopeButtonIndex];
    
//    if (selectedScopeButtonIndex > 0) {
//        scope = [[Customer deviceTypeNames] objectAtIndex:(selectedScopeButtonIndex - 1)];
//    }

    [self updateFilteredContentForProductName:searchString type:scope];
    
    [((UITableViewController *)self.searchController.searchResultsController).tableView reloadData];
}


#pragma mark - Content Filtering
- (void)updateFilteredContentForProductName:(NSString *)productName type:(NSString *)typeName {

    // Update the filtered array based on the search text and scope.
    if ((productName == nil) || [productName length] == 0) {
        // If there is no search string and the scope is "All".
        if (typeName == nil) {
            self.searchResults = [self.customers mutableCopy];
        } else {
            // If there is no search string and the scope is chosen.
            NSMutableArray *searchResults = [[NSMutableArray alloc] init];
            
            for (Customer *customer in self.customers) {
                if ([customer.name isEqualToString:typeName]) {
                    [searchResults addObject:customer];
                }
            }
            self.searchResults = searchResults;
        }
        return;
    }


    [self.searchResults removeAllObjects]; // First clear the filtered array.

    /*  Search the main list for products whose type matches the scope (if selected) and whose name matches searchText; add items that match to the filtered array.
     */
    for (Customer *customer in self.customers) {
        if ((typeName == nil) || [customer.name isEqualToString:typeName]) {
            NSUInteger searchOptions = NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch;
            NSRange productNameRange = NSMakeRange(0, customer.name.length);
            NSRange foundRange = [customer.name rangeOfString:productName options:searchOptions range:productNameRange];
            if (foundRange.length > 0) {
                [self.searchResults addObject:customer];
            }
        }
    }
}


#pragma mark Setters
- (void) setCustomers:(NSArray *)customers {
    _customers = customers;
    [self.tableView reloadData];
}


@end
