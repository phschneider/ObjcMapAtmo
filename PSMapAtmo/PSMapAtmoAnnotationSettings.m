//
// Created by Philip Schneider on 01.02.15.
// Copyright (c) 2015 phschneider.net. All rights reserved.
//

#import "PSMapAtmoAnnotationSettings.h"


@implementation PSMapAtmoAnnotationSettings

- (id)init
{
    DLogFuncName();
    self = [super init];
    if (self)
    {
        self.showsCustomImage = NO;
        self.showsValueInAnnotation = NO;
        self.changeBackgroundSizeAutomatically = YES;
        self.imageSize = @36;
        self.fontSize = @8.5;
    }
    return self;
}


+ (PSMapAtmoAnnotationSettings*) defaultAnnotationSettings
{
    DLogFuncName();
    PSMapAtmoAnnotationSettings *settings = [[PSMapAtmoAnnotationSettings alloc] init];
    return settings;
}


#pragma mark - Image
- (CGFloat)minImageSize
{
    DLogFuncName();
    return 12.0;
}


- (CGFloat)maxImageSize
{
    DLogFuncName();
    return 64.0;
}


- (NSString*)imageNameWithSize
{
    DLogFuncName();
    NSString *imagename = [NSString stringWithFormat:@"marker-red-%d",[[self imageSize] intValue]];
    if (![UIImage imageNamed:imagename])
    {
        NSLog(@"NOT FOUND Imagename = %@", imagename);
    }
    return imagename;
}


#pragma mark - Font
- (CGFloat)minFontSize
{
    DLogFuncName();
    return 5.0;
}


- (CGFloat)maxFontSize
{
    DLogFuncName();
    return 12.0;
}


#pragma mark - Background
- (CGFloat)minBackgroundSize
{
    DLogFuncName();
    return 10.0;
}

- (CGFloat)maxBackgroundSize
{
    DLogFuncName();
    return 24.0;
}


//- (void) setShowsValueInAnnotation:(BOOL)showsValueInAnnotation
//{
//    DLogFuncName();
//    _showsValueInAnnotation = showsValueInAnnotation;
//}


- (void) setChangeBackgroundSizeAutomatically:(BOOL)changeBackgroundSizeAutomatically
{
    DLogFuncName();
    _changeBackgroundSizeAutomatically = changeBackgroundSizeAutomatically;
}

// For further usage
- (BOOL) useBackgroundSizeFromTempValue
{
    DLogFuncName();

    return NO;
}



- (BOOL) isDefault
{
    DLogFuncName();

    return !self.showsCustomImage && !self.showsValueInAnnotation;
}


- (NSString*)description
{
    DLogFuncName();
    return [NSString stringWithFormat:@"<PSMapAtmoAnnotationSettings %p> => Class=%@ => showsCustomImage=%@ showsValueInAnnotation=%@ imageSize=%@ fontSize=%@",self, NSStringFromClass([self class]),self.showsCustomImage ? @"YES" : @"NO", self.showsValueInAnnotation ? @"YES" : @"NO", self.imageSize, self.fontSize];
}



#pragma mark - Archiving (NSUserDefaults)

#define showsImageKey              @"PSMapAtmoAnnotationSettingsShowsCustomImage"
#define showsValueKey              @"PSMapAtmoAnnotationSettingsShowsValue"
#define imageSizeKey               @"PSMapAtmoAnnotationSettingsImageSize"
#define fontSizeKey                @"PSMapAtmoAnnotationSettingsFonzSize"
#define backgroundSizeKey          @"PSMapAtmoAnnotationSettingsBackgroundSize"
#define changeBackgroundSizeKey    @"PSMapAtmoAnnotationSettingsChangeBackgroundSizeKey"

- (void)encodeWithCoder:(NSCoder *)coder {
    DLogFuncName();

    [coder encodeObject:[NSNumber numberWithBool:self.showsCustomImage] forKey:showsImageKey];
    [coder encodeObject:[NSNumber numberWithBool:self.showsValueInAnnotation] forKey:showsValueKey];
    [coder encodeObject:[NSNumber numberWithBool:self.changeBackgroundSizeAutomatically] forKey:changeBackgroundSizeKey];
    
    [coder encodeObject:self.imageSize forKey:imageSizeKey];
    [coder encodeObject:self.fontSize forKey:fontSizeKey];
    [coder encodeObject:self.backgroundSize forKey:backgroundSizeKey];
}


- (id)initWithCoder:(NSCoder *)coder {
    DLogFuncName();

    self = [super init];
    if (self)
    {
        self.showsCustomImage = [[coder decodeObjectForKey:showsImageKey] boolValue];
        self.showsValueInAnnotation = [[coder decodeObjectForKey:showsValueKey] boolValue];
        self.changeBackgroundSizeAutomatically = [[coder decodeObjectForKey:changeBackgroundSizeKey] boolValue];

        self.imageSize = [coder decodeObjectForKey:imageSizeKey];
        self.fontSize = [coder decodeObjectForKey:fontSizeKey];
        self.backgroundSize = [coder decodeObjectForKey:backgroundSizeKey];
    }
    return self;
}

@end