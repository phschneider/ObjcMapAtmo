//
//  PSNetAtmoMapViewController.h
//  PSNetAtmo
//
//  Created by Philip Schneider on 12.12.13.
//  Copyright (c) 2013 phschneider.net. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "PSMapAtmoViewController.h"

@interface PSMapAtmoMapViewController : PSMapAtmoViewController <MKMapViewDelegate, NSFetchedResultsControllerDelegate, UIGestureRecognizerDelegate>

+(PSMapAtmoMapViewController*) sharedInstance;

- (void)infoButtonTouched:(id)sender;
- (MKCoordinateRegion)currentRegion;
@end
