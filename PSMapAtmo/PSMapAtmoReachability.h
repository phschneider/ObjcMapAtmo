//
// Created by Philip Schneider on 02.01.14.
// Copyright (c) 2014 phschneider.net. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PSMapAtmoReachability : NSObject

+ (PSMapAtmoReachability*) sharedInstance;
- (BOOL)isReachable;
- (NSString*)currentReachabilityAsString;

@end