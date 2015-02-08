//
//  PSMapAtmoMapViewDelegate.m
//  PSMapAtmo
//
//  Created by Philip Schneider on 02.01.14.
//  Copyright (c) 2014 phschneider.net. All rights reserved.
//

#define MAP_VIEW_REGION_DEFAULT_SIZE    1000


#define CLCOORDINATE_EPSILON 0.00005f
#define CLCOORDINATES_EQUAL( coord1, coord2 ) (coord1.latitude == coord2.latitude && coord1.longitude == coord2.longitude)
#define CLCOORDINATES_EQUAL2( coord1, coord2 ) (fabs(coord1.latitude - coord2.latitude) < CLCOORDINATE_EPSILON && fabs(coord1.longitude - coord2.longitude) < CLCOORDINATE_EPSILON)

#import "PSMapAtmoMapView.h"
#import "PSMapAtmoMapViewDelegate.h"
#import "PSMapAtmoPublicDeviceDict.h"
#import "PSMapAtmoMapAnalytics.h"
#import "PSMapAtmoUserDefaults.h"
#import "PSMapAtmoAnnotationSettings.h"
#import "UIImage+Color.h"

@interface PSMapAtmoMapViewDelegate()
@property (nonatomic) float mapZoomLevel;
@end

@implementation PSMapAtmoMapViewDelegate


#pragma mark - DelegateProtocol


- (void)mapView:(MKMapView*)mapView willEnable3D:(BOOL)enabled
{
    if (enabled)
    {
        MKMapCamera *camera = mapView.camera;
        if (camera)
        {
            camera.pitch = 75;
        }
        else
        {
            camera = [MKMapCamera cameraLookingAtCenterCoordinate:mapView.centerCoordinate fromEyeCoordinate:mapView.centerCoordinate eyeAltitude:mapView.camera.altitude];
        }
        
        mapView.camera = camera;
    }
    else
    {
        mapView.camera = nil;
    }
}


- (void)mapView:(MKMapView*)mapView zoomToUserLocation:(MKUserLocation*)userLocation
{
    DLogFuncName();
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(mapView.userLocation.location.coordinate, MAP_VIEW_REGION_DEFAULT_SIZE, MAP_VIEW_REGION_DEFAULT_SIZE);
    MKCoordinateRegion adjustedRegion = [mapView regionThatFits:viewRegion];
    [mapView setRegion:adjustedRegion animated:YES];
    
#warning - hier wird auch von 3D zu 2D wieder zurückgewechselt .. :(
}


#pragma mark - Helper
- (BOOL) mapViewShowsUserLocationCentered:(MKMapView*)mapView
{
    if(mapView.showsUserLocation)
    {
        if (CLCOORDINATES_EQUAL2(mapView.centerCoordinate, mapView.userLocation.location.coordinate))
        {
            DLog(@"UserLocationCentered!!!!");
            return YES;
        }
    }
    DLog(@"NOTTTTTTT  UserLocationCentered!!!!");
    return NO;
}


- (void) setMapZoomLevel:(float)mapZoomLevel
{
    DLogFuncName();
    float abs = ABS(_mapZoomLevel - mapZoomLevel);
    
    BOOL zoomIn = (_mapZoomLevel < mapZoomLevel);
    BOOL zoomOut = (_mapZoomLevel > mapZoomLevel);
    
    DLog(@"ABS ZoomLevel = (abs) %f (neu) %f (alt) %f %@",abs, mapZoomLevel, _mapZoomLevel, (zoomIn) ? @"+" : (zoomOut) ? @"-" : @"");
    
    float rounded  = _mapZoomLevel;
    if (mapZoomLevel > 0)
    {
        rounded = (float) (roundf (_mapZoomLevel * 10) / 10.0);
    }

    if (abs > 0.25)
    {
        DLog(@"Tracked  ZoomLevel %f",rounded);
        
        // Setze ZoomLevel nur wenn änderung über Detla Hinaus ...
        _mapZoomLevel = mapZoomLevel;
        
        [[PSMapAtmoMapAnalytics sharedInstance] trackMapZoomLevel: rounded];
    }
}



