//
//  NSString+MKCoordinateRegion.h
//  MapAtmo
//
//  Created by Philip Schneider on 01.03.14.
//  Copyright (c) 2014 phschneider.net. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <Foundation/Foundation.h>

@interface NSString (MKCoordinateRegion)

NSString *NSStringFromMKCoordinateRegion(MKCoordinateRegion region);

@end
