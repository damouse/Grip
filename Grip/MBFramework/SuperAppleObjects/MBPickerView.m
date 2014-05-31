//
//  MBPickerView.m
//  ImageTargets
//
//  Created by Mickey Barboi on 7/24/13.
//
//

/*
 this class is my custom implementation of the UIPicker. Nothing special really happens here, this 
 class is seperate so i can easily copy the code over if needed and to reduce clutter in the main class. 
 
 TODO: add built in animator support, add the button programatically. 
 */

#import "MBPickerView.h"

@implementation MBPickerView
@synthesize data;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        data = nil;
        self.dataSource = self;
        self.delegate = self;
    }
    return self;
}

#pragma mark Custom Synthesis
- (void) setData:(NSArray *)dataN {
    data = dataN;
    
    self.dataSource = self;
    self.delegate = self;
    
    [self reloadAllComponents];
}

#pragma mark Picker Delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    return 1;//Or return whatever as you intend
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    return [data count];
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [data objectAtIndex:row];//Or, your suitable title; like Choice-a, etc.
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSString *choice = [data objectAtIndex:row];
    [_parent mbpicker:self didSelectOption:choice];
}

#pragma mark SAMPLE CALLBACK METHOD
- (void) mbpicker:(MBPickerView *)picker didSelectOption:(NSString *)choice {
    
}
@end
