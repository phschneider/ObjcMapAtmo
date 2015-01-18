//
//  PSNetAtmoLocalStorage.m
//  PSNetAtmo
//
//  Created by Philip Schneider on 14.12.13.
//  Copyright (c) 2013 phschneider.net. All rights reserved.
//


#import "PSMapAtmoLocalStorage.h"
#import "PSMapAtmoPublicDeviceDict.h"


@interface PSMapAtmoLocalStorage ()

@property (nonatomic) NSMutableDictionary * storage;
@property (nonatomic) int _numberOfPublicDevices;
@end


@implementation PSMapAtmoLocalStorage


static PSMapAtmoLocalStorage * instance = nil;
+ (PSMapAtmoLocalStorage *) sharedInstance {
    @synchronized (self)
    {
        if (instance == nil)
        {
            [PSMapAtmoLocalStorage new];
        }
    }
    return instance;
}


- (id)init
{
    NSAssert(!instance,@"We already have an instance of PSMapAtmoLocalStorage");
    DLogFuncName();
    self = [super init];
    if (self)
    {
        __numberOfPublicDevices = 0;
        self.storage = [[NSMutableDictionary alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearStorage:) name:PSMAPATMO_PUBLIC_CLEAR_STORAGE object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearStorage:) name:PSMAPATMO_PUBLIC_CLEAR_ALL object:nil];
    }
    instance = self;
    return self;
}


#pragma PublicDevices
- (PSMapAtmoPublicDeviceDict*)publicDeviceWithID:(NSString*)deviceID
{
    DLogFuncName();
    return self.storage[deviceID];
}


- (BOOL) hasPublicDeviceWithID:(NSString*)deviceID
{
    DLogFuncName();
    return (self.storage[deviceID] != nil);
}


- (void) addPublicDevice:(PSMapAtmoPublicDeviceDict*)publicDevice
{
    DLogFuncName();
    if (![self hasPublicDeviceWithID:publicDevice.deviceID] && publicDevice.deviceID != nil)
    {
        __numberOfPublicDevices++;
        self.storage[publicDevice.deviceID] = publicDevice;
//        NSLog(@"DeviceID = %@", publicDevice.deviceID);
        [[NSNotificationCenter defaultCenter] postNotificationName:PSMAPATMO_PUBLIC_DEVICE_ADDED_NOTIFICATION object:nil userInfo:@{@"device" : publicDevice}];
    }
    else
    {
        DLog(@"Device already exists in DB");
    }
}


- (int) numberOfPublicDevices
{
    DLogFuncName();
    return __numberOfPublicDevices;
}

- (NSData*) toDdata
{
    DLogFuncName();
//    NSMutableData *data = [[NSMutableData alloc] init];
//    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
//    [archiver encodeObject:self.storage forKey:@"Some Key Value"];
//    [archiver finishEncoding];
//
    NSDictionary * dict = [self.storage copy];
    return [NSKeyedArchiver archivedDataWithRootObject:dict];
}


#warning - lesen des caches macht das ganze langsam ...
- (int) storageSize
{
    DLogFuncName();
    NSData * toData = [self toDdata];
    DLog(@"StorageSize = %d", [toData length]);
    return [toData length];
}


- (void) clearStorage:(NSNotification*)note
{
    DLogFuncName();
    self.storage = nil;
    self.storage = [[NSMutableDictionary alloc] init];
}


+ (NSString *) applicationDocumentsDirectory
{
    DLogFuncName();
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? paths[0] : nil;
    return basePath;
}
@end
