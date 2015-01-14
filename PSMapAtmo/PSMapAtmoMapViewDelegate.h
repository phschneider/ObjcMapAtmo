//
//  PSNetAtmoMapViewDelegate.h
//  PSNetAtmo
//
//  Created by Philip Schneider on 02.01.14.
//  Copyright (c) 2014 phschneider.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@protocol PSMapAtmoMapViewDelegate <MKMapViewDelegate>

- (void)mapView:(MKMapView*)mapView willEnable3D:(BOOL)enabled;
- (void)mapView:(MKMapView*)mapView zoomToUserLocation:(MKUserLocation*)userLocation;

- (BOOL)mapViewShowsUserLocationCentered:(MKMapView*)mapView;

@end


@interface PSMapAtmoMapViewDelegate : NSObject <PSMapAtmoMapViewDelegate>

- (BOOL)userIsDraggingMapView:(MKMapView*)mapView;

@end
