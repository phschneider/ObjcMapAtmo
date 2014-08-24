//
//  PSMapAtmoFilter.h
//  MapAtmo
//
//  Created by Philip Schneider on 16.03.14.
//  Copyright (c) 2014 phschneider.net. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSMapAtmoFilter : NSObject <NSCoding>

@property (nonatomic) NSNumber *value;

+ (PSMapAtmoFilter*) defaultFilter;

- (BOOL) isDefault;
- (void) setIsDefault;
- (void) setIsCustom;

- (BOOL) isEnabled;
- (void) setEnabled;
- (void) setDisabled;

- (NSString*) stringValue;

@end
