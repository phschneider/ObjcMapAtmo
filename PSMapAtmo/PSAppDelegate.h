//
//  PSAppDelegate.h
//  PSNetAtmo
//
//  Created by Philip Schneider on 23.11.13.
//  Copyright (c) 2013 phschneider.net. All rights reserved.
//

#import <UIKit/UIKit.h>

#define APPDELEGATE ((PSAppDelegate*)[[UIApplication sharedApplication] delegate])
@class MBFingerTipWindow;

@interface PSAppDelegate : UIResponder <UIApplicationDelegate>

#ifndef CONFIGURATION_AppStore
@property (strong, nonatomic) MBFingerTipWindow *window;
#else
@property (strong, nonatomic) UIWindow *window;
#endif

@end