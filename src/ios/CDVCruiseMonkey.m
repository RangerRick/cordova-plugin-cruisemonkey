#import "CDVCruiseMonkey.h"
#import <Cordova/CDVJSON.h>
#import "AppDelegate.h"

@implementation AppDelegate(AppDelegate)

-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    void (^safeHandler)(UIBackgroundFetchResult) = ^(UIBackgroundFetchResult result){
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(result);
        });
    };
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CruiseMonkey" object:safeHandler];
}

@end

@implementation CDVCruiseMonkey
{
    void (^_completionHandler)(UIBackgroundFetchResult);
    BOOL enabled;
    NSString *fetchCallbackId;
    NSNotification *_notification;
}

- (void)pluginInitialize
{
    [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(onFetch:)
        name:@"CruiseMonkey"
        object:nil];
}

- (void) configure:(CDVInvokedUrlCommand*)command
{    
    NSLog(@"- CDVCruiseMonkey configure");
    
    UIApplication *app = [UIApplication sharedApplication];
    
    if (![app respondsToSelector:@selector(setMinimumCruiseMonkeyInterval:)]) {
        NSLog(@" background fetch unsupported");
        return;
    }
    
    fetchCallbackId = command.callbackId;
    
    [app setMinimumCruiseMonkeyInterval:UIApplicationCruiseMonkeyIntervalMinimum];
    [app.delegate self];
    
    UIApplicationState state = [app applicationState];
    
    // Handle case where app was launched due to background-fetch event
    if (state == UIApplicationStateBackground && _completionHandler && _notification) {
        [self onFetch:_notification];
    }
}

-(void) onFetch:(NSNotification *) notification
{
    NSLog(@"- CDVCruiseMonkey onFetch");
    
    _notification = notification;
    _completionHandler = [notification.object copy];
    
    // Inform javascript a background-fetch event has occurred.
    [self.commandDelegate runInBackground:^{
        CDVPluginResult* result = nil;
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [result setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:result callbackId:fetchCallbackId];
    }];
}
-(void) finish:(CDVInvokedUrlCommand*)command
{
    NSLog(@"- CDVCruiseMonkey finish");
    [self doFinish];
}
-(void) doFinish
{
    UIApplication *app = [UIApplication sharedApplication];
    
    float finishTimer = (app.backgroundTimeRemaining > 25.0) ? 25.0 : app.backgroundTimeRemaining;
    
    [NSTimer scheduledTimerWithTimeInterval:finishTimer
        target:self
        selector:@selector(stopBackgroundTask:)
        userInfo:nil
        repeats:NO];
}
-(void) stopBackgroundTask:(NSTimer*)timer
{
    UIApplication *app = [UIApplication sharedApplication];
    if (_completionHandler) {
        NSLog(@"- CDVCruiseMonkey stopBackgroundTask (remaining t: %f)", app.backgroundTimeRemaining);
        _completionHandler(UIBackgroundFetchResultNewData);
        _completionHandler = nil;
    }
}

// If you don't stopMonitorying when application terminates, the app will be awoken still when a
// new location arrives, essentially monitoring the user's location even when they've killed the app.
// Might be desirable in certain apps.
- (void)applicationWillTerminate:(UIApplication *)application 
{
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
