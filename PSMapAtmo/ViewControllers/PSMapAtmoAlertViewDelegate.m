//
//  PSNetAtmoAlertViewDelegate.m
//  PSNetAtmo
//
//  Created by Philip Schneider on 19.01.14.
//  Copyright (c) 2014 phschneider.net. All rights reserved.
//

#import "PSMapAtmoUserDefaults.h"
#import "PSMapAtmoAlertViewDelegate.h"
#import "PSMapAtmoMapAnalytics.h"
#import "PSMapAtmoFilter.h"

#ifndef CONFIGURATION_AppStore
    #import "TestFlight.h"
#endif

@implementation PSMapAtmoAlertViewDelegate

static PSMapAtmoAlertViewDelegate* instance = nil;
+ (PSMapAtmoAlertViewDelegate*) sharedInstance {
    @synchronized (self)
    {
        if (instance == nil)
        {
            [PSMapAtmoAlertViewDelegate new];
        }
    }
    return instance;
}


- (id) init
{
    DLogFuncName();
    NSAssert(!instance, @"Instance of PSMapAtmoAlertViewDelegate already exists");
    self = [super init];
    if (self)
    {

    }
    instance = self;
    return self;
}


#pragma mark - AlertView
// Sent to the delegate when the user clicks a button on an alert view.
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    DLogFuncName();
    if ([[alertView.title lowercaseString] isEqualToString:@"filter"])
    {
        PSMapAtmoFilter *filter = [[PSMapAtmoUserDefaults sharedInstance] filter];
        if (buttonIndex == alertView.cancelButtonIndex)
        {
            [[PSMapAtmoMapAnalytics sharedInstance] trackEventAlertFilterCancel];
            
#ifndef CONFIGURATION_AppStore
            [TestFlight passCheckpoint:@"settings-filter-alert-cancel"];
#endif
        
            
            if ([filter isEnabled])
            {
                [filter setDisabled];
                [[PSMapAtmoUserDefaults sharedInstance] setFilter:filter];
            }
            else
            {
                [filter setEnabled];
                [[PSMapAtmoUserDefaults sharedInstance] setFilter:filter];
            }
        }
        else
        {
            if (buttonIndex == alertView.firstOtherButtonIndex)
            {
                [[PSMapAtmoMapAnalytics sharedInstance] trackEventAlertFilterOnIgnoreMap];
                // Don't clear map
                // do Nothing
                
#ifndef CONFIGURATION_AppStore
                [TestFlight passCheckpoint:@"settings-filter-alert-dont-clear"];
#endif
            }
            else
            {
                // Clear map
                [[PSMapAtmoMapAnalytics sharedInstance] trackEventAlertFilterOnAndClearMap];
                [[NSNotificationCenter defaultCenter] postNotificationName:PSMAPATMO_PUBLIC_CLEAR_ALL object:nil];
                
#ifndef CONFIGURATION_AppStore
                [TestFlight passCheckpoint:@"settings-filter-alert-clear"];
#endif
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:PSMAPATMO_API_UPDATE_FILTER object:nil];
        }
    }
}


@end
