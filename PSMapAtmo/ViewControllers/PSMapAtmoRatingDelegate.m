//
//  PSMapAtmoRatingDelegate.m
//  MapAtmo
//
//  Created by Philip Schneider on 01.03.14.
//  Copyright (c) 2014 phschneider.net. All rights reserved.
//

#import "PSMapAtmoRatingDelegate.h"
#import "PSMapAtmoMapAnalytics.h"

@implementation PSMapAtmoRatingDelegate

static PSMapAtmoRatingDelegate* instance = nil;

+ (PSMapAtmoRatingDelegate*) sharedInstance {
    @synchronized (self)
    {
        if (instance == nil)
        {
            [PSMapAtmoRatingDelegate new];
        }
    }
    return instance;
}


- (id)init
{
    DLogFuncName();
    NSAssert(!instance, @"Instance of PSMapAtmoRatingDelegate already exists");
    self = [super init];
    if (self)
    {
    }
    instance = self;
    return self;
}


#pragma mark - iRateDelegate
- (void)iRateCouldNotConnectToAppStore:(NSError *)error
{
    DLogFuncName();

    PSMAPATMOMAPANALYTICS_TRACK_METHOD;
}


- (void)iRateDidDetectAppUpdate
{
    DLogFuncName();

    PSMAPATMOMAPANALYTICS_TRACK_METHOD;
}


- (BOOL)iRateShouldPromptForRating
{
    DLogFuncName();

    PSMAPATMOMAPANALYTICS_TRACK_METHOD;
    return YES;
}


- (void)iRateDidPromptForRating
{
    DLogFuncName();

    PSMAPATMOMAPANALYTICS_TRACK_METHOD;
}


- (void)iRateUserDidAttemptToRateApp
{
    DLogFuncName();

    PSMAPATMOMAPANALYTICS_TRACK_METHOD;
}


- (void)iRateUserDidDeclineToRateApp
{
    DLogFuncName();

    PSMAPATMOMAPANALYTICS_TRACK_METHOD;
}


- (void)iRateUserDidRequestReminderToRateApp
{
    DLogFuncName();

    PSMAPATMOMAPANALYTICS_TRACK_METHOD;
}


- (BOOL)iRateShouldOpenAppStore
{
    DLogFuncName();
    return YES;
}


- (void)iRateDidOpenAppStore
{
    DLogFuncName();

    PSMAPATMOMAPANALYTICS_TRACK_METHOD;
}

@end
