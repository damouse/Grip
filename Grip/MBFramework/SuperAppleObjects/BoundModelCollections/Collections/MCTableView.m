//
//  MCTableView.m
//  test
//
//  Created by Mickey Barboi on 9/2/13.
//  Copyright (c) 2013 HardinDD. All rights reserved.
//

#import "MCTableView.h"
#import "MCBinder.h"

@implementation MCTableView {
    MCBinder *binder;
}

@synthesize data, reuseIdentifier, selectHandler, cellForRowHandler;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) initCollection {
    if(binder == nil)
        binder = [[MCBinder alloc] init];
    
    NSAssert(reuseIdentifier != nil, @"ReustIdentifier was not assigned prior to setting the data. Settuing the data reloads the collection, please set the properties before calling");
    
    //set up the tableview
    [self setDataSource:self];
    [self setDelegate:self];
    [self reloadData];
}


#pragma  mark Data and Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];

    NSObject *model = [data objectAtIndex:indexPath.row];
    
    [binder bindPropertiesFrom:model toObject:cell];
    
    if(cellForRowHandler) cellForRowHandler(model, cell, indexPath);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //remember: only 1 dimensional right now!
    if(selectHandler != nil)
        selectHandler([data objectAtIndex:indexPath.row], [tableView cellForRowAtIndexPath:indexPath]);
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark Overridden Synthesis
- (void) setData:(NSArray *)dataNew {
    //trigger the collection view to load and display when the data is set
    data = dataNew;
    
    [self initCollection];
}
@end
