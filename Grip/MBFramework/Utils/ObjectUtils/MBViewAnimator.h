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

//Register an object for offscreen animation: should be called in viewDidLoad. 
- (void) initObject:(UIView *)view inView:(UIView *)superview forSlideinAnimation:(VAAnimationDirection)direction;

//move the object onscreen. Does nothing if the object is not in its proper offscreen position
- (void) animateObjectOnscreen:(UIView *)view completion:(void (^)(BOOL))completion;

//move the object offscreen. Does nothing if the object is not in its proper offscreen position
- (void) animateObjectOffscreen:(UIView *)view completion:(void (^)(BOOL))completion;

@end