#pragma mark - MapViewDelegate
#pragma mark - Responding to Map Position Changes
- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    DLogFuncName();
    // wird auch durch corelocation aufgerufen ...

    [(PSMapAtmoMapView*)mapView debugRenderingStatus];
  
    [[NSNotificationCenter defaultCenter] postNotificationName:PSMAPATMO_PUBLIC_MAP_CHANGED_NOTIFICATION object:nil];
 
#warning hier - analytics
    
    if (![self mapViewShowsUserLocationCentered:mapView])
    {
//        [self highlightToolBarLocateItem:NO];
    }
}


- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    DLogFuncName();
    [[NSNotificationCenter defaultCenter] postNotificationName:PSMAPATMO_PUBLIC_MAP_CHANGED_NOTIFICATION object:nil];
    [(PSMapAtmoMapView*)mapView debugRenderingStatus];

    #warning hier - analytics
    if ([(PSMapAtmoMapView*)mapView isFullyRendered])
    {
        DLog(@"REQUEST DEVICES !!!! REQUEST DEVICES !!!! REQUEST DEVICES !!!! REQUEST DEVICES !!!! REQUEST DEVICES !!!! REQUEST DEVICES !!!! REQUEST DEVICES !!!! ");
        [[(PSMapAtmoMapView*)mapView dataSource] meassuresForMapView:mapView];
        self.mapZoomLevel = [(PSMapAtmoMapView*)mapView zoomLevel];
        [[PSMapAtmoMapAnalytics sharedInstance] trackMapSize:[(PSMapAtmoMapView*)mapView mapSize]];
    }
}

#warning wenn karte bewegt wird muss geprüft werden ob  map shows user location && userlocation is center, dann button aktivieren oder deaktivieren ...


#pragma mark - Managing Annotation Views
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if (annotation == mapView.userLocation)
    {
        return nil;
    }
    
    PSMapAtmoAnnotationSettings *settings = [[PSMapAtmoUserDefaults sharedInstance] annotationSettings];
    if (![settings showsCustomImage] && ![settings showsValueInAnnotation])
    {
        MKPinAnnotationView *view=[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"parkingloc"];
        view.canShowCallout = YES;
        [view setPinColor:MKPinAnnotationColorRed];
        return view;
    }
    else
    {
        UIImage * annotationImage = nil;
        MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@""];
        annotationView.canShowCallout = YES;
        
        if ([settings showsCustomImage])
        {
            annotationImage = [UIImage imageNamed:[settings imageNameWithSize]];
            annotationView.image = annotationImage;
        }
        
        if ([settings showsValueInAnnotation])
        {
            UILabel *label = [[UILabel alloc] initWithFrame:annotationView.frame];
            
            CGRect frame = CGRectZero;
            BOOL adjustFrameFromImage = ([settings changeBackgroundSizeAutomatically] && [settings showsCustomImage]);
            if (adjustFrameFromImage)
            {
                frame.size = CGSizeMake(annotationImage.size.width/2,annotationImage.size.width/2);
                frame.origin.y = ceil(annotationImage.size.width/10);
            }
            else
            {
                frame.size = CGSizeMake([settings.backgroundSize floatValue],[settings.backgroundSize floatValue]);
//                else
//                {
//                    frame.origin.y = ceil([settings.backgroundSize floatValue]/0.5);
//                }
            }

            label.frame = frame;
            label.textAlignment = NSTextAlignmentCenter;
            if ([annotation isKindOfClass:[PSMapAtmoPublicDeviceDict class] ])
            {
                label.text = [(PSMapAtmoPublicDeviceDict *) annotation displayTitle];
            }
            else
            {
                label.text = annotation.title;
            }
            label.backgroundColor = [UIColor blackColor];
            label.adjustsFontSizeToFitWidth = YES;
            label.font = [UIFont systemFontOfSize:[[settings fontSize] floatValue]];
            label.clipsToBounds = YES;
            label.textColor = [UIColor whiteColor];
            label.layer.cornerRadius = frame.size.width/2;
            
            if ([settings showsCustomImage])
            {
                CGPoint center = label.center;
                center.x = ceil(annotationImage.size.width/2);
                label.center = center;
            }
            
            if (!adjustFrameFromImage && [settings showsCustomImage])
            {
                CGPoint center = label.center;
                center.y = ceil(annotationImage.size.height/3);
                label.center = center;
                
//                frame.origin.y = ceil(annotationImage.size.width/10)+(([settings.backgroundSize floatValue]/30)*-1);
            }
            
            [annotationView addSubview:label];
        }
    
        return annotationView;
    }
    
    
    
    
