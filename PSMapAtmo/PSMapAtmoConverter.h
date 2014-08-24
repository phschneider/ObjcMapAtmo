//
//  PSNetAtmoConverter.h
//  PSNetAtmo
//
//  Created by Philip Schneider on 03.01.14.
//  Copyright (c) 2014 phschneider.net. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSMapAtmoConverter : NSObject

+ (PSMapAtmoConverter*) sharedInstance;
- (CGFloat)convertCelsiusToFahrenheit:(CGFloat)celsius;
- (CGFloat)convertMeteresToMiles:(CGFloat)km;

@end
