//
//  NSObject+Runtime.h
//  PSNetAtmo
//
//  Created by Philip Schneider on 25.01.14.
//  Copyright (c) 2014 phschneider.net. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Runtime)

- (NSArray*) allIvars;
- (NSArray*) allProperties;

- (NSArray*)valueForKeys:(NSArray*)keys;

- (BOOL) hasProperty:(NSString*) propertyClass;
- (NSString*) firstIvar;
- (BOOL) hasIvar:(NSString*) ivarClass;


@end