//    int style = 5;
//    switch (style)
//    {
//        case 0:{
//            UIImage * annotationImage = [UIImage imageNamed:@"1387054453_Map-Marker-Marker-Outside-Pink-Smaller"];
//            annotationView.image = annotationImage;
//
//            UILabel *label = [[UILabel alloc] initWithFrame:annotationView.frame];
//            CGRect frame = CGRectZero;
//            frame.size =  annotationImage.size;
//            label.frame = frame;
//            label.textAlignment = NSTextAlignmentCenter;
//            label.text = annotation.title;
//            label.backgroundColor = [UIColor whiteColor];
//            label.adjustsFontSizeToFitWidth = YES;
//            label.font = [UIFont systemFontOfSize:12.0];
//            label.layer.cornerRadius = 15.0;
//            label.clipsToBounds = YES;
//            [annotationView addSubview:label];
//        }
//        break;
//        case 1:{
//            UIImage * annotationImage = [UIImage imageNamed:@"1387054453_Map-Marker-Marker-Outside-Pink-Smaller"];
//            annotationView.image = annotationImage;
//            
//            UILabel *label = [[UILabel alloc] initWithFrame:annotationView.frame];
//            CGRect frame = CGRectZero;
//            frame.size =  annotationImage.size;
//            frame.origin.y = -4;
//            label.frame = frame;
//            label.textAlignment = NSTextAlignmentCenter;
//            label.text = annotation.title;
//            label.backgroundColor = [UIColor clearColor];
//            label.adjustsFontSizeToFitWidth = YES;
//            label.font = [UIFont systemFontOfSize:10.0];
//            label.layer.cornerRadius = 15.0;
//            label.clipsToBounds = YES;
//            label.textColor = [UIColor whiteColor];
//            [annotationView addSubview:label];
//
//        }
//        case 2:{
//
//            UIImage * annotationImage = [UIImage imageNamed:@"1387054453_Map-Marker-Marker-Outside-Pink-Small"];
//            annotationView.image = annotationImage;
//            
//            UILabel *label = [[UILabel alloc] initWithFrame:annotationView.frame];
//            CGRect frame = CGRectZero;
//            frame.size =  annotationImage.size;
//            frame.origin.y = -6;
//            label.frame = frame;
//            label.textAlignment = NSTextAlignmentCenter;
//            label.text = annotation.title;
//            label.backgroundColor = [UIColor clearColor];
//            label.adjustsFontSizeToFitWidth = YES;
//            label.font = [UIFont systemFontOfSize:6.0];
//            label.layer.cornerRadius = 15.0;
//            label.clipsToBounds = YES;
//            label.textColor = [UIColor whiteColor];
//            [annotationView addSubview:label];
//            
//        }
//        case 3:{
//            
//            UIImage * annotationImage = [UIImage imageNamed:@"1387054453_Map-Marker-Marker-Outside-Pink-Small"];
//            annotationView.image = annotationImage;
//            
//            UILabel *label = [[UILabel alloc] initWithFrame:annotationView.frame];
//            CGRect frame = CGRectZero;
//            frame.size =  annotationImage.size;
//            frame.origin.y = -4;
//            label.frame = frame;
//            label.textAlignment = NSTextAlignmentCenter;
//            label.text = annotation.title;
//            label.backgroundColor = [UIColor clearColor];
//            label.adjustsFontSizeToFitWidth = YES;
//            label.font = [UIFont systemFontOfSize:10.0];
//            label.layer.cornerRadius = 15.0;
//            label.clipsToBounds = YES;
//            label.textColor = [UIColor whiteColor];
//            [annotationView addSubview:label];
//            
//        }break;
//        case 4:{
//            // Sehr gut, vielleicht etwas zu klein
//            int size = 15;
//            UIImage * annotationImage = [UIImage imageNamed:@"1387054453_Map-Marker-Marker-Outside-Pink-Small"];
//            annotationView.image = annotationImage;
//            
//            UILabel *label = [[UILabel alloc] initWithFrame:annotationView.frame];
//            CGRect frame = CGRectZero;
//            frame.size =  annotationImage.size;
//            frame.size = CGSizeMake(size, size);
//            frame.origin.y = 3;
//            label.frame = frame;
//            CGPoint center = label.center;
//            center.x = ceil(annotationImage.size.width/2);
//            label.center = center;
//            label.textAlignment = NSTextAlignmentCenter;
//            label.text = annotation.title;
//            label.backgroundColor = [UIColor blackColor];
//            label.adjustsFontSizeToFitWidth = YES;
//            label.font = [UIFont systemFontOfSize:6.0];
//            label.layer.cornerRadius = size/2;
//            label.clipsToBounds = YES;
//            label.textColor = [UIColor whiteColor];
//            [annotationView addSubview:label];
//        }break;
//        case 5:{
//            // Sehr gut, vielleicht etwas zu klein
//            int size = 15;
//            UIImage * annotationImage = [UIImage imageNamed:@"1387054453_Map-Marker-Marker-Outside-Pink-Small"];
//            annotationView.image = annotationImage;
//            
//            UILabel *label = [[UILabel alloc] initWithFrame:annotationView.frame];
//            CGRect frame = CGRectZero;
//            frame.size =  annotationImage.size;
//            frame.size = CGSizeMake(size, size);
//            frame.origin.y = 3;
//            label.frame = frame;
//            CGPoint center = label.center;
//            center.x = ceil(annotationImage.size.width/2);
//            label.center = center;
//            label.textAlignment = NSTextAlignmentCenter;
//            label.text = annotation.title;
//            label.backgroundColor = [UIColor blackColor];
//            label.adjustsFontSizeToFitWidth = YES;
//            label.font = [UIFont systemFontOfSize:10.0];
//            label.layer.cornerRadius = size/2;
//            label.clipsToBounds = YES;
//            label.textColor = [UIColor whiteColor];
//            [annotationView addSubview:label];
//        }
//  
//            default:
//        {
//            
//        }break;
//    }
    
