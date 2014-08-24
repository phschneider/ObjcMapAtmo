//
//  PSNetAtmoAnalytics.h
//  PSNetAtmo
//
//  Created by Philip Schneider on 02.01.14.
//  Copyright (c) 2014 phschneider.net. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSMapAtmoAnalytics : NSObject

+ (PSMapAtmoAnalytics *)sharedInstance;
- (void)trackDevice;
- (void)trackDeviceOrientation;

- (void)trackConnectionOffline;
- (void)trackConnectionOnline;
- (void)trackConnection;

- (void)trackBlankInstall;
- (void)trackBlankInstallVersion:(NSString*)version;
- (void)trackUpdateInstall;
- (void)trackUpdateInstallVersion:(NSString*)version;
- (void)trackUpdateInstallVersion:(NSString*)version fromVersion:(NSString*)fromVersion;
@end
