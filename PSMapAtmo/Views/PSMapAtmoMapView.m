//
//  PSMapAtmoMapView.m
//  PSMapAtmo
//
//  Created by Philip Schneider on 14.12.13.
//  Copyright (c) 2013 phschneider.net. All rights reserved.
//

#define MAX_ZOOM_LEVEL  0.1
#import "PSMapAtmoMapView.h"
#import "PSMapAtmoMapAnalytics.h"

@interface PSMapAtmoMapView()
@property (nonatomic) NSTimeInterval renderTime;
@end


@implementation PSMapAtmoMapView


- (float)mapSize
{
    DLogFuncName();
    MKMapPoint mpTopLeft = self.visibleMapRect.origin;
    
    MKMapPoint mpTopRight = MKMapPointMake(
                                           self.visibleMapRect.origin.x + self.visibleMapRect.size.width,
                                           self.visibleMapRect.origin.y);
    
    MKMapPoint mpBottomRight = MKMapPointMake(
                                              self.visibleMapRect.origin.x + self.visibleMapRect.size.width,
                                              self.visibleMapRect.origin.y + self.visibleMapRect.size.height);
    
    CLLocationDistance hDist = MKMetersBetweenMapPoints(mpTopLeft, mpTopRight);
    CLLocationDistance vDist = MKMetersBetweenMapPoints(mpTopRight, mpBottomRight);
    
    double vmrArea = (hDist * vDist) / 1000.0;
    double rounded  = vmrArea;
    if (vmrArea > 0){
        rounded = roundf (vmrArea * 10) / 10.0;
    }

    DLog(@"Size in QuadratKilometers = %f", vmrArea);
    return vmrArea;
}


#define MAXIMUM_ZOOM    18
- (float)zoomLevel
{
    DLogFuncName();
    
    MKZoomScale currentZoomScale = self.visibleMapRect.size.width / self.bounds.size.width;
    DLog(@"ZoomScale = %f", currentZoomScale);
    
    float zoomLevel = MAXIMUM_ZOOM; // MAXIMUM_ZOOM is 20 with MapKit
    float zoomExponent = log2(currentZoomScale);
    zoomLevel = (MAXIMUM_ZOOM - zoomExponent);
    DLog(@"ZoomLevel = %f", zoomLevel);

    return zoomLevel;
}
#undef MAXIMUM_ZOOM


- (void)setStartRendering:(BOOL)startRendering
{
    _startRendering = startRendering;
    if (_startRendering)
    {
        self.renderTime = CFAbsoluteTimeGetCurrent();
    }
    
    // Setzt isFullyRendered ...
    if (self.finishedRendering && !startRendering)
    {
        NSTimeInterval timeForRendering = CFAbsoluteTimeGetCurrent() - self.renderTime;
        [self mapSize];
        [self zoomLevel];
        
        DLog(@"RenderTimer = %f ForMapRect = %@", timeForRendering, MKStringFromMapRect(self.visibleMapRect));
        
        [[PSMapAtmoMapAnalytics sharedInstance] trackMapRenderTimer:timeForRendering];
        [[PSMapAtmoMapAnalytics sharedInstance] trackMapRenderTimer:timeForRendering forMapSize:[self mapSize]];
        [[PSMapAtmoMapAnalytics sharedInstance] trackMapRenderTimer:timeForRendering forZoomLevel:[self zoomLevel]];
    }
}


- (void) debugRenderingStatus
{
    DLogFuncName();
    DLog(@"MapView isFullyRenderes = %@, startRendering = %@ , finishedRendering = %@",  ([self isFullyRendered]) ? @"YES" : @"NO", (self.startRendering) ? @"YES" : @"NO", (self.finishedRendering) ? @"YES" : @"NO");
}


- (BOOL) isFullyRendered
{
    DLogFuncName();
    BOOL isFullyRendered = (self.finishedRendering && !self.startRendering);
    
    DLog(@"iMapView isFullyRenderes = %@ , startRendering = %@ , finishedRendering = %@", (isFullyRendered) ? @"YES" : @"NO", (self.startRendering) ? @"YES" : @"NO", (self.finishedRendering) ? @"YES" : @"NO");
    
    return isFullyRendered;
}

@end