//    UIImage *frame = [UIImage imageNamed:imageName];
////    UIImage *image = theImageInFrameInner;
//
//    UIGraphicsBeginImageContext(CGSizeMake(pin.size.width, pin.size.height));
//
//    [frame drawInRect:CGRectMake(0, 0, frame.size.width, frame.size.height)];
//    [image drawInRect:CGRectMake(2, 2, 60, 60)]; // the frame your inner image
//    //maybe you should draw the left bottom icon here,
//
//
//    //then set back the new image, done
//    annotationView.image = UIGraphicsGetImageFromCurrentImageContext();
//
//    UIGraphicsEndImageContext();

//    UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
//    [rightButton addTarget:self action:@selector(writeSomething:) forControlEvents:UIControlEventTouchUpInside];
//    [rightButton setTitle:annotation.title forState:UIControlStateNormal];
//
//    annotationView.rightCalloutAccessoryView = rightButton;
//    annotationView.canShowCallout = YES;
//    annotationView.draggable = NO;
//    return annotationView;
}


- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    DLogFuncName();
}


- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    DLogFuncName();
}


#pragma mark - Dragging an Annotation View
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState
{
    DLogFuncName();
}



#pragma mark - Tracking the User Location
- (void)mapViewWillStartLocatingUser:(MKMapView *)mapView
{
    DLogFuncName();
}


- (void)mapViewDidStopLocatingUser:(MKMapView *)mapView
{
    DLogFuncName();
}


- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    DLogFuncName();
    NSLog(@"TimeStamp = %@",userLocation.location.timestamp);
    NSLog(@"Coordinate = %f | %f", userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude);
    NSLog(@"Accuracy = %f | %f", userLocation.location.horizontalAccuracy, userLocation.location.verticalAccuracy);

    NSTimeInterval secondsBetweenUserLocationTimeAndNow = [[NSDate date] timeIntervalSinceDate:userLocation.location.timestamp];
    MKUserLocation * lastUserlocation = ((PSMapAtmoMapView *)mapView).lastUserLocation;
    NSLog(@"Coordinate = %f | %f", lastUserlocation.location.coordinate.latitude, lastUserlocation.location.coordinate.longitude);
    NSLog(@"Accuracy = %f | %f", lastUserlocation.location.horizontalAccuracy, lastUserlocation.location.verticalAccuracy);

    // Check is userlocation was cached and is old ...
    // Check is Userlocation changed
    BOOL accuracyChanged = (lastUserlocation.location.horizontalAccuracy != userLocation.location.horizontalAccuracy ||
                            lastUserlocation.location.verticalAccuracy != userLocation.location.verticalAccuracy );
    NSLog(@"accuracyChanged = %d", accuracyChanged);

    float diffLat = (float) ABS(lastUserlocation.location.coordinate.latitude - userLocation.coordinate.latitude);
    float diffLong = (float) ABS(lastUserlocation.location.coordinate.longitude - userLocation.coordinate.longitude);
    float delta = 0.000005;

    NSLog(@"Diff Lat = %f",diffLat );
    NSLog(@"Diff Long = %f",diffLong );

    BOOL coordinatesChanged = ( diffLat > delta  || diffLong > delta);
    NSLog(@"coordinatesChanged = %d", coordinatesChanged);

    if (secondsBetweenUserLocationTimeAndNow < 5 && ( accuracyChanged || coordinatesChanged) )
    {
        NSLog(@"UPDATE ");
    //    [mapView setCenterCoordinate:mapView.userLocation.location.coordinate animated:YES];

    //    [[NSNotificationCenter defaultCenter] postNotificationName:PSMapAtmo_PUBLIC_MAP_UPDATED_USER_LOCATION object:nil userInfo:@{@"userLocation" : userLocation}];
        [((PSMapAtmoMapViewDelegate*)mapView.delegate) mapView:mapView zoomToUserLocation:userLocation];
        ((PSMapAtmoMapView *)mapView).lastUserLocation = userLocation;
    }
}


- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    DLogFuncName();
    DLog(@"LocationServicesEnabled => %d", [CLLocationManager locationServicesEnabled]);
    DLog(@"AuthStatus => %d", [CLLocationManager authorizationStatus]);
    DLog(@"Error => %@", [error localizedDescription]);

    [[PSMapAtmoMapAnalytics sharedInstance] trackEventMapDelegateFailedToLocateUser];

#warning todo - show red userlocation icon
    if (![CLLocationManager locationServicesEnabled])
    {
        [[PSMapAtmoMapAnalytics sharedInstance] trackEventMapDelegateLocationServicesDisabled];
        [[NSNotificationCenter defaultCenter] postNotificationName:PSMAPATMO_PUBLIC_MAP_ERROR_LOCATION_SERVICES_NOT_ENABLED object:nil];
    }
    else
    {
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted)
        {
            [[PSMapAtmoMapAnalytics sharedInstance] trackEventMapDelegateLocationStatusRestricted];
            // This application is not authorized to use location services. The user cannot change this application’s status, possibly due to active restrictions such as parental controls being in place.
            [[NSNotificationCenter defaultCenter] postNotificationName:PSMAPATMO_PUBLIC_MAP_ERROR_LOCATION_AUTH_RESTRICTED object:nil];
        }
        else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
        {
            [[PSMapAtmoMapAnalytics sharedInstance] trackEventMapDelegateLocationStatusDenied];
            // The user explicitly denied the use of location services for this application or location services are currently disabled in Settings.
            [[NSNotificationCenter defaultCenter] postNotificationName:PSMAPATMO_PUBLIC_MAP_ERROR_LOCATION_AUTH_DENIED object:nil];
        }
        else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized)
        {
            [[PSMapAtmoMapAnalytics sharedInstance] trackEventMapDelegateLocationStatusAuthorized];
            [[NSNotificationCenter defaultCenter] postNotificationName:PSMAPATMO_PUBLIC_MAP_ERROR_LOCATION_AUTH_DENIED object:nil];
        }
        else
        {
            [[PSMapAtmoMapAnalytics sharedInstance] trackEventMapDelegateLocationStatusUnknown];
            [[NSNotificationCenter defaultCenter] postNotificationName:PSMAPATMO_PUBLIC_MAP_ERROR_LOCATION_UNKNOWN_ERROR object:nil];
        }
    }
}


