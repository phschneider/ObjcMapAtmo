//
//  PSNetAtmoPublicDeviceDict.h
//  PSNetAtmo
//
//  Created by Philip Schneider on 14.12.13.
//  Copyright (c) 2013 phschneider.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

// Speicher-Klasse für alle öffentlichen NetAtmo-Stationen
@interface PSMapAtmoPublicDeviceDict : NSObject <MKAnnotation>

@property (nonatomic) CLLocation * userLocation; // für distanz-berechnung

+ (void) createDeviceWithDict:(NSDictionary*)dict;

- (NSString*) deviceID;

- (CLLocationCoordinate2D)coordinate;

- (NSString *)displayTitle;
@end
