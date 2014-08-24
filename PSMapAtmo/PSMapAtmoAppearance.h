//
//  PSNetAtmoAppearance.h
//  PSNetAtmo
//
//  Created by Philip Schneider on 18.01.14.
//  Copyright (c) 2014 phschneider.net. All rights reserved.
//

#import <Foundation/Foundation.h>

// Klasse für alle Grafiken welche in der App verwendet werden
@interface PSMapAtmoAppearance : NSObject

+ (PSMapAtmoAppearance*) sharedInstance;

- (void)applyComposerInterfaceApperance;
- (void)applyGlobalInterfaceAppearance;

- (UIImage *)fullScreenImage;
- (UIImage *)infoImage;
- (UIImage *)locateImage;
- (UIImage *)locateImageActive;
- (UIImage *)locateImageInactive;
- (UIImage *)locateImageError;
@end
