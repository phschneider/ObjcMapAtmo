//
// Created by Philip Schneider on 02.01.14.
// Copyright (c) 2014 phschneider.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSMapAtmoAnalytics.h"


#define PSMAPATMOMAPANALYTICS_TRACK_METHOD  [[PSMapAtmoMapAnalytics sharedInstance] sendEventWithCategory:NSStringFromClass([self class]) withAction:NSStringFromSelector(_cmd) withLabel:@"" withValue:@1]

@interface PSMapAtmoMapAnalytics : PSMapAtmoAnalytics

+ (PSMapAtmoMapAnalytics*) sharedInstance;

- (void)sendEventWithCategory:(NSString *)category withAction:(NSString *)action withLabel:(NSString *)label withValue:(NSNumber *)value;

- (void)sendTimingWithCategory:(NSString *)category withValue:(NSTimeInterval)time1 withName:(NSString *)name withLabel:(NSString *)label;

- (void)sendView:(NSString *)screen;

- (void)trackView:(NSString*)view;

- (void)trackPinCallOut;

- (void)trackPinCallOutWithUnitInFahrenheit;

- (void)trackPinCallOutWithUnitInCelsius;

- (void)trackPinCallOutWithDistance;

- (void)trackPinCallOutWithDistanceInMiles;

- (void)trackMapSize:(float)qm;
- (void)trackMapZoomLevel:(float)zoomLevel;

- (void)trackPinCallOutWithDistanceInKilometers;

- (void)trackPinDistance:(NSString *)distance1;

- (void)trackApiCall;
- (void)trackNumberOfApiCallsForAppSession:(int)numberOfApiCalls;

- (void)trackMapRenderTimer:(NSTimeInterval)renderTime;
- (void)trackMapRenderTimer:(NSTimeInterval)renderTime forMapSize:(float)size;
- (void)trackMapRenderTimer:(NSTimeInterval)renderTime forZoomLevel:(float)zoomLevel;

- (void)trackEventLocateOff;
- (void)trackEventLocateOn;

- (void)trackEventSystemUnitsCelsius;

- (void)trackEventSystemUnitsMiles;

- (void)trackEventSystemUnitsFahrenheit;

- (void)trackEventSystemUnitsKilometers;

- (void)trackEventSystemFilterUseFilter;

- (void)trackEventSystemFilterIgnoreFilter;

- (void)trackEventSettingsTellAFriendSend;

- (void)trackEventSettingsTellAFriendCancelled;

- (void)trackEventAlertFilterCancel;

- (void)trackEventSettingsTellAFriendSaved;

- (void)trackEventSettingsTellAFriendFailed;

- (void)trackEventAlertFilterOnAndClearMap;

- (void)trackEventAlertFilterOnIgnoreMap;

- (void)trackEventSystemMapChange;

- (void)trackEventSystemMapStandard;

- (void)trackEventSystemMapSatellite;

- (void)trackEventSystemMapHybrid;

- (void)trackEventSystemLocationChange;

- (void)trackEventSystemLocationDefault;

- (void)trackEventSystemLocationUserLocation;

- (void)trackEventSystemLocationCurrentLocation;

- (void)trackEventSystemLocationLastLocation;

- (void)trackEventEnteredFullScreen;

- (void)trackEventLeavedFullScreen;

- (void)trackEventFullScreenShowEdges;

- (void)trackOverallCountAfter60Seconds:(int)overallCount;
- (void)trackVisibleCounterAfter60Seconds:(int)visibleCount;

- (void)trackOverallCount:(int)overallCount;
- (void)trackVisibleCount:(int)visibleCount;

- (void)trackEventMapDelegateFailedToLocateUser;

- (void)trackEventMapDelegateLocationServicesDisabled;

- (void)trackEventMapDelegateLocationStatusRestricted;

- (void)trackEventMapDelegateLocationStatusDenied;

- (void)trackEventMapDelegateLocationStatusUnknown;

- (void)trackEventMapDelegateLocationStatusAuthorized;

- (void)trackEventUpdateLastLocation;

- (void)trackEventCookieMissed;
- (void)trackEventCookieInvalid;
- (void)trackEventCookieRequested;
- (void)trackEventCookieReceived;
- (void)trackEventSystemFilterChange;

- (void)trackEventSystemFilterUseDefaultFilter;

- (void)trackEventSystemFilterUseCustomFilter;

- (void)trackEventSystemFilterUseCustomFilterWithValue:(NSNumber *)number;
@end