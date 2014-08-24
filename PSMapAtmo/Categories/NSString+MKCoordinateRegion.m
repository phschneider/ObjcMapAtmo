//
//  NSString+MKCoordinateRegion.m
//  MapAtmo
//
//  Created by Philip Schneider on 01.03.14.
//  Copyright (c) 2014 phschneider.net. All rights reserved.
//

#import "NSString+MKCoordinateRegion.h"

@implementation NSString (MKCoordinateRegion)

NSString *NSStringFromMKCoordinateRegion(MKCoordinateRegion region) {
    return [NSString stringWithFormat:@"{{%f, %f}, {%f, %f}}", region.center.latitude, region.center.longitude, region.span.latitudeDelta, region.span.longitudeDelta];
}
@end
