//
// Created by Philip Schneider on 24.02.14.
// Copyright (c) 2014 phschneider.net. All rights reserved.
//

#import "PSMapAtmoLocation.h"
#import "PSMapAtmoMapViewController.h"

#import "NSString+MKCoordinateRegion.h"

@implementation PSMapAtmoLocation


- (id) initWithLocationType:(PSMapAtmoLocationType)locationType
{
    self = [super init];
    if (self)
    {
        self.locationType = locationType;
    }
    return self;
}


- (id) initWithLocationType:(PSMapAtmoLocationType)locationType region:(MKCoordinateRegion)region
{
    self = [self initWithLocationType:locationType];
    if (self)
    {
        self.region = region;
    }
    return self;
}


+ (id) defaultLocation
{
    return [[PSMapAtmoLocation alloc] initWithLocationType:PSMapAtmoLocationTypeDefault];
}


+ (id) userLocation
{
    return [[PSMapAtmoLocation alloc] initWithLocationType:PSMapAtmoLocationTypeUserLocation];
}


+ (id) currentLocation
{
    PSMapAtmoLocation * location = [[PSMapAtmoLocation alloc] initWithLocationType:PSMapAtmoLocationTypeCurrentLocation];
    location.region = [[PSMapAtmoMapViewController sharedInstance] currentRegion];

    return location;
}


+ (id) lastLocation
{
    return [[PSMapAtmoLocation alloc] initWithLocationType:PSMapAtmoLocationTypeLastLocation];
}


#pragma mark - Archiving (NSUserDefaults)

#define keyLocationType @"PSMapAtmoLocationType"
#define keyMKRegion @"PSMapatmoRegion"

- (void)encodeWithCoder:(NSCoder *)coder {
    DLogFuncName();

    // region to NSData
    NSData *data = [NSData dataWithBytes:&_region length:sizeof(_region)];

    NSLog(@"Data = %@",data);
    
    [coder encodeInt:self.locationType forKey:keyLocationType];
    [coder encodeObject:data forKey:keyMKRegion];
}


- (id)initWithCoder:(NSCoder *)coder {
    DLogFuncName();
    
    self = [super init];
    if (self) {
        self.locationType = [coder decodeIntegerForKey:keyLocationType];
        
        NSData *regiondata = [coder decodeObjectForKey:keyMKRegion];
        [regiondata getBytes:&_region length:sizeof(_region)];
        
        NSLog(@"Self.location = %@",NSStringFromMKCoordinateRegion(_region));
    }
	return self;
}

#undef keyLocationType
#undef keyMKRegion


- (NSString*)description
{
    DLogFuncName();
    return [NSString stringWithFormat:@"<PSMapAtmoLocation %p> => Class=%@ => LocationType=%d => Region=%@",self, NSStringFromClass([self class]),self.locationType, NSStringFromMKCoordinateRegion(self.region)];
}
@end