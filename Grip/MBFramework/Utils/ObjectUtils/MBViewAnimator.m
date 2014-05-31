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
@end

@implementation VAViewMetadata : NSObject 

@end
//END STORAGE CLASS


@implementation MBViewAnimator {
    //stores the active and the hidden frames of ui elements to be animated
    NSMutableDictionary *animationFrameStorage;
    
    //the next tag to be used
    int currentlyFreeTag;
}

#pragma mark Stock Object
- (id) init {
    //init the object for use
    self = [super init];
    
    currentlyFreeTag = STARTING_TAG;
    animationFrameStorage = [NSMutableDictionary dictionary];
    
    return self;
}

#pragma mark Public
- (void) initObject:(UIView *)view inView:(UIView *)superview forSlideinAnimation:(VAAnimationDirection)direction  {
    /** 
        Given a view, this method creates the two frames needed to animate it simply onto the screen. The direction specifies which
        direction the view comes onto the screen from (direction == up means the view will appear from the bottom.)
     
        This class WILL TAG VIEWS starting with tag# 700. Be careful not to use this class if you have tags in that range!
        Alternatively, you can change the starting tag number at the top of this object.
     
        To animate the view, simply call the animation method with the correct direction. 
     
        Superview is included to support automatic frame recalc in the case of an orientation change (NOT CURRENTLY IMPLEMENTED)
     
        You cannot call this method twice with two different directions on the same object and expect it to work.
     */

    [self cLog:@"init object starting..."];
    
    if(view == nil /*|| direction == nil*/){
        NSLog(@"VA WARN: Invalid parameters passed to initObject");
        return;
    }
    
    if([animationFrameStorage objectForKey:[NSNumber numberWithInt:view.tag]] != nil) {
        [self cLog:@"duplicate init call, aborting"];
        return;
    }
    
    
    //save the current frame
    CGRect active = view.frame;
    CGRect hidden = active;
    
    
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
                hidden.origin.x = superview.frame.size.height;
                break;
                
            case VAAnimationDirectionRight:
                hidden.origin.x = -active.size.width;
                break;
        }
    }
    else { //portrait
        switch(direction) {
            case VAAnimationDirectionUp:
                hidden.origin.y = superview.frame.size.height;
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
    
    //set the view to start in its hidden state
    view.frame = hidden;
    
    //tag the view (if it does not already have a tag) and add it to the save dictionary
    int tag;
    if(view.tag == 0) {
        //ASSUME: view tags are unique AND view tags do not conflict with VA tags (need to fix this)
        tag = currentlyFreeTag;
        view.tag = currentlyFreeTag;
        currentlyFreeTag++;
    }
    else 
        tag = view.tag;
    
    //create the save object
    VAViewMetadata *save = [[VAViewMetadata alloc] init];
    [save setHiddenFrame:hidden];
    [save setActiveFrame:active];
    [save setView:view]; //do we need to keep a ref to the object?
    [save setTag:tag];
    
    [animationFrameStorage setObject:save forKey:[NSNumber numberWithInt:tag]];
    
    [self cLog:@"init object done"];
}

- (void) animateObjectOnscreen:(UIView *)view completion:(void (^)(BOOL))completion {
    //bring the object in from its hidden state to its active state
    [self cLog:@"animateObjectOnscreen starting..."];
    
    if(view.tag == 0) {
        [self cLog:@"animateObject called with an untagged view"];
        return;
    }
    
    //check if save is present and valid
    VAViewMetadata *save = [animationFrameStorage objectForKey:[NSNumber numberWithInt:view.tag]];
    if(save == nil) {
        [self cLog:[NSString stringWithFormat:@"save not found for tag %i", view.tag]];
        return;
    }

    // This project does not deal with this check very well, since VC's are not sizing themselves appropriately in viewDidLoad (because of the nested subviews)
    //NSLog(@"view o: %@, saved o: %@",  NSStringFromCGPoint(view.frame.origin),  NSStringFromCGPoint([save hiddenFrame].origin));
    
    //check if the object is actually in its hidden position
    if(!CGPointEqualToPoint(view.frame.origin, [save hiddenFrame].origin)) {
        [self cLog:[NSString stringWithFormat:@"view with tag %i is supposed to animate in, but is not in its hidden position", view.tag]];
        return;
    }
    
    //if its a button turn it off while its animating
    if([view isKindOfClass:[UIButton class]]) {
        // do somthing
        ((UIButton *)view).enabled = NO;
    }
    
    //perform the animation
    [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^ {
                         view.frame = [save activeFrame];
                     }
                     completion:completion];
    
    //if its a button turn it off while its animating
    if([view isKindOfClass:[UIButton class]]) {
        // do somthing
        ((UIButton *)view).enabled = YES;
    }
    
    [self cLog:@"animateObjectOnscreen done"];
}

- (void) animateObjectOffscreen:(UIView *)view completion:(void (^)(BOOL))completion {
    //bring the object in from its hidden state to its active state
    [self cLog:@"animateObjectOffscreen starting..."];
    
    if(view.tag == 0) {
        [self cLog:@"animateObjectOffscreen called with an untagged view"];
        return;
    }
    
    //check if save is present and valid
    VAViewMetadata *save = [animationFrameStorage objectForKey:[NSNumber numberWithInt:view.tag]];
    if(save == nil) {
        [self cLog:[NSString stringWithFormat:@"save not found for tag %i", view.tag]];
        return;
    }
    
    //NSLog(@"view o: %@, saved o: %@",  NSStringFromCGPoint(view.frame.origin),  NSStringFromCGPoint([save activeFrame].origin));
    
    //check if the object is actually in its active position
    if(!CGPointEqualToPoint(view.frame.origin, [save activeFrame].origin)) {
        [self cLog:[NSString stringWithFormat:@"view with tag %i is supposed to animate out, but is not in its active position", view.tag]];
        //return;
    }
    
    //perform the animation
    [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^ {
                         view.frame = [save hiddenFrame];
                     }
                     completion:completion];
    
    [self cLog:@"animateObjectOffscreen done"];
}

#pragma mark Utility
- (BOOL) saveIsValid {
    //checks to make sure the packaged save data is valid: IN PROGRESS
    return true;
}

- (CGRect) getHiddenFrameForDirection {
    //This method is independant of all the other init methods so that it can be called on orientation change (in progress)
    
    return CGRectMake(0, 0, 0, 0);
}

- (void) cLog:(NSString *)log {
    // cLog = "conditionalLog"
    // log helper method that only outputs to console if DEBUG flag is set
#ifdef DEBUG
    NSLog(@"VA: %@", log);
#endif
}
@end
