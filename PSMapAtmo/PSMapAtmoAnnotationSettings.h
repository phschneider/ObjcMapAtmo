//
// Created by Philip Schneider on 01.02.15.
// Copyright (c) 2015 phschneider.net. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PSMapAtmoAnnotationSettings : NSObject <NSCoding>

@property (nonatomic) BOOL showsCustomImage;
@property (nonatomic) BOOL showsValueInAnnotation;
@property (nonatomic) BOOL changeBackgroundSizeAutomatically;
@property (nonatomic) NSNumber *imageSize;
@property (nonatomic) NSNumber *fontSize;
@property (nonatomic) NSNumber *backgroundSize;

+ (PSMapAtmoAnnotationSettings*) defaultAnnotationSettings;

- (CGFloat)minImageSize;
- (CGFloat)maxImageSize;

- (NSString *)imageNameWithSize;

- (CGFloat)minFontSize;
- (CGFloat)maxFontSize;

- (CGFloat)minBackgroundSize;
- (CGFloat)maxBackgroundSize;

@end
