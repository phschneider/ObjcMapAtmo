//
//  PSMapAtmoRatingDelegate.h
//  MapAtmo
//
//  Created by Philip Schneider on 01.03.14.
//  Copyright (c) 2014 phschneider.net. All rights reserved.
//

#import "iRate.h"
#import <Foundation/Foundation.h>

@interface PSMapAtmoRatingDelegate : NSObject <iRateDelegate>

+ (PSMapAtmoRatingDelegate*) sharedInstance;

@end
