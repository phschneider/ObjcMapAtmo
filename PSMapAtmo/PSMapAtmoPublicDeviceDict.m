//
//  PSNetAtmoPublicDeviceDict.m
//  PSNetAtmo
//
//  Created by Philip Schneider on 14.12.13.
//  Copyright (c) 2013 phschneider.net. All rights reserved.
//

#import "PSMapAtmoLocalStorage.h"
#import "PSMapAtmoPublicDeviceDict.h"
#import "PSMapAtmoConverter.h"
#import "PSMapAtmoUserDefaults.h"
#import "PSMapAtmoMapAnalytics.h"

#define VALUE_NOT_FOUND     -9999.99
#define TEMPERATURE_KEY     @"temperature"
#define HUMIDITY_KEY        @"humidity"
#define PRESSURE_KEY        @"pressure"

@interface PSMapAtmoPublicDeviceDict()

@property (nonatomic) NSDictionary *dict;
@property (nonatomic) NSDictionary *address;
@property (nonatomic) CLPlacemark *placeMark;
@end


/*
{
    "_id" = "70:ee:50:00:e4:38";
    mark = 11;
    measures =         {
        "02:00:00:00:f2:1c" =             {
            res =                 {
                1397851578 =                     (
                                                  20,
                                                  55
                                                  );
            };
            type =                 (
                                    temperature,
                                    humidity
                                    );
        };
        "70:ee:50:00:e4:38" =             {
            res =                 {
                1397851623 =                     (
                                                  "1010.1"
                                                  );
            };
            type =                 (
                                    pressure
                                    );
        };
    };
    place =         {
        altitude = "1084.1206949101";
        location =             (
                                "-120.95149",
                                "39.26167"
                                );
        timezone = "America/Los_Angeles";
    };
 */

@implementation PSMapAtmoPublicDeviceDict

- (id) initWithDict:(NSDictionary*)dict
{
    self = [super init];
    if (self)
    {
        self.dict = dict;
    }
    return self;
}


+ (PSMapAtmoPublicDeviceDict*) publicDeviceFromDict:(NSDictionary*)dict
{
    DLogFuncName();
    PSMapAtmoPublicDeviceDict * device = [[PSMapAtmoLocalStorage sharedInstance] publicDeviceWithID:[dict objectForKey:@"_id"]];
    BOOL addDevice = (!device);
    if (addDevice)
    {
        device = [[PSMapAtmoPublicDeviceDict alloc] initWithDict:dict];
        [[PSMapAtmoLocalStorage sharedInstance] addPublicDevice:device];
        
//        [PSNetAtmoPublicDeviceDict resolveAdressForDevice:device];
    }
    
    return device;
}


+ (void) resolveAdressForDevice:(PSMapAtmoPublicDeviceDict*)device
{
    if (!device.address)
    {
        CLGeocoder *gc = [[CLGeocoder alloc] init];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:[[device latitude]doubleValue] longitude:[[device longitude]doubleValue] ];
        [gc reverseGeocodeLocation:location completionHandler:^(NSArray *placemark, NSError *error) {
            device.placeMark = [placemark objectAtIndex:0];
            device.address = device.placeMark.addressDictionary;
            // do something with the address, see keys in the remark below
            
        }];
    }
}


+ (void) createDeviceWithDict:(NSDictionary*)dict
{
    DLogFuncName();
    PSMapAtmoPublicDeviceDict * device = [[PSMapAtmoLocalStorage sharedInstance] publicDeviceWithID:[dict objectForKey:@"_id"]];
    BOOL addDevice = (!device);
    if (addDevice)
    {
        device = [[PSMapAtmoPublicDeviceDict alloc] initWithDict:dict];
        [[PSMapAtmoLocalStorage sharedInstance] addPublicDevice:device];
//        [PSNetAtmoPublicDeviceDict resolveAdressForDevice:device];
    }
}


- (NSString*) deviceID
{
    return [self.dict objectForKey:@"_id"];
}

- (NSDictionary*)place
{
//    DLogFuncName();
    return [self.dict objectForKey:@"place"];
}

- (NSDictionary*)measures
{
//    DLogFuncName();
    return [self.dict objectForKey:@"measures"];
}


- (NSNumber*) latitude
{
//    DLogFuncName();
    return [[[self place] objectForKey:@"location"] objectAtIndex:1];
}

- (NSNumber*) longitude
{
//    DLogFuncName();
    return [[[self place] objectForKey:@"location"] objectAtIndex:0];
}

- (CLLocationCoordinate2D)coordinate
{
//    DLogFuncName();
    CLLocationCoordinate2D coord;
    coord.latitude = [self.latitude doubleValue]; // or self.latitudeValue à la MOGen
    coord.longitude = [self.longitude doubleValue];
    return coord;
}


