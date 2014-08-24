//
//  NSObject+Runtime.m
//  PSNetAtmo
//
//  Created by Philip Schneider on 25.01.14.
//  Copyright (c) 2014 phschneider.net. All rights reserved.
//

#import <objc/message.h>
#import <objc/runtime.h>

#import "NSObject+Runtime.h"

@implementation NSObject (Runtime)

- (NSArray*) allIvars
{
    NSMutableArray * ivarsArray = [[NSMutableArray alloc] init];
    
    unsigned int outCount;
	Ivar* ivars = class_copyIvarList([self class], &outCount);
    
    for (int i = 0; i < outCount ; i++) {
		NSString * ivarName = 	[NSString stringWithUTF8String:ivar_getName(ivars[i])];
        [ivarsArray addObject:ivarName];
    }
    return [NSArray arrayWithArray:ivarsArray];
}


- (NSArray*) allProperties
{
    NSMutableArray * props = [[NSMutableArray alloc] init];
    unsigned int outCount;
	objc_property_t * propList = nil;
    propList = class_copyPropertyList([self class], &outCount);
	
	
	for (int i=0;i<outCount;i++) {
		objc_property_t oneProp = propList[i];
		NSString * propName = [NSString stringWithUTF8String:property_getName(oneProp)];
        [props addObject:propName];
    }
    return [NSArray arrayWithArray:props];
}


- (BOOL) hasProperty:(NSString*) propertyClass {
	unsigned int outCount;
	objc_property_t * propList = nil;
	
    //	DLog(@"Self Class = %@", NSStringFromClass([self class]));
	propList = class_copyPropertyList([self class], &outCount);
	
	
	for (int i=0;i<outCount;i++) {
		objc_property_t oneProp = propList[i];
		NSString * propName = [NSString stringWithUTF8String:property_getName(oneProp)];
        
		if ( [[propName class] isEqualToString:propertyClass] )
        {
			return YES;
		}
		
        if ( NSClassFromString(propertyClass) )
        {
            return YES;
        }
        
	}
	return NO;
}


- (NSArray*)valueForKeys:(NSArray*)keys
{
    NSMutableArray * mArray = [[NSMutableArray alloc] initWithCapacity:[keys count]];
    for (NSString * key in keys)
    {
        [mArray addObject:[self valueForKey:key]];
    }
    
    return mArray;
}


- (NSString*) firstIvar {
   	unsigned int outCount;
	Ivar* ivars = class_copyIvarList([self class], &outCount);
    
    if ( outCount > 0 ) {
		return [NSString stringWithUTF8String:ivar_getName(ivars[1])];
    }
	
    free(ivars);
	return nil;
}


- (BOOL) hasIvar:(NSString*) ivarClass {
	unsigned int outCount;
	Ivar* ivars = class_copyIvarList([self class], &outCount);
    
    for (int i = 0; i < outCount ; i++) {
		NSString * ivarName = 	[NSString stringWithUTF8String:ivar_getName(ivars[i])];
        
        //		DLog(@"IvarClass = %@", [ivarClass asCamelCaseClassName]);
        //		DLog(@"IvarName = %@", [ivarName asCamelCaseClassName]);
        //		DLog(@"IvarName Class = %@", [ivarName class]);
        
		if ( [ivarName isEqualToString:ivarClass] ) {
			return YES;
		}
    }
	
    free(ivars);
	return NO;
}

@end
