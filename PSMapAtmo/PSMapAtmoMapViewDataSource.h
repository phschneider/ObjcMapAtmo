//
// Created by Philip Schneider on 02.01.14.
// Copyright (c) 2014 phschneider.net. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PSMapAtmoMapViewDataSource
- (void) meassuresForMapView:(MKMapView *)mapView;
@end

@interface PSMapAtmoMapViewDataSource : NSObject <PSMapAtmoMapViewDataSource>

@end