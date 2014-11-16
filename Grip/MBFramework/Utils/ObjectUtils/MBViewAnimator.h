//
//  MBViewAnimator.h
//  ImageTargets
//
//  Created by Mickey Barboi on 6/24/13.
//
// Refactored 5-31 to enable animations of all flavors.

/*
    5-31 Refactor
 This class should also be able to animate views to any position within the frame, not just on/offscreen.
 The system relies on relative positioning as to remove the need to manually specify frames: this also serves
 to allow use on multiple sized screens without issues. 
 
 Animating on/offscreen:
    -ability to specify where the animation starts/ends
    -does the frame start in hidden or shown position?
    
 Animating around onscreen:
    -ability to specify end frame relative to edge of another object or the screen
*/


#import <Foundation/Foundation.h>

//view animator directions: these are the direction the view will move when coming onto the screen (i.e. "up" means the view starts offscreen at the bottom)
typedef enum VAAnimationDirection{
    VAAnimationDirectionUp,
    VAAnimationDirectionDown,
    VAAnimationDirectionLeft,
    VAAnimationDirectionRight
} VAAnimationDirection;

@interface MBViewAnimator : NSObject

- (id) initWithDuration:(double)duration;

#pragma mark Onscreen/Offscreen animations
/* Used to move a view on and offscreen.
 
 Given a view, this method creates the two frames needed to animate it simply onto the screen. The direction specifies which
 direction the view comes onto the screen from (direction == up means the view will appear from the bottom.)
 
 This class WILL TAG VIEWS starting with tag# 700. Be careful not to use this class if you have tags in that range!
 Alternatively, you can change the starting tag number at the top of this object.
 
 To animate the view, simply call the animation method with the correct direction.
 
 Superview is included to support automatic frame recalc in the case of an orientation change (NOT CURRENTLY IMPLEMENTED)
 
 You cannot call this method twice with two different directions on the same object and expect it to work.
 */
- (void) initObject:(UIView *)view inView:(UIView *)superview forSlideinAnimation:(VAAnimationDirection)direction;

/*
 Emergency hack-- returning view controllers leave some frames offscreen. This is needed to force a reinit without checking for existing frame
 WARN WARN WARN
 
 When a VC dissapears and reappears, it calls init again. Init normally moves the objects offscreen when called, 
 but any views that remained onscreen when the VC left will show as duplicates in the save and thus will not be init'd
 offscreen. 
 
 Similar error- if a view is left offscreen and then re-init'd, it will stay offscreen perpetually. 
 */
-(void) initObjectForce:(UIView *)view inView:(UIView *)superview forSlideinAnimation:(VAAnimationDirection)direction;

//move the object onscreen. Does nothing if the object is not in its proper offscreen position
- (void) animateObjectOnscreen:(UIView *)view completion:(void (^)(BOOL))completion;

//move the object offscreen. Does nothing if the object is not in its proper offscreen position
- (void) animateObjectOffscreen:(UIView *)view completion:(void (^)(BOOL))completion;


#pragma mark Relative Animations
/*
 Used to move an object around within its superview. 
 
 Register the object, then call the animate method with the appropriate direction.
 
 Example: object is in the middle of the screen, and Left is passed as the direction with a margin of 10. When the animation is called 
 the object is moved from its current position to the left margin of its superview.
 
 The purpose of the registration is to tag the view and remember its original position.
 */
- (void) initObjectForRelativeAnimation:(UIView *)view inView:(UIView *)superview;

/*
 Moves the view in the direction specified until it is (margin) away from the edge of its superview. Note that the direction given specifies
 which edge to compare the margin to: a right animation will check the right edge of the view with the right edge of the superview.
 */
- (void) animateObjectToRelativePosition:(UIView *)view direction:(VAAnimationDirection)direction withMargin:(int)margin completion:(void (^)(BOOL))completion;

//reset the view to its starting position. Must have previously been registered.
- (void) animateObjectToStartingPosition:(UIView *)view completion:(void (^)(BOOL))completion;


#pragma mark Custom Animations
/*
 MUST call initObjectForRelativeAnimation first! Please refactor this later.
 
 Registers a custom animation with the animator. Custom animations specify a new size and position for the view. The size is a
 percentage of its current size.
 
 The x and y parameters are relative values to the view's original frame
 
 Custom animations are saved under a string and can be executed with the method below by providing the string. 
 */
- (void) registerCustomAnimationForView:(UIView *) view key:(NSString *)key size:(float) sizePercent x:(int) x y:(int) y;

/*
 Perform a custom animation previously registered,
 */
- (void) animateCustomAnimationForView:(UIView *)view andKey:(NSString *) key completion:(void (^)(BOOL))completion;
@end
