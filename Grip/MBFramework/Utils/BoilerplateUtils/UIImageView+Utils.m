//
//  UIImage.m
//  Culvers
//
//  Created by Mickey Barboi on 9/30/13.
//  Copyright (c) 2013 HardinDD. All rights reserved.
//

#import "UIImageView+Utils.h"

@implementation UIImageView (Utils)

//- (void) removeWhitespace {
//    //TESTING METHOD!
//    
//    UIImage *viewImage = self.image;
//    
//    for(int i = 0; i < 10; i++) {
//        viewImage = [self removeWhitespaceWithOffset:i];
//        [self setImage:viewImage];
//    }
//}

//- (UIImage *) removeWhitespaceWithOffset:(int) offset {
//    //this is used to remove a range of whites off the image
//    int rgb = 255 - offset;
//    
//    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 1.0);
//    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
//    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    CGImageRef rawImageRef = viewImage.CGImage;
//    const float colorMasking[6] = {rgb, rgb, rgb, rgb, rgb, rgb};
//    UIGraphicsBeginImageContext(viewImage.size);
//    CGImageRef maskedImageRef = CGImageCreateWithMaskingColors(rawImageRef, colorMasking);
//    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0.0, viewImage.size.height);
//    CGContextScaleCTM(UIGraphicsGetCurrentContext(), 1.0, -1.0);
//    
//    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, viewImage.size.width, viewImage.size.height), maskedImageRef);
//    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
//    CGImageRelease(maskedImageRef);
//    UIGraphicsEndImageContext();
//    
//    return newImage;
//}
@end
