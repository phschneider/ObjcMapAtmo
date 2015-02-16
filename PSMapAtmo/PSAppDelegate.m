//
//  PSAppDelegate.m
//  PSNetAtmo
//
//  Created by Philip Schneider on 23.11.13.
//  Copyright (c) 2013 phschneider.net. All rights reserved.
//


#import "PSAppDelegate.h"

#import "PSMapAtmoAppVersion.h"
#import "PSMapAtmoMapViewController.h"
#import "PSMapAtmoNavigationController.h"


#import "iRate.h"

#import "PSMapAtmoMapAnalytics.h"
#import "PSMapAtmoUserDefaults.h"
#import "PSMapAtmoRatingDelegate.h"
#import "PSMapAtmoLocation.h"
#import "PSMapAtmoPublicCookie.h"

#ifdef CONFIGURATION_AppStore
    #import <Crashlytics/Crashlytics.h>
#else
    #import "TestFlight.h"
    #import "Fingertips/MBFingerTipWindow.h"
//      #import <LookBack/LookBack.h>
#endif


@implementation PSAppDelegate


- (void) notificationCatched:(NSNotification*)note
{

//    if ([PSNETATMO_NOTIFICATIONS containsObject:note.name])
//    {
//        NSLog(@" ======= %@ ======= ",note.name);
//        NSLog(@" ===> %@ ",note.userInfo);
//    }
}


+ (void)initialize
{
    DLogFuncName();
    [PSMapAtmoMapAnalytics sharedInstance];
    [PSMapAtmoRatingDelegate sharedInstance];
    [PSMapAtmoUserDefaults sharedInstance];
    [PSMapAtmoAppVersion sharedInstance];

    [[iRate sharedInstance] setDelegate:[PSMapAtmoRatingDelegate sharedInstance]];
    [[iRate sharedInstance] setAppStoreID:783111887];
    [[iRate sharedInstance] setUsesPerWeekForPrompt:5.0];
    [[iRate sharedInstance] setRemindPeriod:7];
    [[iRate sharedInstance] setDaysUntilPrompt:7];
    
    //    [[iVersion sharedInstance] setAppStoreID:783111887];
    //    [[iVersion sharedInstance] setGroupNotesByVersion:YES];
    //    [[iVersion sharedInstance] setCheckPeriod:3];
    //    [[iVersion sharedInstance] setCheckPeriod:3];
}


#pragma mark - AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    DLogFuncName();
    
//#ifdef DEBUG
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationCatched:) name:nil object:nil];
//#endif
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(managedObjectContextDidSave:)
//                                                 name:NSManagedObjectContextDidSaveNotification
//                                               object:self.backgroundManagedObjectContext];
    
    
    // iOS5 Warning - NO Social Framework
    // iOS5 Warning - NO Ad Framework

    //UIWebView in PSMapAtmoPublicCookie darf erst initialisiert werden, wenn die App da ist!
    [PSMapAtmoPublicCookie sharedInstance];

    UIViewController * rootViewController = nil;

        #ifdef CONFIGURATION_AppStore
            self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
            [Crashlytics startWithAPIKey:@"c13fd4d9aee54009fd4750058c84e02db744864d"];
        #endif
        
        #ifdef CONFIGURATION_Beta
             self.window = [[MBFingerTipWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//            [TestFlight setDeviceIdentifier:[[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString]];
            [TestFlight takeOff:@"a80cb978-8484-437b-ac86-7e6ca5a389e4"];
        
             //[LookBack setupWithAppToken:@"XZ3uBLwSsheXvux88"];
             //[LookBack lookback].shakeToRecord = YES;
        #endif

        #ifdef CONFIGURATION_Debug
            self.window = [[MBFingerTipWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//            [TestFlight setDeviceIdentifier:[[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString]];
            [TestFlight takeOff:@"6c75b978-51f3-404d-bc95-cabad88de7a5"];
        #endif

        self.window.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Midnight-1536x2048.jpg"]];
        rootViewController = [PSMapAtmoMapViewController sharedInstance];

    
    PSMapAtmoNavigationController * navController = [[PSMapAtmoNavigationController alloc] initWithRootViewController:rootViewController];
    self.window.rootViewController = navController;
    [self.window makeKeyAndVisible];

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    DLogFuncName();
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.


    PSMapAtmoLocation *location = [[PSMapAtmoUserDefaults sharedInstance] location];
    NSLog(@"Updating last Location %@", location);

    if(location.locationType == PSMapAtmoLocationTypeLastLocation)
    {
        [[PSMapAtmoMapAnalytics sharedInstance] trackEventUpdateLastLocation];
        location.region = [[PSMapAtmoMapViewController sharedInstance] currentRegion];
        NSLog(@"Updating last Location %@", location);
        [[PSMapAtmoUserDefaults sharedInstance] setLocation:location];
    }
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    DLogFuncName();
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    DLogFuncName();
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.

}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    DLogFuncName();
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    [[iRate sharedInstance] logEvent:YES];
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    DLogFuncName();
}

#pragma mark - Application's Documents directory

@end