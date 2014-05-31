//
//  MBPickerView.h
//  ImageTargets
//
//  Created by Mickey Barboi on 7/24/13.
//
//

#import <UIKit/UIKit.h>

@interface MBPickerView : UIPickerView <UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) NSArray *data;

//this is the object that "owns" this picker
@property (weak, nonatomic) id parent;

@end
