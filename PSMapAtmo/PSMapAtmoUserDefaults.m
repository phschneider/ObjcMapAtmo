//
// Created by Philip Schneider on 05.12.13.
// Copyright (c) 2013 phschneider.net. All rights reserved.
//


#import "PSMapAtmoUserDefaults.h"
#import "PSMapAtmoPublicApi.h"
#import "PSMapAtmoLocation.h"
#import "PSMapAtmoFilter.h"

#define PSMAPATMO_USERDEFAULTS_TEMP_UNIT_CELSIUS            @"PSMAPATMO_USERDEFAULTS_TEMP_UNIT_CELSIUS"
#define PSMAPATMO_USERDEFAULTS_TEMP_UNIT_FAHRENHEIT         @"PSMAPATMO_USERDEFAULTS_TEMP_UNIT_FAHRENHEIT"

#define PSMAPATMO_USERDEFAULTS_DISTANCE_UNIT_KILOMETERES    @"PSMAPATMO_USERDEFAULTS_DISTANCE_UNIT_KILOMETERES"
#define PSMAPATMO_USERDEFAULTS_DISTANCE_UNIT_MILES          @"PSMAPATMO_USERDEFAULTS_DISTANCE_UNIT_MILES"

#define PSMAPATMO_USERDEFAULTS_TEMP_UNIT                    @"PSMAPATMO_USERDEFAULTS_TEMP_UNIT"
#define PSMAPATMO_USERDEFAULTS_DISTANCE_UNIT                @"PSMAPATMO_USERDEFAULTS_DISTANCE_UNIT"

#define PSMAPATMO_USERDEFAULTS_FILTER                       @"PSMAPATMO_USERDEFAULTS_FILTER"

#define PSMAPATMO_USERDEFAULTS_FULLSCREEN_LEAVINGS          @"PSMAPATMO_USERDEFAULTS_FULLSCREEN_LEAVINGS"
#define PSMAPATMO_USERDEFAULTS_FULLSCREEN_ENTERINGS         @"PSMAPATMO_USERDEFAULTS_FULLSCREEN_ENTERINGS"

#define PSMAPATMO_USERDEFAULTS_MAPTYPE                      @"PSMAPATMO_USERDEFAULTS_MAPTYPE"
#define PSMAPATMO_USERDEFAULTS_LOCATION                     @"PSMAPATMO_USERDEFAULTS_LOCATION"

#define PSMAPATMO_USERDEFAULTS_BETA_NAME                    @"PSMAPATMO_USERDEFAULTS_BETA_NAME"
#define PSMAPATMO_USERDEFAULTS_BETA_MAIL                    @"PSMAPATMO_USERDEFAULTS_BETA_MAIL"

@interface PSMapAtmoUserDefaults()

@property (nonatomic) int numberOfFullScreenLeavings;
@property (nonatomic) int numberOfFullScreenEnterings;

@end


@implementation PSMapAtmoUserDefaults

static PSMapAtmoUserDefaults* instance = nil;
+ (PSMapAtmoUserDefaults*) sharedInstance {
    @synchronized (self)
    {
        if (instance == nil)
        {
            [PSMapAtmoUserDefaults new];
        }
    }
    return instance;
}


- (id) init
{
    DLogFuncName();
    NSAssert(!instance, @"Instance of PSMapAtmouserDefaults already exists");
    self = [super init];
    if (self)
    {
        self.numberOfFullScreenEnterings = [[[NSUserDefaults standardUserDefaults] objectForKey:PSMAPATMO_USERDEFAULTS_FULLSCREEN_ENTERINGS] integerValue];
        self.numberOfFullScreenLeavings = [[[NSUserDefaults standardUserDefaults] objectForKey:PSMAPATMO_USERDEFAULTS_FULLSCREEN_LEAVINGS] integerValue];

        PSMapAtmoFilter *filter = [self filter];
        if (!filter)
        {
            [self setFilter:[PSMapAtmoFilter defaultFilter]];
        }

        PSMapAtmoLocation *location = [self location];
        if (!location)
        {
            [self setLocation:[PSMapAtmoLocation defaultLocation] ];
        }
        else
        {
            DLog(@"Location => %@",location);
        }
    }
    instance = self;
    return self;
}


#pragma mark - TempUnits
- (BOOL) useFahrenheit
{
    DLogFuncName();
    NSString * value = [[NSUserDefaults standardUserDefaults] objectForKey:PSMAPATMO_USERDEFAULTS_TEMP_UNIT];
    return ([value isEqualToString:PSMAPATMO_USERDEFAULTS_TEMP_UNIT_FAHRENHEIT]);
}