- (MKMapItem*)mapItem {
//    DLogFuncName();
//    NSDictionary *addressDict = @{(NSString*)kABPersonAddressStreetKey : _address};
    
    MKPlacemark *placemark = [[MKPlacemark alloc]
                              initWithCoordinate:self.coordinate
                              addressDictionary:nil];
    
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    mapItem.name = [self deviceID];
    
    return mapItem;
}



// Für Annotation
- (NSString*)title
{
//    DLogFuncName();
//    [PSNetAtmoPublicDeviceDict resolveAdressForDevice:self];

    NSString * distanceString = @"";
    if (self.userLocation)
    {
        CLLocation * publicLocation = [[CLLocation alloc] initWithLatitude:[[self latitude]doubleValue] longitude:[[self longitude] doubleValue]];
        CLLocationDistance distance = [publicLocation distanceFromLocation:self.userLocation];
        if (distance)
        {
            float distanceInKm = distance/1000.0;
            if ([[PSMapAtmoUserDefaults sharedInstance] useMiles])
            {
                distanceString = [NSString stringWithFormat:@" (Distance: %.2f mi)",[[PSMapAtmoConverter sharedInstance] convertMeteresToMiles:distanceInKm]];
            }
            else
            {
                distanceString = [NSString stringWithFormat:@" (Distance: %.2f km)",distanceInKm];
            }
            [[PSMapAtmoMapAnalytics sharedInstance] trackPinDistance:distanceString];
        }
    }
    
    float temperature = [self temperature];
//    float humidity = [self humidity];
//    float pressure = [self pressure];
    
//    NSLog(@"Temp = %f", temperature);
//    NSLog(@"Pressure = %f", pressure);
//    NSLog(@"Humidity = %f", humidity);
    
    NSString * meassureString = nil;
//    NSString * humidityString = nil;
//    NSString * pressureString = nil;
    
    if (temperature == VALUE_NOT_FOUND)
    {
//        dispatch_async(dispatch_get_main_queue(),^{
//            [[[UIAlertView alloc] initWithTitle:@"No Value!" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
//        });
//        
        meassureString = @" n/a";
    }
    else
    {
        if ([[PSMapAtmoUserDefaults sharedInstance] useFahrenheit])
        {
            meassureString = [NSString stringWithFormat:@" %.1f°F",[[PSMapAtmoConverter sharedInstance] convertCelsiusToFahrenheit:temperature]];
        }
        else
        {
            meassureString = [NSString stringWithFormat:@" %.1f°C",temperature];
        }
    }
    
    
//    humidityString = [NSString stringWithFormat:@" %.1f%%",humidity];
//    pressureString = [NSString stringWithFormat:@" %.1mb",pressure];
    
//    return [NSString stringWithFormat:@"%@ %.1f°C | %.1f°F %@", (self.placeMark) ? self.placeMark.locality : @"", meassure, [[PSNetAtmoConverter sharedInstance] convertCelsiusToFahrenheit:meassure] , distanceString];
    return [NSString stringWithFormat:@"%@%@%@", (self.placeMark) ? self.placeMark.locality : @"", meassureString,distanceString];
}


// key von meassures sind die statationen
/* [meassures allKeys]
<__NSArrayI 0x28e16450>(
                        02:00:00:00:16:6a,
                        70:ee:50:00:16:b2
                        )
*/
/*
 [meassures allValues]
 <__NSArrayI 0x28e1fd30>(
 {
     res =     {
         1397851533 =         (
            "-0.1",
            89
         );
        };
      type =     (
         temperature,
         humidity
         );
     },
 {
     res =     {
        1397851558 =         
        (
            "1010.9"
        );
      };
     type =     (
        pressure
     );
     }
 )
 */
- (NSDictionary*)meassures
{
    DLogFuncName();
    if ([[self.dict objectForKey:@"measures"] isKindOfClass:[NSDictionary class]])
    {
//        NSLog(@"Meassures = %@", [self.dict objectForKey:@"measures"]);
        return [self.dict objectForKey:@"measures"];
    }
    return nil;
}



// ACHTUNG!!!!
// Res kann folgendermaßen aussehen:
/*
 2014-07-23 22:03:24.866 MapAtmo-Beta[1831:60b] Meassures = {
 "02:00:00:03:7b:d4" =     {
 res =         (
 {
 "beg_time" = 0;
 }
 );
 type =         (
 temperature,
 humidity
 );
 };
 "70:ee:50:03:84:ce" =     {
 res =         {
 1405175997 =             (
 "1008.7"
 );
 };
 type =         (
 pressure
 );
 };
 }
 2014-07-23 22:03:24.867 MapAtmo-Beta[1831:60b] RES = (
 {
 "beg_time" = 0;
 }
 )
 */
