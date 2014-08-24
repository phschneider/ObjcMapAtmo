
//
//  PSNetAtmoAnalytics.m
//  PSNetAtmo
//
//  Created by Philip Schneider on 02.01.14.
//  Copyright (c) 2014 phschneider.net. All rights reserved.
//

//#import <Analytics/Analytics.h>
#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import "UIDevice-Hardware.h"

#import "PSMapAtmoAnalytics.h"
#import "PSMapAtmoReachability.h"

#ifndef CONFIGURATION_AppStore
    #import "TestFlight.h"
#endif

@implementation PSMapAtmoAnalytics
static PSMapAtmoAnalytics* instance = nil;

+ (PSMapAtmoAnalytics*) sharedInstance {
    @synchronized (self)
    {
        if (instance == nil)
        {
            [PSMapAtmoAnalytics new];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(trackMemoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        }
    }
    return instance;
}


- (id) init
{
    DLogFuncName();
    NSAssert(!instance, @"Instance of PSMapAtmoAnalytics already exists");
    self = [super init];
    if (self)
    {
        #ifdef CONFIGURATION_AppStore
            [GAI sharedInstance].trackUncaughtExceptions = YES;
        #endif
        
        DLog(@"%@",[[UIDevice currentDevice] modelName]);
    }
    instance = self;
    return self;
}


#pragma mark - Helper
- (void)sendEventWithCategory:(NSString *)category withAction:(NSString *)action withLabel:(NSString *)label withValue:(NSNumber *)value
{
    DLogFuncName();
    
#ifndef CONFIGURATION_AppStore
    NSString * checkPointString = [NSString stringWithFormat:@"EVENT >> Category=%@ Action=%@ Label=%@ Value=%@",category,action,label,value];
    DLog(@"CheckPointString => %@");
    [TestFlight passCheckpoint:checkPointString];
#endif
    
    
    [[GAI sharedInstance].defaultTracker  sendEventWithCategory:category
                                                     withAction:action
                                                      withLabel:label
                                                      withValue:value];
}


#pragma mark - Device
- (void) trackDevice
{
    DLogFuncName();
    [self sendEventWithCategory:@"system"
                                                    withAction:@"device"
                                                     withLabel:[[UIDevice currentDevice] modelName]
                                                     withValue:nil];
}


- (void) trackDeviceOrientation
{
    DLogFuncName();
    
    [self sendEventWithCategory:@"system"
                                                    withAction:@"orientation"
                                                     withLabel:[self deviceOrientationAsString]
                                                     withValue:nil];
}


#pragma mark - On/Offline
// Wie oft ist der Benutzer Offline
- (void) trackConnectionOffline
{
    DLogFuncName();
    [self sendEventWithCategory:@"system"
                                                    withAction:@"connection"
                                                     withLabel:@"offline"
                                                     withValue:nil];
}


// Wie oft ist der Benutzer Online
- (void) trackConnectionOnline
{
    DLogFuncName();
    [self sendEventWithCategory:@"system"
                                                    withAction:@"connection"
                                                     withLabel:@"online"
                                                     withValue:nil];
}


// Welche ist die aktuelle Verbindung
- (void) trackConnection
{
    DLogFuncName();
    [self sendEventWithCategory:@"system"
                                                    withAction:@"connection"
                                                     withLabel:[[PSMapAtmoReachability sharedInstance] currentReachabilityAsString]
                                                     withValue:nil];
}


#pragma mark - Install/update
// Wenn App neu installiert wurde
- (void)trackBlankInstall
{
    DLogFuncName();
    [self sendEventWithCategory:@"system"
                                                    withAction:@"install"
                                                     withLabel:@"blank"
                                                     withValue:nil];
}


// Welches ist die Version die Neu installiert wurde
- (void)trackBlankInstallVersion:(NSString*)version
{
    DLogFuncName();
    [self sendEventWithCategory:@"system"
                                                    withAction:@"install"
                                                     withLabel:[NSString stringWithFormat:@"install-%@",version]
                                                     withValue:nil];
}


// Wenn App aktualisiert wurde
- (void)trackUpdateInstall
{
    DLogFuncName();
    [self sendEventWithCategory:@"system"
                                                    withAction:@"install"
                                                     withLabel:@"update"
                                                     withValue:nil];
}


// Welches ist die Version die Neu aktualisiert wurde
- (void)trackUpdateInstallVersion:(NSString*)version
{
    DLogFuncName();
    [self sendEventWithCategory:@"system"
                                                    withAction:@"install"
                                                     withLabel:[NSString stringWithFormat:@"update-%@",version]
                                                     withValue:nil];
}


// Von welcher Version wurde auf welche andere Version aktualisiert
- (void)trackUpdateInstallVersion:(NSString*)version fromVersion:(NSString*)fromVersion
{
    DLogFuncName();
    [self sendEventWithCategory:@"system"
                                                    withAction:@"install"
                                                     withLabel:[NSString stringWithFormat:@"update-%@=>%@",fromVersion,version]
                                                     withValue:nil];
}

#pragma mark - Memory Warning
+ (void)trackMemoryWarning
{
    DLogFuncName();
#ifndef CONFIGURATION_AppStore
    NSString * checkPointString = [NSString stringWithFormat:@"EVENT >> Category=%@ Action=%@ Label=%@ Value=%@",@"system",@"memoryWarning",@"memoryWarning",nil];
    DLog(@"CheckPointString => %@");
    [TestFlight passCheckpoint:checkPointString];
#endif
    
    
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:@"system"
                                                    withAction:@"memoryWarning"
                                                     withLabel:@"memoryWarning"
                                                     withValue:nil];
}

#pragma mark - Helper
-(NSString*)deviceOrientationAsString
{
    DLogFuncName();
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
    {
        return @"landscape";
    }
    else
    {
        return @"portrait";
    }
}

@end
