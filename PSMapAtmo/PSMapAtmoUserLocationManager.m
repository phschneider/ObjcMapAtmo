//
//  PSMapAtmoUserLocationManager.m
//  MapAtmo
//
//  Created by Philip Schneider on 18.04.14.
//  Copyright (c) 2014 phschneider.net. All rights reserved.
//

#import "PSMapAtmoUserLocationManager.h"

@implementation
PSMapAtmoUserLocationManager

static PSMapAtmoUserLocationManager * instance = nil;
+ (PSMapAtmoUserLocationManager *) sharedInstance {
    @synchronized (self)
    {
        if (instance == nil)
        {
            [PSMapAtmoUserLocationManager new];
        }
    }
    return instance;
}


- (id)init
{
    NSAssert(!instance,@"We already have an instance of PSMapAtmoUserLocationManager");
    DLogFuncName();
    self = [super init];
    if (self)
    {
    
    }
    instance = self;
    return self;
}

//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationTrackingDenied:) name:PSMAPATMO_PUBLIC_MAP_ERROR_LOCATION_AUTH_DENIED object:nil];
//PSMAPATMO_PUBLIC_MAP_ERROR_LOCATION_SERVICES_NOT_ENABLED
//PSMAPATMO_PUBLIC_MAP_ERROR_LOCATION_AUTH_RESTRICTED
//PSMAPATMO_PUBLIC_MAP_ERROR_LOCATION_AUTH_DENIED
//PSMAPATMO_PUBLIC_MAP_ERROR_LOCATION_UNKNOWN_ERROR
//- (UIImage*)toolBarLocateItemImage
//{
//    DLogFuncName();
//    return nil;
//}


// Funktion - Track User
// Funktion - Stop Tracking User

// Funktion - Tracking Status






@end
