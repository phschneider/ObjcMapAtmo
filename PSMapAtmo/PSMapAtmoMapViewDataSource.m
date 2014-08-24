//
// Created by Philip Schneider on 02.01.14.
// Copyright (c) 2014 phschneider.net. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "PSMapAtmoPublicApi.h"
#import "PSMapAtmoMapViewDataSource.h"
#import "PSMapAtmoPublicDeviceDict.h"
#import "PSMapAtmoNotifications.h"
#import "PSMapAtmoMapAnalytics.h"

@implementation PSMapAtmoMapViewDataSource

- (id)init
{
    DLogFuncName();
    self = [super init];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMap:) name:PSMAPATMO_PUBLIC_MEASURES_UPDATE_NOTIFICATION object:nil];
    }
    return self;
}


#pragma mark - Helper
- (void) updateMap:(NSNotification*)notification
{
    DLogFuncName();
    if ([NSThread isMainThread])
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^
        {
            [self updateMap:notification];
        });
        return;
    }

    NSDictionary * dict = notification.userInfo;
    
    for (NSDictionary * subDict in [dict objectForKey:PSMAPATMO_PUBLIC_MEASURES_UPDATE_NOTIFICATION_USERINFO_KEY])
    {
        [PSMapAtmoPublicDeviceDict createDeviceWithDict:subDict];
    }
}


#pragma mark - DataSource
- (void) meassuresForMapView:(MKMapView *)mapView
{
    DLogFuncName();
    CGPoint nePoint = CGPointMake(mapView.bounds.origin.x + mapView.bounds.size.width, mapView.bounds.origin.y);
    CGPoint swPoint = CGPointMake((mapView.bounds.origin.x), (mapView.bounds.origin.y + mapView.bounds.size.height));

    //Then transform those point into lat,lng values
    CLLocationCoordinate2D neCoord = [mapView convertPoint:nePoint toCoordinateFromView:mapView];
    CLLocationCoordinate2D swCoord = [mapView convertPoint:swPoint toCoordinateFromView:mapView];

    DLog(@"nePoint = %@", NSStringFromCGPoint(nePoint));
    DLog(@"swPoint = %@", NSStringFromCGPoint(swPoint));
    DLog(@"neCoord = %f %f", neCoord.latitude, neCoord.longitude);
    DLog(@"swCoord = %f %f", swCoord.latitude, swCoord.longitude);

    if (API_ENABLED)
    {
        [[PSMapAtmoPublicApi sharedInstance] meassuresForSw:neCoord andNe:swCoord];
    }
    else
    {
        [self updateMap:[[NSNotification alloc] initWithName: PSMAPATMO_PUBLIC_MEASURES_UPDATE_NOTIFICATION object:nil userInfo:nil]];
    }
}



@end