- (float)temperature
{
    DLogFuncName();
 
    NSDictionary *meassure = [self meassures];
    CGFloat value = VALUE_NOT_FOUND;
 
    if (meassure)
    {
        for (NSDictionary *key in [meassure allValues] )
        {
            if ([[key allKeys] containsObject:@"type"])
            {
                NSArray *types = [key objectForKey:@"type"];
                if ([types containsObject:TEMPERATURE_KEY])
                {
//                    NSLog(@"TEMPERATURE_KEY Found in %@", key);
                    if ([[key allKeys] containsObject:@"res"])
                    {
                        if ([[key objectForKey:@"res"] isKindOfClass:[NSDictionary class]] )
                        {
                            NSDictionary *res = [key objectForKey:@"res"];
                            int index = [types indexOfObject:TEMPERATURE_KEY];
                            NSString *timeInterval = nil;
                            if (!res)
                            {
//                                dispatch_async(dispatch_get_main_queue(),^{
//                                    [[[UIAlertView alloc] initWithTitle:@"Res not found!" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
//                                });
                                return value;
                            }

                            for (NSString *resKey in [res allKeys])
                            {
                                if (resKey > timeInterval)
                                {
                                    timeInterval = resKey;
                                    value = [[[res objectForKey:resKey] objectAtIndex:index] floatValue];
                                }
                            }
                        }
                        else
                        {
                            // => Res besteht nur aus begin time !!! beg_time" = 0;
                            NSLog(@"Meassures = %@", meassure);
                            NSLog(@"RES = %@", [key objectForKey:@"res"]);
                            
//                            dispatch_async(dispatch_get_main_queue(),^{
//                                [[[UIAlertView alloc] initWithTitle:@"Res = " message:[NSString stringWithFormat:@"%@",[key objectForKey:@"res"]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
//                            });
                            
                            return value;
                        }
                    }
                }
            }
        }
    }
    return value;
}


- (float)pressure
{
    DLogFuncName();

    NSDictionary *meassure = [self meassures];
    CGFloat value = VALUE_NOT_FOUND;
    
    if (meassure)
    {
        for (NSDictionary *key in [meassure allValues] )
        {
            if ([[key allKeys] containsObject:@"type"])
            {
                NSArray *types = [key objectForKey:@"type"];
                if ([types containsObject:PRESSURE_KEY])
                {
//                    NSLog(@"PRESSURE_KEY Found in %@", key);
                    if ([[key allKeys] containsObject:@"res"])
                    {
                        NSDictionary *res = [key objectForKey:@"res"];
                        int index = [types indexOfObject:PRESSURE_KEY];
                        NSString *timeInterval = nil;
                        for (NSString *resKey in [res allKeys])
                        {
                            if (resKey > timeInterval)
                            {
                                timeInterval = resKey;
                                value = [[[res objectForKey:resKey] objectAtIndex:index] floatValue];
                            }
                        }
                    }
                }
            }
        }
    }
    return value;
}


- (float)humidity
{
    DLogFuncName();
    
    NSDictionary *meassure = [self meassures];
    CGFloat value = VALUE_NOT_FOUND;
    
    if (meassure)
    {
        for (NSDictionary *key in [meassure allValues] )
        {
            if ([[key allKeys] containsObject:@"type"])
            {
                NSArray *types = [key objectForKey:@"type"];
                if ([types containsObject:HUMIDITY_KEY])
                {
//                    NSLog(@"HUMIDITY_KEY Found in %@", key);
                    if ([[key allKeys] containsObject:@"res"])
                    {
                        NSDictionary *res = [key objectForKey:@"res"];
                        int index = [types indexOfObject:HUMIDITY_KEY];
                        NSString *timeInterval = nil;
                        for (NSString *resKey in [res allKeys])
                        {
                            if (resKey > timeInterval)
                            {
                                timeInterval = resKey;
                                value = [[[res objectForKey:resKey] objectAtIndex:index] floatValue];
                            }
                        }
                    }
                }
            }
        }
    }
    return value;
}


- (void)encodeWithCoder:(NSCoder *) coder
{
//    [coder encodeInt:noteIndex forKey:@"noteIndex"];
//    [coder encodeCGRect:cellRect forKey:@"cellRect"];
//    [coder encodeBool:noteOn forKey: @"noteOn"];
//    [coder encodeInt:note forKey:@"note"];
//    [coder encodeInt:velocity forKey:@"velocity"];
//    [coder encodeInt:channel forKey:@"channel"];
//    [coder encodeInt:releaseVelocity forKey:@"releaseVelocity"];
//    [coder encodeFloat:duration forKey:@"duration"];
    [coder encodeObject:self.dict forKey:@"dict"];
}


@end
