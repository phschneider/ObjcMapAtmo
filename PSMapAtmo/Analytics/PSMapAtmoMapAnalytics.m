//
// Created by Philip Schneider on 02.01.14.
// Copyright (c) 2014 phschneider.net. All rights reserved.
//

#import "PSMapAtmoAnalytics.h"
#import "PSMapAtmoMapAnalytics.h"

#ifndef CONFIGURATION_AppStore
    #import "TestFlight.h"
#endif

@implementation PSMapAtmoMapAnalytics

static PSMapAtmoMapAnalytics* instance = nil;

+ (PSMapAtmoMapAnalytics*) sharedInstance {
    @synchronized (self)
    {
        if (instance == nil)
        {
            [PSMapAtmoMapAnalytics new];
        }
    }
    return instance;
}


- (id)init
{
    DLogFuncName();
    NSAssert(!instance, @"Instance of PSMapAtmoMapAnalytics already exists");
    self = [super init];
    if (self)
    {
        
//#ifdef TARGET_IPHONE_SIMULATOR
//    NSLog(@"#ifdef TARGET_IPHONE_SIMULATOR");
//#else
//    NSLog(@"#else #ifdef TARGET_IPHONE_SIMULATOR");
//#endif
//        
//        
//#if (TARGET_IPHONE_SIMULATOR)
//     NSLog(@"#if (TARGET_IPHONE_SIMULATOR)");
//#else
//     NSLog(@"#else #if (TARGET_IPHONE_SIMULATOR)");
//#endif
//        
//#if (TARGET_OS_IPHONE)
//     NSLog(@"#if (TARGET_OS_IPHONE)");
//#else
//     NSLog(@"#else #if (TARGET_OS_IPHONE)");
//#endif
        #if (TARGET_IPHONE_SIMULATOR)
            NSLog(@"Not tracking in simulator");
        #else
            #ifdef CONFIGURATION_AppStore
                // Get a new tracker.
                id newTracker = [[GAI sharedInstance]trackerWithTrackingId:@"UA-46480837-1"];
                [GAI sharedInstance].defaultTracker = newTracker;
                [[GAI sharedInstance].defaultTracker sendView:@"map"];
                [[GAI sharedInstance].defaultTracker setAnonymize:YES];
            #endif

            #ifdef CONFIGURATION_Beta
                // Get a new tracker.
                id newTracker = [[GAI sharedInstance]trackerWithTrackingId:@"UA-46480837-3"];
                [GAI sharedInstance].defaultTracker = newTracker;
                [[GAI sharedInstance].defaultTracker sendView:@"map"];
                [[GAI sharedInstance].defaultTracker setAnonymize:YES];
            #endif
        #endif
        [self trackDevice];
        [self trackDeviceOrientation];
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


- (void)sendTimingWithCategory:(NSString *)category withValue:(NSTimeInterval)time withName:(NSString *)name withLabel:(NSString *)label
{
    DLogFuncName();

#ifndef CONFIGURATION_AppStore
    NSString * checkPointString = [NSString stringWithFormat:@"TIMING >> Category=%@ Value=%f Name=%@ Label=%@",category,time,name,label];
    DLog(@"CheckPointString => %@");
    [TestFlight passCheckpoint:checkPointString];
#endif


    [[GAI sharedInstance].defaultTracker  sendTimingWithCategory:category
                                                       withValue:time
                                                        withName:name
                                                       withLabel:label];
    
}


- (void)sendView:(NSString *)screen
{
    DLogFuncName();

#ifndef CONFIGURATION_AppStore
    NSString * checkPointString = [NSString stringWithFormat:@"VIEW >> %@",screen];
    DLog(@"CheckPointString => %@");
    [TestFlight passCheckpoint:checkPointString];
#endif

    [[GAI sharedInstance].defaultTracker  sendView:screen];
}


#pragma mark - Analytics
- (void)trackView:(NSString*)view
{
    DLogFuncName();
    [self sendView:view];
}


- (void)trackPinCallOut
{
    DLogFuncName();
    [self sendEventWithCategory:@"user-interaction"
                     withAction:@"pin"
                      withLabel:@"callout"
                      withValue:@1];
}


- (void)trackPinCallOutWithUnitInFahrenheit
{
    DLogFuncName();
    [self sendEventWithCategory:@"user-interaction"
                     withAction:@"pin"
                      withLabel:@"calloutWithUnitInFahrenheit"
                      withValue:@1];
}


- (void)trackPinCallOutWithUnitInCelsius
{
    DLogFuncName();
    [self sendEventWithCategory:@"user-interaction"
                     withAction:@"pin"
                      withLabel:@"calloutWithUnitInCelsius"
                      withValue:@1];
}


- (void)trackPinCallOutWithDistance
{
    DLogFuncName();
    [self sendEventWithCategory:@"user-interaction"
                     withAction:@"pin"
                      withLabel:@"calloutWithDistance"
                      withValue:@1];
}


- (void)trackPinCallOutWithDistanceInMiles
{
    DLogFuncName();
    [self sendEventWithCategory:@"user-interaction"
                     withAction:@"pin"
                      withLabel:@"calloutWithDistanceInMiles"
                      withValue:@1];
}


- (void)trackPinCallOutWithDistanceInKilometers
{
    DLogFuncName();
    [self sendEventWithCategory:@"user-interaction"
                     withAction:@"pin"
                      withLabel:@"calloutWithDistanceInKilometers"
                      withValue:@1];
}


- (void)trackPinDistance:(NSString*)distance
{
    DLogFuncName();
    [self sendEventWithCategory:@"user-interaction"
                     withAction:@"pin-distance"
                      withLabel:distance
                      withValue:@1];
}


- (void)trackApiCall
{
    DLogFuncName();
    [self sendEventWithCategory:@"api"
                     withAction:@"request"
                      withLabel:@"any"
                      withValue:@1];
}


- (void)trackMapSize:(float)qm
{
    DLogFuncName();
    [self sendEventWithCategory:@"map"
                     withAction:@"sizeInkm²"
                      withLabel:[NSString stringWithFormat:@"%.2fkm²", qm]
                      withValue:@1];
}


- (void)trackMapZoomLevel:(float)zoomLevel
{
    DLogFuncName();
    [self sendEventWithCategory:@"map"
                     withAction:@"zoomLevel"
                      withLabel:[NSString stringWithFormat:@"%.2f", zoomLevel]
                      withValue:@1];
}


- (void)trackNumberOfApiCallsForAppSession:(int)numberOfApiCalls
{
    DLogFuncName();
    [self sendEventWithCategory:@"api"
                     withAction:@"request"
                      withLabel:@"forAppSession"
                      withValue:@(numberOfApiCalls)];
}


- (void)trackMapRenderTimer:(NSTimeInterval)renderTime
{
    DLogFuncName();
    [self sendTimingWithCategory:@"map"
                                                       withValue:renderTime
                                                        withName:@"renderingTime"
                                                       withLabel:@"tilFinished"];
}


- (void)trackMapRenderTimer:(NSTimeInterval)renderTime forMapSize:(float)size
{
    DLogFuncName();
    [self sendTimingWithCategory:@"map"
                                                       withValue:renderTime
                                                        withName:@"renderingTimeForSize"
                                                       withLabel:[NSString stringWithFormat:@"%.2f",size]];
}


- (void)trackMapRenderTimer:(NSTimeInterval)renderTime forZoomLevel:(float)zoomLevel
{
    DLogFuncName();
    [self sendTimingWithCategory:@"map"
                                                       withValue:renderTime
                                                        withName:@"renderingTimeForZoomLevel"
                                                       withLabel:[NSString stringWithFormat:@"%.2f",zoomLevel]];
}


#pragma mark - Events
- (void)trackEventLocateOff
{
    DLogFuncName();

    [self sendEventWithCategory:@"user-interaction"
                     withAction:@"locate"
                      withLabel:@"off"
                      withValue:@1];
}


- (void)trackEventLocateOn
{
    DLogFuncName();

    [self sendEventWithCategory:@"user-interaction"
                     withAction:@"locate"
                      withLabel:@"on"
                      withValue:@1];
}


- (void)trackEventShowWarning
{
    DLogFuncName();
    [self sendEventWithCategory:@"system"
                     withAction:@"warning"
                      withLabel:@"limit"
                      withValue:@1];
}


- (void)trackEventSettingsTellAFriendSend
{
    DLogFuncName();
    [self sendEventWithCategory:@"settings"
                     withAction:@"tellAFriend"
                      withLabel:@"send"
                      withValue:@1];
}


- (void)trackEventSettingsTellAFriendCancelled
{
    DLogFuncName();
    [self sendEventWithCategory:@"settings"
                     withAction:@"tellAFriend"
                      withLabel:@"cancelled"
                      withValue:@1];
}


- (void)trackEventSettingsTellAFriendSaved
{
    DLogFuncName();
    [self sendEventWithCategory:@"settings"
                     withAction:@"tellAFriend"
                      withLabel:@"saved"
                      withValue:@1];
}


- (void)trackEventSettingsTellAFriendFailed
{
    DLogFuncName();
    [self sendEventWithCategory:@"settings"
                     withAction:@"tellAFriend"
                      withLabel:@"failed"
                      withValue:@1];
}

- (void)trackEventSystemUnitsFahrenheit
{
    DLogFuncName();
    [self sendEventWithCategory:@"settings"
                     withAction:@"units"
                      withLabel:@"fahrenheit"
                      withValue:@1];
}


- (void)trackEventSystemUnitsCelsius
{
    DLogFuncName();
    [self sendEventWithCategory:@"settings"
                     withAction:@"units"
                      withLabel:@"celsius"
                      withValue:@1];
}


- (void)trackEventSystemUnitsMiles
{
    DLogFuncName();
    [self sendEventWithCategory:@"settings"
                     withAction:@"units"
                      withLabel:@"miles"
                      withValue:@1];
}


- (void)trackEventSystemUnitsKilometers
{
    DLogFuncName();
    [self sendEventWithCategory:@"settings"
                     withAction:@"units"
                      withLabel:@"kilometers"
                      withValue:@1];
}


- (void)trackEventSystemFilterUseFilter
{
    DLogFuncName();
    [self sendEventWithCategory:@"settings"
                     withAction:@"filter"
                      withLabel:@"on"
                      withValue:@1];
}


- (void)trackEventSystemFilterIgnoreFilter
{
    DLogFuncName();
    [self sendEventWithCategory:@"settings"
                     withAction:@"filter"
                      withLabel:@"off"
                      withValue:@1];
}


- (void)trackEventAlertFilterCancel
{
    DLogFuncName();
    [self sendEventWithCategory:@"alert"
                     withAction:@"filter"
                      withLabel:@"cancel"
                      withValue:@1];
}


- (void)trackEventAlertFilterOnAndClearMap
{
    DLogFuncName();
    [self sendEventWithCategory:@"alert"
                     withAction:@"filter"
                      withLabel:@"onAndClearMap"
                      withValue:@1];
}


- (void)trackEventAlertFilterOnIgnoreMap
{
    DLogFuncName();
    [self sendEventWithCategory:@"alert"
                     withAction:@"filter"
                      withLabel:@"onAndIgnoreMap"
                      withValue:@1];
}


- (void)trackEventSystemFilterChange
{
    DLogFuncName();
    [self sendEventWithCategory:@"settings"
                     withAction:@"filter"
                      withLabel:@"change"
                      withValue:@1];
}


- (void)trackEventSystemFilterUseDefaultFilter
{
    DLogFuncName();
    [self sendEventWithCategory:@"settings"
                     withAction:@"filter"
                      withLabel:@"default"
                      withValue:@1];
}


- (void)trackEventSystemFilterUseCustomFilter
{
    DLogFuncName();
    [self sendEventWithCategory:@"settings"
                     withAction:@"filter"
                      withLabel:@"custom"
                      withValue:@1];
}


- (void)trackEventSystemFilterUseCustomFilterWithValue:(NSNumber *)number
{
    DLogFuncName();
    [self sendEventWithCategory:@"settings"
                     withAction:@"filter"
                      withLabel:[NSString stringWithFormat:@"custom-%d", [number intValue]]
                      withValue:@1];
}


- (void)trackEventSystemMapChange
{
    DLogFuncName();
    [self sendEventWithCategory:@"settings"
                     withAction:@"map"
                      withLabel:@"change"
                      withValue:@1];
}


- (void)trackEventSystemMapStandard
{
    DLogFuncName();
    [self sendEventWithCategory:@"settings"
                     withAction:@"map"
                      withLabel:@"standard"
                      withValue:@1];
}


- (void)trackEventSystemMapSatellite
{
    DLogFuncName();
    [self sendEventWithCategory:@"settings"
                     withAction:@"map"
                      withLabel:@"satellite"
                      withValue:@1];
}


- (void)trackEventSystemMapHybrid
{
    DLogFuncName();
    [self sendEventWithCategory:@"settings"
                     withAction:@"map"
                      withLabel:@"hybrid"
                      withValue:@1];
}


- (void)trackEventSystemLocationChange
{
    DLogFuncName();
    [self sendEventWithCategory:@"settings"
                     withAction:@"location"
                      withLabel:@"change"
                      withValue:@1];
}


- (void)trackEventSystemLocationDefault
{
    DLogFuncName();
    [self sendEventWithCategory:@"settings"
                     withAction:@"location"
                      withLabel:@"default"
                      withValue:@1];
}


- (void)trackEventSystemLocationUserLocation
{
    DLogFuncName();
    [self sendEventWithCategory:@"settings"
                     withAction:@"location"
                      withLabel:@"userLocation"
                      withValue:@1];
}


- (void)trackEventSystemLocationCurrentLocation
{
    DLogFuncName();
    [self sendEventWithCategory:@"settings"
                     withAction:@"location"
                      withLabel:@"currentLocation"
                      withValue:@1];
}


- (void)trackEventSystemLocationLastLocation
{
    DLogFuncName();
    [self sendEventWithCategory:@"settings"
                     withAction:@"location"
                      withLabel:@"lastLocation"
                      withValue:@1];
}


- (void)trackEventEnteredFullScreen
{
    DLogFuncName();

    [self sendEventWithCategory:@"map"
                     withAction:@"fullScreen"
                      withLabel:@"enterFullScreen"
                      withValue:@1];
}


- (void)trackEventLeavedFullScreen
{
    DLogFuncName();

    [self sendEventWithCategory:@"map"
                     withAction:@"fullScreen"
                      withLabel:@"leaveFullScreen"
                      withValue:@1];
}


- (void)trackEventFullScreenShowEdges
{
    DLogFuncName();
    [self sendEventWithCategory:@"map"
                     withAction:@"fullScreen"
                      withLabel:@"showEdges"
                      withValue:@1];
}


#pragma mark - Counts
- (void)trackOverallCountAfter60Seconds:(int)overallCount
{
    DLogFuncName();
    [self sendEventWithCategory:@"system"
                     withAction:@"overallCount"
                      withLabel:@"overallCountAfter60Seconds"
                      withValue:@(overallCount)];
}

- (void)trackVisibleCounterAfter60Seconds:(int)visibleCount
{
    DLogFuncName();
    [self sendEventWithCategory:@"system"
                     withAction:@"visibleCount"
                      withLabel:@"visibleCountAfter60Seconds"
                      withValue:@(visibleCount)];
}

- (void)trackOverallCount:(int)overallCount
{
    return;
    
//    self.lastCheck = [[NSDate date] timeIntervalSince1970];

    if(overallCount > 10000)
    {
        [self sendEventWithCategory:@"system"
                         withAction:@"overallCount"
                          withLabel:@">10000"
                          withValue:@1];
    }
    else if(overallCount > 9000)
    {
        [self sendEventWithCategory:@"system"
                         withAction:@"overallCount"
                          withLabel:@">9000"
                          withValue:@1];
    }
    else if(overallCount > 8000)
    {
        [self sendEventWithCategory:@"system"
                         withAction:@"overallCount"
                          withLabel:@">8000"
                          withValue:@1];
    }
    else if(overallCount > 7000)
    {
        [self sendEventWithCategory:@"system"
                         withAction:@"overallCount"
                          withLabel:@">7000"
                          withValue:@1];
    }
    else if(overallCount > 6000)
    {
        [self sendEventWithCategory:@"system"
                         withAction:@"overallCount"
                          withLabel:@">6000"
                          withValue:@1];
    }
    else if(overallCount > 5000)
    {
        [self sendEventWithCategory:@"system"
                         withAction:@"overallCount"
                          withLabel:@">5000"
                          withValue:@1];
    }
    else if(overallCount > 4000)
    {
        [self sendEventWithCategory:@"system"
                         withAction:@"overallCount"
                          withLabel:@">4000"
                          withValue:@1];
    }
    else if(overallCount > 3000)
    {
        [self sendEventWithCategory:@"system"
                         withAction:@"overallCount"
                          withLabel:@">3000"
                          withValue:@1];
    }
    else if(overallCount > 2000)
    {
        [self sendEventWithCategory:@"system"
                         withAction:@"overallCount"
                          withLabel:@">2000"
                          withValue:@1];
    }
    else if(overallCount > 1500)
    {
        [self sendEventWithCategory:@"system"
                         withAction:@"overallCount"
                          withLabel:@">1500"
                          withValue:@1];
    }
    else if(overallCount > 1000)
    {
        [self sendEventWithCategory:@"system"
                         withAction:@"overallCount"
                          withLabel:@">1000"
                          withValue:@1];
    }
    else if(overallCount > 500)
    {
        [self sendEventWithCategory:@"system"
                         withAction:@"overallCount"
                          withLabel:@">500"
                          withValue:@1];
    }
    else if(overallCount > 100)
    {
        [self sendEventWithCategory:@"system"
                         withAction:@"overallCount"
                          withLabel:@">100"
                          withValue:@1];
    }
    else if(overallCount > 50)
    {
        [self sendEventWithCategory:@"system"
                         withAction:@"overallCount"
                          withLabel:@">50"
                          withValue:@1];
    }
    else if(overallCount > 10)
    {
        [self sendEventWithCategory:@"system"
                         withAction:@"overallCount"
                          withLabel:@">10"
                          withValue:@1];
    }
}


- (void)trackVisibleCount:(int)visibleCount
{
    if(visibleCount > 2000)
    {
        [self sendEventWithCategory:@"system"
                         withAction:@"visiblecount"
                          withLabel:@">2000"
                          withValue:@1];
    }
    else if(visibleCount > 1500)
    {
        [self sendEventWithCategory:@"system"
                         withAction:@"visiblecount"
                          withLabel:@">1500"
                          withValue:@1];
    }
    else if(visibleCount > 1000)
    {
        [self sendEventWithCategory:@"system"
                         withAction:@"visiblecount"
                          withLabel:@">1000"
                          withValue:@1];
    }
    else if(visibleCount > 500)
    {
        [self sendEventWithCategory:@"system"
                         withAction:@"visiblecount"
                          withLabel:@">500"
                          withValue:@1];
    }
    else if(visibleCount > 100)
    {
        [self sendEventWithCategory:@"system"
                         withAction:@"visiblecount"
                          withLabel:@">100"
                          withValue:@1];
    }
    else if(visibleCount > 50)
    {
        [self sendEventWithCategory:@"system"
                         withAction:@"visiblecount"
                          withLabel:@">50"
                          withValue:@1];
    }
    else if(visibleCount > 10)
    {
        [self sendEventWithCategory:@"system"
                         withAction:@"visiblecount"
                          withLabel:@">10"
                          withValue:@1];
    }
}


- (void)trackEventMapDelegateFailedToLocateUser
{
    DLogFuncName();

    [self sendEventWithCategory:@"failure"
                     withAction:@"mapviewdelegate"
                      withLabel:@"didFailToLocateUser"
                      withValue:@1];
}


- (void)trackEventMapDelegateLocationServicesDisabled
{
    DLogFuncName();

    [self sendEventWithCategory:@"failure"
                     withAction:@"mapviewdelegate"
                      withLabel:@"locationServicesDisabled"
                      withValue:@1];
}


- (void)trackEventMapDelegateLocationStatusRestricted
{
    DLogFuncName();

    [self sendEventWithCategory:@"failure"
                     withAction:@"mapviewdelegate"
                      withLabel:@"locationStatusRestricted"
                      withValue:@1];
}


- (void)trackEventMapDelegateLocationStatusDenied
{
    DLogFuncName();

    [self sendEventWithCategory:@"failure"
                     withAction:@"mapviewdelegate"
                      withLabel:@"locationStatusDenied"
                      withValue:@1];
}


- (void)trackEventMapDelegateLocationStatusUnknown
{
    DLogFuncName();

    [self sendEventWithCategory:@"failure"
                     withAction:@"mapviewdelegate"
                      withLabel:@"locationStatusUnknown"
                      withValue:@1];
}


- (void)trackEventMapDelegateLocationStatusAuthorized
{
    DLogFuncName();

    [self sendEventWithCategory:@"failure"
                     withAction:@"mapviewdelegate"
                      withLabel:@"locationStatusAuthorized"
                      withValue:@1];
}


- (void)trackEventUpdateLastLocation
{
    DLogFuncName();

    [self sendEventWithCategory:@"PSMapAtmoLocation"
                     withAction:@"updateLastLocation"
                      withLabel:@""
                      withValue:@1];
}
@end