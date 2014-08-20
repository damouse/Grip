//
//  MBViewAnimator.m
//  ImageTargets
//
//  Created by Mickey Barboi on 6/24/13.
//
//

/**
    TODO:
        -add support for orientation changes
        -enable objects to have multiple animations/directions and starting frames
        -add completion block support in the animateObject function (to allow callers to 
 */

#import "MBViewAnimator.h"
//#define DEBUG 1

//define the starting number to tag at (declared here in case of conflict)
#define STARTING_TAG 700


//STORAGE CLASS FOR INSTANCE DICTIONARY
@interface VAViewMetadata : NSObject

@property NSInteger tag;
@property (strong, nonatomic) UIView *view;
@property CGRect activeFrame;
@property CGRect hiddenFrame;
@property CGRect superview; //used by relative animations

//a set of CGRects keyed by position names. Register these on init
@property (strong, nonatomic) NSMutableDictionary *customFrames;
@end

@implementation VAViewMetadata : NSObject 

- (id) init {
    self = [super init];
    self.customFrames = [[NSMutableDictionary alloc] init];
    return self;
}
@end
//END STORAGE CLASS


@implementation MBViewAnimator {
    //stores the active and the hidden frames of ui elements to be animated
    NSMutableDictionary *animationFrameStorage;
    
    //the next tag to be used
    int currentlyFreeTag;
    
    double animationDuration;
}


#pragma mark Stock Object
- (id) initWithDuration:(double)duration {
    //init the object for use
    self = [super init];
    
    animationDuration = duration;
    currentlyFreeTag = STARTING_TAG;
    animationFrameStorage = [NSMutableDictionary dictionary];
    
    return self;
}


#pragma mark Onscreen/Offscreen animations
- (void) initObject:(UIView *)view inView:(UIView *)superview forSlideinAnimation:(VAAnimationDirection)direction  {
    if([animationFrameStorage objectForKey:[NSNumber numberWithInt:view.tag]] != nil) {
        [self cLog:@"duplicate slidein init call, aborting"];
        return;
    }
    
    //save the current frame
    CGRect active = view.frame;
    CGRect hidden = active;
    
    switch(direction) {
        case VAAnimationDirectionUp:
            hidden.origin.y = superview.bounds.size.height;
            break;
            
        case VAAnimationDirectionDown:
            hidden.origin.y = -active.size.height;
            break;
            
        case VAAnimationDirectionLeft:
            hidden.origin.x = superview.bounds.size.width;
            break;
            
        case VAAnimationDirectionRight:
            hidden.origin.x = -active.size.width;
            break;
    }

    
    //set the view to start in its hidden state
    view.frame = hidden;
    
    //tag the view (if it does not already have a tag) and add it to the save dictionary
    if(view.tag == 0)
        view.tag = [self getFreeTag];

    //create the save object
    VAViewMetadata *save = [[VAViewMetadata alloc] init];
    [save setHiddenFrame:hidden];
    [save setActiveFrame:active];
    [save setView:view];
    [save setTag:view.tag];
    
    [animationFrameStorage setObject:save forKey:[NSNumber numberWithInt:view.tag]];
}

- (void) animateObjectOnscreen:(UIView *)view completion:(void (^)(BOOL))completion {
    
    if(view.tag == 0) {
        [self cLog:@"animateObject called with an untagged view"];
        return;
    }
    
    //check if save is present and valid
    VAViewMetadata *save = [self getSaveForView:view];
    if(save == nil) return;

    //check if the object is actually in its hidden position
    if(!CGPointEqualToPoint(view.frame.origin, [save hiddenFrame].origin)) {
        [self cLog:[NSString stringWithFormat:@"view with tag %i is supposed to animate in, but is not in its hidden position", view.tag]];
        return;
    }
    
    //if its a button turn it off while its animating
    if([view isKindOfClass:[UIButton class]]) {
        ((UIButton *)view).enabled = NO;
    }
    
    //perform the animation
    [UIView animateWithDuration:animationDuration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^ {
                         view.frame = [save activeFrame];
                     }
                     completion:completion];
    
    //if its a button turn it off while its animating
    if([view isKindOfClass:[UIButton class]]) {
        // do somthing
        ((UIButton *)view).enabled = YES;
    }
}

- (void) animateObjectOffscreen:(UIView *)view completion:(void (^)(BOOL))completion {
    if(view.tag == 0) {
        [self cLog:@"animateObjectOffscreen called with an untagged view"];
        return;
    }
    
    //check if save is present and valid
    VAViewMetadata *save = [self getSaveForView:view];
    if(save == nil) return;
    
    //check if the object is actually in its active position
    if(!CGPointEqualToPoint(view.frame.origin, [save activeFrame].origin)) {
        [self cLog:[NSString stringWithFormat:@"view with tag %i is supposed to animate out, but is not in its active position", view.tag]];
        //return;
    }
    
    //perform the animation
    [UIView animateWithDuration:animationDuration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^ {
                         view.frame = [save hiddenFrame];
                     }
                     completion:completion];
}


