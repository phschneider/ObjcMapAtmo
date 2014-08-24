//
//  PSNetAtmoAppVersion.h
//  PSNetAtmo
//
//  Created by Philip Schneider on 14.12.13.
//  Copyright (c) 2013 phschneider.net. All rights reserved.
//

#import <Foundation/Foundation.h>

// Helper um herauszufinden welche AppVersion gerade eingesetzt wird und von welcher Version der Benutzer aktualisiert hat
@interface PSMapAtmoAppVersion : NSObject

@property (nonatomic) BOOL isFirstStart;
@property (nonatomic) BOOL isFirstStartForCurrentAppVersion;

+ (PSMapAtmoAppVersion *)sharedInstance;

- (NSString*)currentAppVersion;
- (NSString*)previousAppVersion;

- (BOOL)isFirstVersion;
@end
