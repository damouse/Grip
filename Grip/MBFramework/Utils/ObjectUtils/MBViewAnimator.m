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
@end

@implementation VAViewMetadata : NSObject 

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
        [self cLog:@"duplicate init call, aborting"];
        return;
    }
    
    //save the current frame
    CGRect active = view.frame;
    CGRect hidden = active;
    
    /*
    //the way in which directions are calculated change based on device orientation
    if (UIDeviceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        switch(direction) {
            case VAAnimationDirectionUp:
                hidden.origin.y = superview.frame.size.width;
                break;
                
            case VAAnimationDirectionDown:
                hidden.origin.y = -active.size.height;
                break;
                
            case VAAnimationDirectionLeft:
                hidden.origin.x = superview.frame.size.width;
                break;
                
            case VAAnimationDirectionRight:
                hidden.origin.x = -active.size.width;
                break;
        }
    }
    else { //portrait */
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
    //}
    
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
        [self cLog:@"duplicate init call, aborting"];
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