#pragma mark Relative Superview Animations
- (void) initObjectForRelativeAnimation:(UIView *)view inView:(UIView *)superview {
    //What happens when you want to relatively animate a view that was also animated in?
    if([animationFrameStorage objectForKey:[NSNumber numberWithInt:view.tag]] != nil) {
        [self cLog:@"duplicate relative init call, aborting"];
        return;
    }

    //tag the view (if it does not already have a tag) and add it to the save dictionary
    if(view.tag == 0)
        view.tag = [self getFreeTag];
    
    //create the save object
    VAViewMetadata *save = [[VAViewMetadata alloc] init];
    [save setActiveFrame:view.frame];
    [save setView:view];
    [save setTag:view.tag];
    [save setSuperview:superview.bounds];
    
    [animationFrameStorage setObject:save forKey:[NSNumber numberWithInt:view.tag]];
}

//Animates a view to a position relative to its current position (right, left, etc) while preserving the given margin to the superview.
- (void) animateObjectToRelativePosition:(UIView *)view direction:(VAAnimationDirection)direction withMargin:(int)margin completion:(void (^)(BOOL))completion {
    //check if save is present and valid
    VAViewMetadata *save = [self getSaveForView:view];
    if(save == nil) return;
    
    CGRect newFrame = view.frame;
    CGRect superview = [save superview];
    
    switch(direction) {
        case VAAnimationDirectionUp:
            newFrame.origin.y = margin;
            break;
            
        case VAAnimationDirectionDown:
            newFrame.origin.y = superview.size.height - newFrame.size.height - margin;
            break;
            
        case VAAnimationDirectionLeft:
            newFrame.origin.x = margin;
            break;
            
        case VAAnimationDirectionRight:
            newFrame.origin.x = superview.size.width - newFrame.size.width - margin;
            break;
    }
    
    //perform the animation
    [UIView animateWithDuration:animationDuration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^ {
                         view.frame = newFrame;
                     }
                     completion:completion];
}

//Register a custom position with the animator. This position can be used to later animate the view as needed. Note that
//params are all relative: size is considered a percentage to the starting frame size, x and y are relative values which are calculated from the center of the view
//NOTE: must have called "initObjectForRelativeAnimation" first!
- (void) registerCustomAnimationForView:(UIView *) view key:(NSString *)key size:(float) sizePercent x:(int) x y:(int) y {
    VAViewMetadata *save = [self getSaveForView:view];
    if(save == nil) return;
    
    CGRect newFrame = save.activeFrame;
    
    int newHeight = newFrame.size.height * sizePercent;
    int newWidth = newFrame.size.width * sizePercent;

    //if the new height or width is large than before, adjust origin to keep the center in the same spot
    newFrame.origin.x = newFrame.origin.x + x + (newFrame.size.width - newWidth) / 2;
    newFrame.origin.y = newFrame.origin.y + y + (newFrame.size.height - newHeight) / 2;
    
    newFrame.size.height = newHeight;
    newFrame.size.width = newWidth;
    
    if ([save.customFrames objectForKey:key] != nil)
        NSLog(@"VA: WARN: key '%@' exists! Overwriting", key);
    
    [save.customFrames setObject:NSStringFromCGRect(newFrame) forKey:key];
    
    NSLog(@"VA: saved custom animation for key '%@'", key);
}

//Peforms the custom animations registered in the method above.
- (void) animateCustomAnimationForView:(UIView *)view andKey:(NSString *) key completion:(void (^)(BOOL))completion {
    VAViewMetadata *save = [self getSaveForView:view];
    if(save == nil) return;
    
    
    NSString *savedFrame = [save.customFrames objectForKey:key];
    
    if (savedFrame == nil) {
        NSLog(@"VA: WARN no animation present for key %@", key);
        return;
    }
    
    CGRect newFrame = CGRectFromString(savedFrame);
    
    [UIView animateWithDuration:animationDuration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^ {
                         view.frame = newFrame;
                     }
                     completion:completion];
}

- (void) animateObjectToStartingPosition:(UIView *)view completion:(void (^)(BOOL))completion {
    VAViewMetadata *save = [self getSaveForView:view];
    if(save == nil) return;

    //perform the animation
    [UIView animateWithDuration:animationDuration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^ {
                         view.frame = [save activeFrame];
                     }
                     completion:completion];
}

#pragma mark Utility
- (int) getFreeTag {
    currentlyFreeTag++;
    return currentlyFreeTag;
}

- (VAViewMetadata *) getSaveForView:(UIView *)view {
    //check if save is present and valid
    VAViewMetadata *save = [animationFrameStorage objectForKey:[NSNumber numberWithInt:view.tag]];
    if(save == nil) {
        [self cLog:[NSString stringWithFormat:@"save not found for tag %i", view.tag]];
        return nil;
    }
    
    return save;
}

- (void) cLog:(NSString *)log {
    // cLog = "conditionalLog"
    // log helper method that only outputs to console if DEBUG flag is set
#ifdef DEBUG
    NSLog(@"VA: %@", log);
#endif
}
@end
