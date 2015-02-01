//
//  PSNetAtmoLocalStorage.h
//  PSNetAtmo
//
//  Created by Philip Schneider on 14.12.13.
//  Copyright (c) 2013 phschneider.net. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PSMapAtmoPublicDeviceDict;


@interface PSMapAtmoLocalStorage : NSObject

+ (PSMapAtmoLocalStorage *) sharedInstance;

- (PSMapAtmoPublicDeviceDict*)publicDeviceWithID:(NSString*)deviceID;
- (BOOL) hasPublicDeviceWithID:(NSString*)deviceID;
- (void) addPublicDevice:(PSMapAtmoPublicDeviceDict*)publicDevice;
- (int) numberOfPublicDevices;
- (NSDictionary *)allDevices;
- (int) storageSize;

@end
