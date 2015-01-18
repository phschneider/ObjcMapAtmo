//
//  PSNetAtmoPublicApi.h
//  PSNetAtmo
//
//  Created by Philip Schneider on 15.12.13.
//  Copyright (c) 2013 phschneider.net. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <Foundation/Foundation.h>

@interface PSMapAtmoPublicApi : NSObject

+ (PSMapAtmoPublicApi*) sharedInstance;
- (void) meassuresForSw:(CLLocationCoordinate2D)sw andNe:(CLLocationCoordinate2D)ne;

@end
