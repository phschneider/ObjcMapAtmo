//
// Created by Philip Schneider on 24.02.14.
// Copyright (c) 2014 phschneider.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

typedef NS_ENUM(NSUInteger, PSMapAtmoLocationType) {
    PSMapAtmoLocationTypeDefault = 0,
    PSMapAtmoLocationTypeUserLocation,
    PSMapAtmoLocationTypeCurrentLocation, // current view on screen
    PSMapAtmoLocationTypeLastLocation     // open as leaved
};

@interface PSMapAtmoLocation : NSObject <NSCoding>

@property (nonatomic) PSMapAtmoLocationType locationType;
@property (nonatomic) MKCoordinateRegion region;

- (id)initWithLocationType:(PSMapAtmoLocationType)locationType;
- (id)initWithLocationType:(PSMapAtmoLocationType)locationType region:(MKCoordinateRegion)region;

+ (id)defaultLocation;
+ (id)userLocation;
+ (id)currentLocation;
+ (id)lastLocation;

@end