- (void) setUseFahrenheitAsTempUnit
{
    DLogFuncName();
    [[NSUserDefaults standardUserDefaults] setObject:PSMAPATMO_USERDEFAULTS_TEMP_UNIT_FAHRENHEIT forKey:PSMAPATMO_USERDEFAULTS_TEMP_UNIT];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void) setUseCelsiusAsTempUnit
{
    DLogFuncName();
    [[NSUserDefaults standardUserDefaults] setObject:PSMAPATMO_USERDEFAULTS_TEMP_UNIT_CELSIUS forKey:PSMAPATMO_USERDEFAULTS_TEMP_UNIT];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark - DistanceUnits
- (BOOL) useMiles
{
    DLogFuncName();
    NSString * value = [[NSUserDefaults standardUserDefaults] stringForKey:PSMAPATMO_USERDEFAULTS_DISTANCE_UNIT];
    return ([value isEqualToString:PSMAPATMO_USERDEFAULTS_DISTANCE_UNIT_MILES]);
}


- (void)setUseMilesAsDistanceUnit
{
    DLogFuncName();
    [[NSUserDefaults standardUserDefaults] setObject:PSMAPATMO_USERDEFAULTS_DISTANCE_UNIT_MILES forKey:PSMAPATMO_USERDEFAULTS_DISTANCE_UNIT];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)setUseKilometersAsDistanceUnit
{
    DLogFuncName();
    [[NSUserDefaults standardUserDefaults] setObject:PSMAPATMO_USERDEFAULTS_DISTANCE_UNIT_KILOMETERES forKey:PSMAPATMO_USERDEFAULTS_DISTANCE_UNIT];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark - Filter
- (PSMapAtmoFilter *)filter
{
    DLogFuncName();
    NSData *filterData = [[NSUserDefaults standardUserDefaults] objectForKey:PSMAPATMO_USERDEFAULTS_FILTER];
    PSMapAtmoFilter *filter= [NSKeyedUnarchiver unarchiveObjectWithData:filterData];

    return filter;
}


- (void) setFilter:(PSMapAtmoFilter*)filter
{
    DLogFuncName();

    NSData *filterData = [NSKeyedArchiver archivedDataWithRootObject:filter];
    [[NSUserDefaults standardUserDefaults] setObject:filterData
                                              forKey:PSMAPATMO_USERDEFAULTS_FILTER];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [[NSNotificationCenter defaultCenter] postNotificationName:PSMAPATMO_API_UPDATE_FILTER object:nil];
}


#pragma mark - FullScreen
#pragma mark - FirstUsage
- (BOOL) firstUseOfFullScreenMode
{
    DLogFuncName();
    // Kleiner 2 da wenn der Wert das erste Mal abgefragt wird, er schon auf 1 steht da bereits im FullScreen Modus
    return (self.numberOfFullScreenEnterings < 2);
}


- (void) setEnteringFullScreenMode
{
    DLogFuncName();

    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:++self.numberOfFullScreenEnterings] forKey:PSMAPATMO_USERDEFAULTS_FULLSCREEN_ENTERINGS];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void) setLeavingFullScreenMode
{
    DLogFuncName();
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:++self.numberOfFullScreenLeavings] forKey:PSMAPATMO_USERDEFAULTS_FULLSCREEN_LEAVINGS];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark - MapTyps
-(MKMapType) mapType
{
    DLogFuncName();

    MKMapType mapType = 0;
    mapType = [[[NSUserDefaults standardUserDefaults] objectForKey:PSMAPATMO_USERDEFAULTS_MAPTYPE] intValue];
    return mapType;
}


- (void) setMapType:(NSNumber*)mapType
{
    DLogFuncName();

    [[NSUserDefaults standardUserDefaults] setObject:mapType
                                              forKey:PSMAPATMO_USERDEFAULTS_MAPTYPE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark - Location
- (PSMapAtmoLocation *)location
{
    DLogFuncName();
    NSData *locationData = [[NSUserDefaults standardUserDefaults] objectForKey:PSMAPATMO_USERDEFAULTS_LOCATION];
    PSMapAtmoLocation *location = [NSKeyedUnarchiver unarchiveObjectWithData:locationData];
   
    return location;
}


- (void) setLocation:(PSMapAtmoLocation*)location
{
    DLogFuncName();

    NSData *locationData = [NSKeyedArchiver archivedDataWithRootObject:location];
    [[NSUserDefaults standardUserDefaults] setObject:locationData
                                              forKey:PSMAPATMO_USERDEFAULTS_LOCATION];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Beta
- (NSString*) betaName
{
    DLogFuncName();

    return [[NSUserDefaults standardUserDefaults] objectForKey:PSMAPATMO_USERDEFAULTS_BETA_NAME];
}


- (void) setBetaName:(NSString*)betaName
{
    DLogFuncName();

    [[NSUserDefaults standardUserDefaults] setObject:betaName forKey:PSMAPATMO_USERDEFAULTS_BETA_NAME];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (NSString*) betaMail
{
    DLogFuncName();

    return [[NSUserDefaults standardUserDefaults] objectForKey:PSMAPATMO_USERDEFAULTS_BETA_MAIL];
}


- (void) setBetaMail:(NSString*)betaMail
{
    DLogFuncName();

    [[NSUserDefaults standardUserDefaults] setObject:betaMail forKey:PSMAPATMO_USERDEFAULTS_BETA_MAIL];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end