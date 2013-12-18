//
//  AppDelegate.m
//  SingPost
//
//  Created by Edward Soetiono on 24/9/13.
//  Copyright (c) 2013 Codigo. All rights reserved.
//

#import "AppDelegate.h"
#import "RootViewController.h"
#import <Reachability.h>
#import <UIAlertView+Blocks.h>
#import <SVProgressHUD.h>
#import "DatabaseSeeder.h"
#import "PushNotification.h"
#import "TrackedItem.h"
#import "ApiClient.h"
#import "TrackingMainViewController.h"

@implementation AppDelegate

+ (AppDelegate *)sharedAppDelegate {
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    [MagicalRecord setupCoreDataStack];
    [DatabaseSeeder seedLocationsDataIfRequired];
    [DatabaseSeeder seedOffersDataIfRequired];  //FIXME: for development only
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    _rootViewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
    [self.window setRootViewController:_rootViewController];
    [self.window makeKeyAndVisible];
    
    [self hasInternetConnectionWarnIfNoConnection:YES];
    [self updateMaintananceStatuses];
    [self setupGoogleAnalytics];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [self hasInternetConnectionWarnIfNoConnection:YES];
    [self updateMaintananceStatuses];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)setupGoogleAnalytics
{
    [GAI sharedInstance].trackUncaughtExceptions = NO;
    [GAI sharedInstance].dispatchInterval = 20;

//    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    [[GAI sharedInstance] trackerWithTrackingId:GAI_ID];
}

#pragma mark - Maintanance

- (void)updateMaintananceStatuses
{
    [[ApiClient sharedInstance] getMaintananceStatusOnSuccess:^(id responseJSON) {
        _maintenanceStatuses = responseJSON[@"root"];
        [_rootViewController updateMaintananceStatusUIs];
    } onFailure:^(NSError *error) {
        _maintenanceStatuses = nil;
    }];
}

#pragma mark - Utilities

- (BOOL)hasInternetConnectionWarnIfNoConnection:(BOOL)warnIfNoConnection
{
    BOOL hasInternetConnection = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable;
    if (!hasInternetConnection && warnIfNoConnection) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No/Slow Internet Connection" message:@"Your device is not connected to the internet, or may have slow access." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
        [alertView show];
    }
    
    return hasInternetConnection;
}

#pragma mark - APNS

- (void)handleRemoteNotification:(NSDictionary *)payloadInfo
{
    NSLog(@"received payload: %@", payloadInfo);
    
    NSString *trackingNumber = payloadInfo[@"i"];
    NSDictionary *aps = [payloadInfo objectForKey:@"aps"];
    
    if (trackingNumber.length > 0) {
        //it's a tracking item apns
        [UIAlertView showWithTitle:@"SingPost"
                           message:aps[@"alert"]
                 cancelButtonTitle:@"Cancel"
                 otherButtonTitles:@[@"View"]
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              if (buttonIndex != [alertView cancelButtonIndex]) {
                                  [SVProgressHUD showWithStatus:@"Please wait..." maskType:SVProgressHUDMaskTypeClear];
                                  [TrackedItem API_getItemTrackingDetailsForTrackingNumber:trackingNumber onCompletion:^(BOOL success, NSError *error) {
                                      if (success) {
                                          [SVProgressHUD dismiss];
                                          TrackingMainViewController *trackingMainViewController = [[TrackingMainViewController alloc] initWithNibName:nil bundle:nil];
                                          trackingMainViewController.trackingNumber = trackingNumber;
                                          [self.rootViewController cPushViewController:trackingMainViewController];
                                      }
                                      else {
                                          [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                                      }
                                  }];
                              }
                          }];
    }
    else {
        //a plain alert apns
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SingPost" message:aps[@"alert"] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
        [alertView show];
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [self handleRemoteNotification:userInfo];
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSString *sanitizedDeviceToken = [[[[deviceToken description]
                                        stringByReplacingOccurrencesOfString: @"<" withString: @""]
                                       stringByReplacingOccurrencesOfString: @">" withString: @""]
                                      stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    NSLog(@"sanitized device token: %@", sanitizedDeviceToken);
    [PushNotification API_registerAPNSToken:sanitizedDeviceToken onCompletion:^(BOOL success, NSError *error) {
        //do nothing
    }];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}

#pragma mark - Google Analytics

- (void)trackGoogleAnalyticsWithScreenName:(NSString *)screenName
{
    [[GAI sharedInstance].defaultTracker set:kGAIScreenName value:screenName];
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createAppView] build]];
}

@end
