//
//  PSNetAtmoLocalStorage.h
//  PSNetAtmo
//
//  Created by Philip Schneider on 14.12.13.
//  Copyright (c) 2013 phschneider.net. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PSMapAtmoPublicDevice;
@interface PSMapAtmoLocalStorage : NSObject

+ (PSMapAtmoLocalStorage *) sharedInstance;

- (PSMapAtmoPublicDevice*)publicDeviceWithID:(NSString*)deviceID;
- (BOOL) hasPublicDeviceWithID:(NSString*)deviceID;
- (void) addPublicDevice:(PSMapAtmoPublicDevice*)publicDevice;
- (int) numberOfPublicDevices;
- (int) storageSize;

- (void) archive;
- (void) load;

@end
