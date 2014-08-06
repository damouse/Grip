//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#import "LandingViewController.h"
#import <AFNetworking/AFNetworking.h>


#define DEBUG true

//conditional debug logging
#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d]\n\t" fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif

//unconditional logging
#define ULog(fmt, ...) NSLog((@"%s [Line %d]\n\t" fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

//pops an alert, debug logging
#ifdef DEBUG
#   define ALog(fmt, ...)  { UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%s\n [Line %d] ", __PRETTY_FUNCTION__, __LINE__] message:[NSString stringWithFormat:fmt, ##__VA_ARGS__]  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil]; [alert show]; }
#else
#   define ALog(...)
#endif