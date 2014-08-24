//
//  PSNetAtmoApi.h
//  PSNetAtmo
//
//  Created by Philip Schneider on 08.12.13.
//  Copyright (c) 2013 phschneider.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface PSMapAtmoApi : NSObject

+ (void) publicMeassuresForSw:(CLLocationCoordinate2D)sw andNe:(CLLocationCoordinate2D)ne;

//+ (PSNetAtmoDeviceDB *) devices;
//+ (PSNetAtmoMeasureDB *) measureForDevice:(NSString*)deviceID;
//+ (PSNetAtmoMeasureDB *) measureForDevice:(NSString*)deviceID andModule:(NSString*)module;

+ (void) devices;
+ (void) measureForDevice:(NSString*)deviceID;

@end
