//
//  PSMapAtmoFilter.m
//  MapAtmo
//
//  Created by Philip Schneider on 16.03.14.
//  Copyright (c) 2014 phschneider.net. All rights reserved.
//


#define PSMAPATMO_FILTER_DEFAULT_VALUE  @7
#define PSMApATMO_FILTER_VALUE_CUSTOM  @3

#import "PSMapAtmoFilter.h"
#import "PSMapAtmoUserDefaults.h"
#import "PSMapAtmoConverter.h"

@interface PSMapAtmoFilter()
@property (nonatomic) BOOL isCustom; // wird benötigt damit wenn slider auf wert 7 steht, nicht der filter komplett umspringt ...
@end

@implementation PSMapAtmoFilter

- (id)init
{
    DLogFuncName();
    self = [super init];
    if (self)
    {
        self.value = PSMAPATMO_FILTER_DEFAULT_VALUE;
        self.isCustom = NO;
    }
    return self;
}


+ (PSMapAtmoFilter*) defaultFilter
{
    DLogFuncName();
    PSMapAtmoFilter *filter = [[PSMapAtmoFilter alloc] init];
    [filter setIsDefault];
    
    return filter;
}


#pragma mark - UserDefaults
#warning  TODO


#pragma mark - Default
- (BOOL) isDefault
{
    DLogFuncName();
    
    return ([self.value isEqualToNumber:PSMAPATMO_FILTER_DEFAULT_VALUE] && !self.isCustom);
}


- (void) setIsDefault
{
    DLogFuncName();
    
    // Reihenfolge !!! Achtung
    self.value = PSMAPATMO_FILTER_DEFAULT_VALUE;
    self.isCustom = NO;
}


- (void) setIsCustom
{
    DLogFuncName();
    self.value = PSMApATMO_FILTER_VALUE_CUSTOM;
    self.isCustom = YES;
}


- (void) setValue:(NSNumber *)value
{
    DLogFuncName();
    _value = value;
    self.isCustom = YES;
}

#pragma mark - Enabled
- (BOOL) isEnabled
{
    DLogFuncName();
    return [self.value integerValue] > -1;
}


- (void) setEnabled
{
    DLogFuncName();
    [self setIsDefault];
}


- (void) setDisabled
{
    DLogFuncName();
    self.value = @-1;
}


#pragma mark - Archiving (NSUserDefaults)

#define keyValue @"PSMapAtmoFilterValue"

- (void)encodeWithCoder:(NSCoder *)coder {
    DLogFuncName();
    
    [coder encodeObject:self.value forKey:keyValue];
}


- (id)initWithCoder:(NSCoder *)coder {
    DLogFuncName();
    
    self = [super init];
    if (self)
    {
        self.value = [coder decodeObjectForKey:keyValue];
        
        if (!self.value)
        {
            [self setIsDefault];
        }
    }
	return self;
}


- (NSString*) stringValue
{
    DLogFuncName();
    if ([[PSMapAtmoUserDefaults sharedInstance] useFahrenheit])
    {
        return [NSString stringWithFormat:@"%.1f°F", [[PSMapAtmoConverter sharedInstance] convertCelsiusToFahrenheit:[self.value floatValue]]];
    }
    else
    {
        return [NSString stringWithFormat:@"%.1f°C", [self.value floatValue]];
    }
    
}

#warning TODO - IntValue
#warning TODO - FloatValue


#undef keyLocationType
#undef keyMKRegion


- (NSString*)description
{
    DLogFuncName();
    return [NSString stringWithFormat:@"<PSMapAtmoFilter %p> => Class=%@ => Value=%@",self, NSStringFromClass([self class]),self.value];
}


- (BOOL) isEqual:(id)object
{
    DLogFuncName();
    if ([object isKindOfClass:[self class]])
    {
        #warning
        [((PSMapAtmoFilter*)object).value isEqualToNumber:self.value];
    }
    return NO;
}

@end
