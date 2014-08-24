//
//  PSNetAtmoAppearance.m
//  PSNetAtmo
//
//  Created by Philip Schneider on 18.01.14.
//  Copyright (c) 2014 phschneider.net. All rights reserved.
//

#import "PSMapAtmoAppearance.h"
#import "PSMapAtmoViewController.h"
#import "PSMapAtmoNavigationController.h"

#import <MessageUI/MessageUI.h>

@implementation PSMapAtmoAppearance
static PSMapAtmoAppearance* instance = nil;
+ (PSMapAtmoAppearance*) sharedInstance {
    @synchronized (self)
    {
        if (instance == nil)
        {
            [PSMapAtmoAppearance new];
        }
    }
    return instance;
}


- (id) init
{
    DLogFuncName();
    NSAssert(!instance, @"Instance of PSMapAtmoAppearance already exists");
    self = [super init];
    if (self)
    {
       
    }
    instance = self;
    return self;
}


#pragma mark - Appearance
// Wird für den MFMessageComposer verwendet
- (void)applyComposerInterfaceApperance
{
    DLogFuncName();
    if (SYSTEM_VERSION_LESS_THAN(@"7.0"))
    {
        UIColor * appearanceColor = nil;
        
        if (SYSTEM_VERSION_LESS_THAN(@"6.0"))
        {
            appearanceColor = [UIColor darkGrayColor];
            
        }
        else
        {
            appearanceColor = [UIColor darkGrayColor];
        }
        
        [[UINavigationBar appearance] setTintColor:appearanceColor];
        [[UIToolbar appearance] setTintColor:appearanceColor];
    }
}


- (void)applyGlobalInterfaceAppearance
{
    DLogFuncName();
    // My default color of choice
    if (SYSTEM_VERSION_LESS_THAN(@"7.0"))
    {
        UIColor * appearanceColor = nil;
        if (SYSTEM_VERSION_LESS_THAN(@"6.0"))
        {
            appearanceColor = [UIColor darkGrayColor];
            
        }
        else
        {
            appearanceColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Midnight-1536x2048.jpg"]];
        }
    
        // MFMessageComposer kann keine colorWithPatternImage als TintColor haben
        [[UINavigationBar appearanceWhenContainedIn:[PSMapAtmoNavigationController class], nil] setTintColor:appearanceColor];
        [[UIToolbar appearanceWhenContainedIn:[PSMapAtmoNavigationController class], nil] setTintColor:appearanceColor];
    }
}


#pragma mark - Colors



#pragma mark - Images
- (UIImage *)fullScreenImage
{
    DLogFuncName();
    if (SYSTEM_VERSION_LESS_THAN(@"7.0"))
    {
        return [UIImage imageNamed:@"white-338-enter-fullscreen"];
    }
    else
    {
        return [UIImage imageNamed:@"gray-1067-enter-fullscreen"];
    }
}


- (UIImage *)infoImage
{
    DLogFuncName();
    if (SYSTEM_VERSION_LESS_THAN(@"7.0"))
    {
        return [UIImage imageNamed:@"gray-42-info"];
    }
    else
    {
        return [UIImage imageNamed:@"InfoButton"];
    }
}


- (UIImage *)locateImage
{
    DLogFuncName();
    if (SYSTEM_VERSION_LESS_THAN(@"7.0"))
    {
        return [UIImage imageNamed:@"white-193-location-arrow"];
    }
    else
    {
        return [UIImage imageNamed:@"TrackingLocationOffMaskLandscape"];
    }
}


- (UIImage *)locateImageActive
{
    DLogFuncName();
    if (SYSTEM_VERSION_LESS_THAN(@"7.0"))
    {
        return [UIImage imageNamed:@"blue-193-location-arrow"];
    }
    else
    {
        return [UIImage imageNamed:@"TrackingLocationMaskLandscape"];
    }
}


- (UIImage *)locateImageInactive
{
    DLogFuncName();
    if (SYSTEM_VERSION_LESS_THAN(@"7.0"))
    {
        return [UIImage imageNamed:@"white-193-location-arrow"];
    }
    else
    {
        return [UIImage imageNamed:@"TrackingLocationOffMaskLandscape"];
    }
}


- (UIImage *)locateImageError
{
    DLogFuncName();
    if (SYSTEM_VERSION_LESS_THAN(@"7.0"))
    {
        return [UIImage imageNamed:@"red-193-location-arrow"];
    }
    else
    {
        return [UIImage imageNamed:@"TrackingLocationOffMaskLandscape"];
    }
}


@end

