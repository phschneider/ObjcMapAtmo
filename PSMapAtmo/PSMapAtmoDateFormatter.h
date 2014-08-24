//
//  PSNetAtmoDateFormatter.h
//  PSNetAtmo
//
//  Created by Philip Schneider on 14.12.13.
//  Copyright (c) 2013 phschneider.net. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSMapAtmoDateFormatter : NSObject

+ (PSMapAtmoDateFormatter *)sharedInstance;

- (NSDate*) dateFromString:(NSString*) string;
- (NSString*) stringFromDate:(NSDate*) date;

- (NSString*) shortStringFromDate:(NSDate*) date;
@end
