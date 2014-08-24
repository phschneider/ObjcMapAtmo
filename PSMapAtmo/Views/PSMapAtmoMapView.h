//
//  PSNetAtmoMapView.h
//  PSNetAtmo
//
//  Created by Philip Schneider on 14.12.13.
//  Copyright (c) 2013 phschneider.net. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "PSMapAtmoMapViewDataSource.h"

@interface PSMapAtmoMapView : MKMapView <UIScrollViewDelegate>

@property (nonatomic) id<PSMapAtmoMapViewDataSource> dataSource;
@property (nonatomic) BOOL startRendering;
@property (nonatomic) BOOL finishedRendering;
@property (nonatomic) MKUserLocation *lastUserLocation;

- (float)zoomLevel;
- (float)mapSize;

- (void)debugRenderingStatus;
- (BOOL)isFullyRendered;

@end
