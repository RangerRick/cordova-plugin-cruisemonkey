#import <Cordova/CDVPlugin.h>
#import "AppDelegate.h"

@interface CDVCruiseMonkey : CDVPlugin <UIApplicationDelegate>
- (void) configure:(CDVInvokedUrlCommand*)command;
- (void) finish:(CDVInvokedUrlCommand*)command;
@end

