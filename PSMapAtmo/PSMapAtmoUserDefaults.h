//
// Created by Philip Schneider on 05.12.13.
// Copyright (c) 2013 phschneider.net. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class PSMapAtmoLocation;
@class PSMapAtmoFilter;


@interface PSMapAtmoUserDefaults : NSObject

+ (PSMapAtmoUserDefaults*) sharedInstance;

- (BOOL)useFahrenheit;

- (void)setUseFahrenheitAsTempUnit;

- (void)setUseCelsiusAsTempUnit;

- (BOOL)useMiles;

- (void)setUseMilesAsDistanceUnit;

- (void)setUseKilometersAsDistanceUnit;

- (PSMapAtmoFilter *)filter;

- (void)setFilter:(PSMapAtmoFilter *)filter;

- (BOOL)firstUseOfFullScreenMode;

- (void)setEnteringFullScreenMode;

- (void)setLeavingFullScreenMode;

- (MKMapType) mapType;
- (void) setMapType:(NSNumber*)mapType;

- (PSMapAtmoLocation *)location;

- (void)setLocation:(PSMapAtmoLocation *)location;

- (NSString *)betaName;

- (void)setBetaName:(NSString *)betaName;

- (NSString *)betaMail;

- (void)setBetaMail:(NSString *)betaMail;
@end
