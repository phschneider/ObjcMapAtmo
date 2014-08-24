//
//  PSNetAtmoAppVersion.m
//  PSNetAtmo
//
//  Created by Philip Schneider on 14.12.13.
//  Copyright (c) 2013 phschneider.net. All rights reserved.
//

#import "PSMapAtmo.h"
#import "PSMapAtmoDateFormatter.h"
#import "PSMapAtmoAppVersion.h"
#import "PSMapAtmoAnalytics.h"
#import "PSMapAtmoNotifications.h"

@interface PSMapAtmoAppVersion()

@end

@implementation PSMapAtmoAppVersion

static PSMapAtmoAppVersion* instance = nil;

+ (PSMapAtmoAppVersion*) sharedInstance {
    @synchronized (self)
    {
        if (instance == nil)
        {
            [PSMapAtmoAppVersion new];
        }
    }
    return instance;
}


- (id)init
{
    DLogFuncName();
    NSAssert(!instance, @"Instance of PSMapAtmoAppVersion already exists");

    self = [super init];
    if (self)
    {
        _isFirstStart = NO;
        _isFirstStartForCurrentAppVersion = NO;
        
        [self checkIsFirstStart];
        [self checkIsFirstStartForCurrentAppVersion];
        
        DLog(@"previousAppVersion = %@", [self previousAppVersion]);
        DLog(@"isFirstStart = %@", ([self isFirstStart]) ? @"YES" : @"NO");
        DLog(@"isFirstStartForCurrentAppVersion = %@", ([self isFirstStartForCurrentAppVersion]) ? @"YES" : @"NO");
    }
    
    instance = self;
    return self;
}


#pragma mark - FirstStart
- (void)checkIsFirstStart
{
    DLogFuncName();
    BOOL isFirststart = _isFirstStart;
    NSDate * firstStartDate = [[NSUserDefaults standardUserDefaults] objectForKey:DEFAULTS_APP_FIRST_START_DATE];
    if (!firstStartDate)
    {
        DLog(@"is first start");
        isFirststart = YES;
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:DEFAULTS_APP_FIRST_START_DATE];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        DLog(@"First Start Date = %@", [[PSMapAtmoDateFormatter sharedInstance] stringFromDate:firstStartDate]);
    }
    
    self.isFirstStart = isFirststart;
}


- (void) setIsFirstStart:(BOOL)isFirstStart
{
    DLogFuncName();
    _isFirstStart = isFirstStart;
    if (_isFirstStart)
    {
        [[PSMapAtmoAnalytics sharedInstance] trackBlankInstall];
        [[PSMapAtmoAnalytics sharedInstance] trackBlankInstallVersion:[self currentAppVersion]];
    }
}


#pragma mark - FirstStartCurrentVersion
- (void)checkIsFirstStartForCurrentAppVersion
{
    DLogFuncName();
    BOOL isFirstStartForCurrentAppVersion = _isFirstStartForCurrentAppVersion;
    
    if ([self isFirstStart])
    {
        // Track current version for new app
        isFirstStartForCurrentAppVersion = YES;
    }
    else
    {
        //Compare AppVersion
        NSString * previousVersion = [[NSUserDefaults standardUserDefaults] objectForKey:DEFAULTS_APP_PREVIOUS_VERSION];
        NSDate * previousVersionDate = [[NSUserDefaults standardUserDefaults] objectForKey:DEFAULTS_APP_PREVIOUS_VERSION_DATE];
    
        DLog(@"LastVersion %@, Date = %@", previousVersion, [[PSMapAtmoDateFormatter sharedInstance] stringFromDate:previousVersionDate]);
        if (![[self currentAppVersion] isEqualToString:previousVersion])
        {
            isFirstStartForCurrentAppVersion = YES;
        }
    }
    
    self.isFirstStartForCurrentAppVersion = isFirstStartForCurrentAppVersion;
}


// Zeigt gleichzeitig auch die Settings an!
- (void)setIsFirstStartForCurrentAppVersion:(BOOL)isFirstStartForCurrentAppVersion
{
    DLogFuncName();
    
    _isFirstStartForCurrentAppVersion = isFirstStartForCurrentAppVersion;
    NSDate *currentDate = [NSDate date];
    if (_isFirstStartForCurrentAppVersion && ![self isFirstStart])
    {
        // Erweiterung des Else-Zweig von checkIsFirstStartForCurrentAppVersion
        [self setPreviousAppVersion];
        [self setCurrentAppVersionWithDate:currentDate];

        [[PSMapAtmoAnalytics sharedInstance] trackUpdateInstall];
        [[PSMapAtmoAnalytics sharedInstance] trackUpdateInstallVersion:[self currentAppVersion]];
        [[PSMapAtmoAnalytics sharedInstance] trackUpdateInstallVersion:[self currentAppVersion] fromVersion:[self previousAppVersion]];
    }
    
    if (_isFirstStartForCurrentAppVersion)
    {
        [self setCurrentAppVersionWithDate:currentDate];

        NSMutableArray * versionHistory = [[NSUserDefaults standardUserDefaults] objectForKey:DEFAULS_APP_VERSION_HISTORY];
        if (!versionHistory)
        {
            versionHistory = [[NSMutableArray alloc] init];
        }

        [versionHistory addObject:@{[self currentAppVersion] : currentDate}];

        [[NSUserDefaults standardUserDefaults] setObject:versionHistory forKey:DEFAULS_APP_VERSION_HISTORY];
        [[NSUserDefaults standardUserDefaults] synchronize];

        [[NSNotificationCenter defaultCenter] postNotificationName:PSMAPATMO_PUBLIC_FIRST_START_NOTIFICATION object:nil];
    }
}

- (void)setPreviousAppVersion
{
    NSString *previousVersion = [[NSUserDefaults standardUserDefaults] objectForKey:DEFAULTS_APP_CURRENT_VERSION];
    NSDate *previousVersionDate = [[NSUserDefaults standardUserDefaults] objectForKey:DEFAULTS_APP_CURRENT_VERSION_DATE];

    NSLog(@"PreviousVersion = %@",previousVersion);

    [[NSUserDefaults standardUserDefaults] setObject:previousVersion forKey:DEFAULTS_APP_PREVIOUS_VERSION];
    [[NSUserDefaults standardUserDefaults] setObject:previousVersionDate forKey:DEFAULTS_APP_PREVIOUS_VERSION_DATE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)setCurrentAppVersionWithDate:(NSDate *)currentDate
{
    [[NSUserDefaults standardUserDefaults] setObject:[self currentAppVersion] forKey:DEFAULTS_APP_CURRENT_VERSION];
    [[NSUserDefaults standardUserDefaults] setObject:currentDate forKey:DEFAULTS_APP_CURRENT_VERSION_DATE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark - Getter
- (NSString*)currentAppVersion
{
    DLogFuncName();
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}




- (NSString*)previousAppVersion
{
    DLogFuncName();
    return [[NSUserDefaults standardUserDefaults] objectForKey:DEFAULTS_APP_PREVIOUS_VERSION];
}


- (BOOL) isFirstVersion
{
    DLogFuncName();
    return ![self previousAppVersion];
}


@end
