//
//  PSMapAtmoUserLocationManager.h
//  MapAtmo
//
//  Created by Philip Schneider on 18.04.14.
//  Copyright (c) 2014 phschneider.net. All rights reserved.
//

#import <Foundation/Foundation.h>

// Schnittstelle für das LocationTracking
// -> MapViewController
// -> MapViewDelegate
// -> UserInteraction
@interface PSMapAtmoUserLocationManager : NSObject

+ (PSMapAtmoUserLocationManager *) sharedInstance;

@end