#pragma mark - Selecting Annotation Views
- (void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated
{
    DLogFuncName();
    
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    DLogFuncName();
    if (view.annotation == mapView.userLocation)
    {
        return;
    }
    
    PSMapAtmoPublicDeviceDict * dict = view.annotation;

    [[PSMapAtmoMapAnalytics sharedInstance] trackPinCallOut];

    if ([[PSMapAtmoUserDefaults sharedInstance] useFahrenheit])
    {
        [[PSMapAtmoMapAnalytics sharedInstance] trackPinCallOutWithUnitInFahrenheit];
    }
    else
    {
        [[PSMapAtmoMapAnalytics sharedInstance] trackPinCallOutWithUnitInCelsius];
    }

    if (mapView.showsUserLocation)
    {
        [[PSMapAtmoMapAnalytics sharedInstance] trackPinCallOutWithDistance];
        if ([[PSMapAtmoUserDefaults sharedInstance] useMiles])
        {
            [[PSMapAtmoMapAnalytics sharedInstance] trackPinCallOutWithDistanceInMiles];
        }
        else
        {
            [[PSMapAtmoMapAnalytics sharedInstance] trackPinCallOutWithDistanceInKilometers];
        }

        [dict setUserLocation:mapView.userLocation.location];
    }
}


- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    DLogFuncName();
    if (view.annotation == mapView.userLocation)
    {
        return;
    }
    
    PSMapAtmoPublicDeviceDict * dict = view.annotation;
    [dict setUserLocation:nil];
}


#pragma mark - Managing the Display of Overlays
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay
{
    DLogFuncName();
    return nil;
}


- (void)mapView:(MKMapView *)mapView didAddOverlayRenderers:(NSArray *)renderers
{
    DLogFuncName();
}


#pragma mark - Loading the Map Data
- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView
{
    DLogFuncName();
    [(PSMapAtmoMapView*)mapView debugRenderingStatus];
}


- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
    DLogFuncName();
    [(PSMapAtmoMapView*)mapView debugRenderingStatus];

    // Init zoomLevel
    _mapZoomLevel = [(PSMapAtmoMapView*)mapView zoomLevel];
    
    // iOS5 / iOS6
    if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        [[(PSMapAtmoMapView*)mapView dataSource] meassuresForMapView:mapView];
    }
}


- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error
{
    DLogFuncName();
}


- (void)mapViewWillStartRenderingMap:(MKMapView *)mapView
{
    DLogFuncName();
    ((PSMapAtmoMapView*)mapView).startRendering = YES;
    [(PSMapAtmoMapView*)mapView debugRenderingStatus];
}


- (void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered
{
    DLogFuncName();
    
    ((PSMapAtmoMapView*)mapView).finishedRendering = fullyRendered;
    [(PSMapAtmoMapView*)mapView debugRenderingStatus];
    
    if (fullyRendered)
    {
        self.mapZoomLevel = [(PSMapAtmoMapView*)mapView zoomLevel];
        [[PSMapAtmoMapAnalytics sharedInstance] trackMapSize:[(PSMapAtmoMapView*)mapView mapSize]];
        
        ((PSMapAtmoMapView*)mapView).startRendering = NO;
        [(PSMapAtmoMapView*)mapView debugRenderingStatus];
        [[(PSMapAtmoMapView*)mapView dataSource] meassuresForMapView:mapView];
    }
}

@end
