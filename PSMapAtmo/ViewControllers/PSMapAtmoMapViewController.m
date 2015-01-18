//
//  PSMapAtmoMapViewController.m
//  PSMapAtmo
//
//  Created by Philip Schneider on 12.12.13.
//  Copyright (c) 2013 phschneider.net. All rights reserved.
//

#import "PSMapAtmoPublicApi.h"

#import "PSMapAtmoMapView.h"
#import "PSMapAtmoMapViewController.h"
#import "PSMapAtmoAppearance.h"
#import "PSMapAtmoNavigationController.h"
#import "PSMapAtmoUserDefaults.h"
#import "PSMapAtmoLocalStorage.h"
#import "PSMapAtmoPublicDeviceDict.h"

#import "TSMessage.h"

#import "PSMapAtmoMapViewDelegate.h"
#import "PSMapAtmoMapAnalytics.h"
#import "PSMapAtmoMapImprintViewController.h"

#define kNavBarDefaultPosition CGPointMake(160,22)


#define FULLSCREE_HINT_ANIMATION_DURATION   1.0

#import "PSMapAtmoSettingsViewController.h"
#import "PSMapAtmoLocation.h"
#import "NSString+MKCoordinateRegion.h"
#import "PSMapAtmoAppVersion.h"

// https://twitter.com/gparker/status/236582488355520512
#define OBJC_OLD_DISPATCH_PROTOTYPES 0


@interface PSMapAtmoMapViewController ()
@property (nonatomic) PSMapAtmoMapView * mapView;
@property (nonatomic) BOOL warningAlreadyShown;
@property (nonatomic) BOOL prefersStatusBarHidden;

@property (nonatomic) UIToolbar * toolBar;
@property (nonatomic) int bytesReceived;
@property (nonatomic) NSTimeInterval lastCheck;

@property (nonatomic) UIView * statusBarView;
@property (nonatomic) id<PSMapAtmoMapViewDelegate> mapViewDelegate;
@property (nonatomic) id<PSMapAtmoMapViewDataSource> mapViewDataSource;

@property (nonatomic) UILongPressGestureRecognizer * longPressRecognizer;

@end

@implementation PSMapAtmoMapViewController

#define WARNING_LIMIT   1000

static PSMapAtmoMapViewController* instance = nil;
+ (PSMapAtmoMapViewController*) sharedInstance {
    @synchronized (self)
    {
        if (instance == nil)
        {
            [PSMapAtmoMapViewController new];
        }
    }
    return instance;
}


- (id) init
{
    DLogFuncName();
    NSAssert(!instance, @"Instance of PSMapAtmoMapViewController already exists");
    self = [super init];
    if (self)
    {
        [[PSMapAtmoAppearance sharedInstance] applyGlobalInterfaceAppearance];

        [[NSMutableArray alloc] initWithCapacity:5000];
        
        self.mapViewDelegate =  [[PSMapAtmoMapViewDelegate alloc] init];
        self.mapViewDataSource = [[PSMapAtmoMapViewDataSource alloc] init];

        CGRect frame = self.view.bounds;
        
        
        self.mapView = [[PSMapAtmoMapView alloc] initWithFrame:frame];
        self.mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.mapView.delegate = self.mapViewDelegate;
        self.mapView.dataSource = self.mapViewDataSource;
        [self.mapView setMapType:MKMapTypeStandard];
        [self.mapView setZoomEnabled:YES];
        [self.mapView setScrollEnabled:YES];
        self.mapView.mapType = [[PSMapAtmoUserDefaults sharedInstance] mapType];

        // nicht in iOS6
        if ([self.mapView respondsToSelector:@selector(setRotateEnabled:)])
        {
            self.mapView.rotateEnabled = NO; // API only works for looking norh...
        }
        
        [self.view addSubview:self.mapView];

        self.toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,self.view.bounds.size.height-40,self.view.bounds.size.width,40)];
        self.toolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        [self.view addSubview:self.toolBar];
        [self initToolBar];

        self.bytesReceived = 0;
        self.warningAlreadyShown = NO;
        self.lastCheck = [[NSDate date] timeIntervalSince1970];

        CFAbsoluteTimeGetCurrent();
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addDevice:) name:PSMAPATMO_PUBLIC_DEVICE_ADDED_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedData:) name:PSMAPATMO_API_DATA_RECEIVED object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mapChanged:) name:PSMAPATMO_PUBLIC_MAP_CHANGED_NOTIFICATION object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mapUpdateUserLocation:) name:PSMAPATMO_PUBLIC_MAP_UPDATED_USER_LOCATION object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearMap:) name:PSMAPATMO_PUBLIC_CLEAR_MAP object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearMap:) name:PSMAPATMO_PUBLIC_CLEAR_ALL object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeType:) name:@"PSMAPATMO_CHANGE_MAP_TYPE" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload) name:PSMAPATMO_COOKIE_UPDATED_NOTIFICICATION object:nil];

        self.longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
        {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[PSMapAtmoAppearance sharedInstance]fullScreenImage] style:UIBarButtonItemStylePlain target:self action:@selector(enterFullScreen:)];
        }
    }
    instance = self;
    return self;
}

#pragma mark - Notification
- (void) reload
{
    DLogFuncName();
    
    // Reload Annotations ...
#ifndef CONFIGURATION_AppStore
    dispatch_async(dispatch_get_main_queue(),^{
        [[[UIAlertView alloc] initWithTitle:@"Reload Annotions" message:@"We've got a new cookie" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    });
#endif
    
    [self.mapView.delegate mapViewDidFinishLoadingMap:self.mapView];
}

#pragma mark - View
- (void)viewWillAppear:(BOOL)animated
{
    DLogFuncName();

    PSMapAtmoLocation *location = [[PSMapAtmoUserDefaults sharedInstance] location];
    NSLog(@"Location => %@", location);
    [self showLocation:location];
}


- (void) viewDidAppear:(BOOL)animated
{
    DLogFuncName();
    [super viewDidAppear:animated];
    [self debugViewFrames];

    [[PSMapAtmoMapAnalytics sharedInstance] trackView:@"map"];
    
    if ([[PSMapAtmoAppVersion sharedInstance] isFirstStartForCurrentAppVersion])
    {
        [self firstStart:nil];
    }
}


#pragma mark - PSMapAtmoLocation
- (void) showLocation:(PSMapAtmoLocation *)location
{
    DLogFuncName();
    switch (location.locationType)
    {
        case PSMapAtmoLocationTypeDefault:
            // Do nothing - show default map status
            break;

        case PSMapAtmoLocationTypeUserLocation:
            [self.mapView setShowsUserLocation:YES];
            break;

        case PSMapAtmoLocationTypeCurrentLocation:
            {
                MKCoordinateRegion locationRegion = location.region;
                NSLog(@"REGION = %@", NSStringFromMKCoordinateRegion(locationRegion));

                [self.mapView setRegion:locationRegion];
            }
            break;

        case PSMapAtmoLocationTypeLastLocation:
            {
                MKCoordinateRegion locationRegion = location.region;
                NSLog(@"REGION = %@", NSStringFromMKCoordinateRegion(locationRegion));

                [self.mapView setRegion:locationRegion];
            }
            break;

        default:
            break;
    }

}


#pragma mark - StatusBar
//// NOT USED IN BETA AND DEBUG!?
//- (BOOL)prefersStatusBarHidden
//{
//    DLogFuncName();
//    return YES;
//}
//
//
//// NOT USED
//- (UIStatusBarAnimation) preferredStatusBarUpdateAnimation
//{
//    DLogFuncName();
//    return UIStatusBarAnimationSlide;
//}


#import <objc/message.h>
- (void) setStatusBarAndNavigationBarHidden:(BOOL)hidden withDuration:(CGFloat)duration
{
    BOOL customAnimationsWorked = NO;
    @try {
        // Get the class
        Class statusBarHideParameterClass = NSClassFromString([NSString stringWithFormat:@"%@Stat%@B%@eA%@Param%@rs",@"UI",@"us",@"arHid",@"nimation",@"ete"]);
        if (statusBarHideParameterClass)
        {
//            DLog(@"statusBarHideParameterClass = %@", [statusBarHideParameterClass allIvars]);
//            DLog(@"statusBarHideParameterClass = %@", [statusBarHideParameterClass allProperties]);
            
            // Create the UIStatusBarHideAnimationParameters object and check if it was successful.
            id animParameters = ((id(*)(id,SEL))objc_msgSend)([statusBarHideParameterClass alloc], NSSelectorFromString(@"initWithDefaultParameters"));
            if (animParameters)
            {
                // Set animation parameters
                [animParameters setValue:@(duration) forKey:@"duration"];
                [animParameters setValue:@(UIStatusBarAnimationSlide) forKey:@"hideAnimation"];
                
                CGFloat slideHeight = fminf(CGRectGetHeight(self.navigationController.navigationBar.frame),CGRectGetWidth(self.navigationController.navigationBar.frame));
//                fminf(CGRectGetHeight(UIApplication.sharedApplication.statusBarFrame), CGRectGetWidth(UIApplication.sharedApplication.statusBarFrame));
                [animParameters setValue:@(slideHeight) forKey:[NSString stringWithFormat:@"additionalSlideHeight"]];
                
//                NSLog(@"AnimParams = %@", [animParameters allIvars]);
//                NSLog(@"AnimParams = %@", [animParameters valueForKeys:[animParameters allIvars]]);
            }
            
            
            // Call setStatusBarHidden:WithParameters: on UIApplication.
            // Selector creation will never fail, but might not exists
//            if (SYSTEM_VERSION_LESS_THAN(@"7.0"))
//            {
//                SEL statusBarHiddenWithParams = NSSelectorFromString([NSString stringWithFormat:@"setStatusBarHidden:animationParameters:"]);
//                if ([UIApplication.sharedApplication respondsToSelector:statusBarHiddenWithParams])
//                {
//                    ((void(*)(id, SEL, BOOL, id))objc_msgSend)(UIApplication.sharedApplication,statusBarHiddenWithParams,hidden,animParameters);
//                    customAnimationsWorked = YES;
//                }
//            }
//            else
//            {
                SEL statusBarHiddenWithParams = NSSelectorFromString([NSString stringWithFormat:@"se%@atusB%@idden:animat%@meters:changeAp%@:",@"tSt",@"arH",@"ionPara",@"plicationFlag"]);
                if ([UIApplication.sharedApplication respondsToSelector:statusBarHiddenWithParams])
                {
                    ((void(*)(id, SEL, BOOL, id, BOOL))objc_msgSend)(UIApplication.sharedApplication,statusBarHiddenWithParams,hidden,animParameters,NO);
                    customAnimationsWorked = YES;
                }
//            }
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"didn't work, falling back to default animation.");
    }
    
    if (!customAnimationsWorked)
    {
        [UIApplication.sharedApplication setStatusBarHidden:hidden withAnimation:UIStatusBarAnimationSlide];
    }
}


#pragma mark - FullScreen
- (void) enterFullScreen:(id)sender
{
    DLogFuncName();
    
    [[PSMapAtmoUserDefaults sharedInstance] setEnteringFullScreenMode];
    [[PSMapAtmoMapAnalytics sharedInstance] trackEventEnteredFullScreen];
    
    [self.view setUserInteractionEnabled:NO];
    [self setStatusBarAndNavigationBarHidden:YES withDuration:1.5];

    
    [UIView animateWithDuration:1.5
                          delay:.25
                        options: UIViewAnimationCurveLinear
                     animations:^{
                         
                         CGRect statusBarFrame = UIApplication.sharedApplication.statusBarFrame;
                         CGFloat statusBarHeight = fminf(CGRectGetHeight(statusBarFrame),CGRectGetWidth(statusBarFrame));
                     
                         CGRect frame = self.toolBar.frame;
                         frame.origin.y += frame.size.height;
                         self.toolBar.frame = frame;

                         UINavigationBar *navBar = self.navigationController.navigationBar;
//                         NSLog(@"%@",NSStringFromCGRect(navBar.frame));
                         navBar.frame = CGRectMake(0.f,-CGRectGetHeight(navBar.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(navBar.frame));
//                         NSLog(@"%@",NSStringFromCGRect(navBar.frame));

                         if (SYSTEM_VERSION_LESS_THAN(@"7.0"))
                         {
                             // Zuerst die Höhe abziehen damit kein Freiraum unter der NavBar und der StatusBar entsteht
                             frame = self.mapView.frame;
                             frame.origin.y = -64;
                             frame.size.height = 768;
                             self.mapView.frame = frame;
                         }
                     }
                     completion:^(BOOL finished){
//                         NSLog(@"Completion Finished = %d", finished);
                         [self.navigationController setNavigationBarHidden:YES animated:YES];

                         if (finished)
                         {
                             if (SYSTEM_VERSION_LESS_THAN(@"7.0"))
                             {
                                 // Dann nur auf die Höhe der StatusBar setzen da diese Ausgeblendet und nicht erkannt wird ...
                                 CGRect frame = self.mapView.frame;
                                 frame.origin.y = -20;
                                 frame.size.height = 768;
                                 self.mapView.frame = frame;
                             }
                             
                             [self.view addGestureRecognizer:self.longPressRecognizer];
                             
                             UITapGestureRecognizer * tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
                             tapRecognizer.delegate = self;
                             [tapRecognizer requireGestureRecognizerToFail:self.longPressRecognizer];
                             [self.view addGestureRecognizer:tapRecognizer];
                             

                             // Damit aus Multitasking nicht plötzliche NavBar angezeigt wird
//                             self.navigationController.navigationBarHidden = YES;
                             [self debugViewFrames];
                             
                             if ([[PSMapAtmoUserDefaults sharedInstance] firstUseOfFullScreenMode])
                             {
                                 [self showFullScreenHelpMessage];
                             }
                             
//                             [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(relayoutForFullscreen) name:UIApplicationDidBecomeActiveNotification object:nil];
                         }
                         [self.view setUserInteractionEnabled:YES];
                     }];
}

#pragma - Gestures
//// Asks the delegate if a gesture recognizer should begin interpreting touches.
//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
//{
//    return YES;
//}

#define TOUCH_FRAME_SIZE 60
- (CGRect) leftFrame
{
    return CGRectMake(0,0,TOUCH_FRAME_SIZE,768);
}


- (CGRect) rightFrame
{
    return CGRectMake(1024-TOUCH_FRAME_SIZE,0,TOUCH_FRAME_SIZE,768);
}


- (CGRect) toolBarFrame
{
    DLogFuncName();
    return CGRectMake(TOUCH_FRAME_SIZE,768-TOUCH_FRAME_SIZE,1024-TOUCH_FRAME_SIZE-TOUCH_FRAME_SIZE,TOUCH_FRAME_SIZE);
}


- (CGRect) navBarFrame
{
    DLogFuncName();
    return CGRectMake(TOUCH_FRAME_SIZE,0,1024-TOUCH_FRAME_SIZE-TOUCH_FRAME_SIZE,TOUCH_FRAME_SIZE);
}


//Ask the delegate if a gesture recognizer should receive an object representing a touch.
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    CGRect navBarFrame = [self navBarFrame];
    CGRect toolBarFrame = [self toolBarFrame];
    
    CGRect leftFrame = [self leftFrame];
    CGRect rightFrame = [self rightFrame];
    
    CGPoint point = [touch locationInView:self.view];

    
//    NSLog(@"navBaFrame = %@", NSStringFromCGRect(navBarFrame));
//    NSLog(@"toolBarFrame = %@", NSStringFromCGRect(toolBarFrame));
//    NSLog(@"cgPoint = %@",NSStringFromCGPoint(point));
    
    if (CGRectContainsPoint(navBarFrame, point))
    {
        return YES;
    }
    else if (CGRectContainsPoint(toolBarFrame, point))
    {
        return YES;
    }
    else if (CGRectContainsPoint(leftFrame, point))
    {
        return YES;
    }
    else if (CGRectContainsPoint(rightFrame, point))
    {
        return YES;
    }
    return NO;
}

- (void) showFullScreenHelpMessage
{
    DLogFuncName();
    [TSMessage showNotificationInViewController:self
                                          title:NSLocalizedString(@"Fullscreen mode", nil)
                                       subtitle:@"You can leave fullscreen mode with one tap on the edges of the screen. Need help? Just long tap on the screen to see these areas!"
                                           type:TSMessageNotificationTypeWarning
                                       duration:TSMessageNotificationDurationEndless
                                       callback:nil
                                    buttonTitle:NSLocalizedString(@"Ok",nil)
                                 buttonCallback:nil
                                     atPosition:TSMessageNotificationPositionBottom
                            canBeDismisedByUser:YES];
}


- (void) tapped:(UIGestureRecognizer*)recognizer
{
    DLogFuncName();
//    NSLog(@"State = %d", recognizer.state);
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        [self.view removeGestureRecognizer:recognizer];
        [self.view removeGestureRecognizer:self.longPressRecognizer];
        [self exitFullScreen];
    }
//
//    if (recognizer.state == UIGestureRecognizerStateChanged) {
//        CGPoint newTouchPoint = [recognizer locationInView:[self view]];
//        NSLog(@"%@",NSStringFromCGPoint(newTouchPoint));
//    
////        CGFloat dx = newTouchPoint.x - initTouchPoint.x;
////        CGFloat dy = newTouchPoint.y - initTouchPoint.y;
////        if (sqrt(dx*dx + dy*dy) > 25.0) {
//            recognizer.enabled = NO;
//            recognizer.enabled = YES;
////        }
//        NSLog(@"FAILED!?");
//    }
//    else if (recognizer.state != UIGestureRecognizerStateFailed && recognizer.state != UIGestureRecognizerStateCancelled)
//    {
//        NSLog(@"OK");
//    }
}


- (void) longPress:(UIGestureRecognizer*)recognizer
{
    DLogFuncName();
    
    if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state != UIGestureRecognizerStateBegan)
    {
//        [self.view removeGestureRecognizer:recognizer];
//        [self exitFullScreen:nil];
        
        [self showFullScreenExitViews];
    }
}


- (void) showFullScreenExitViews
{
    DLogFuncName();
    
    [[PSMapAtmoMapAnalytics sharedInstance] trackEventFullScreenShowEdges];
    int tag = 444;
    for (NSValue * orgFrame in @[ [NSValue valueWithCGRect:[self toolBarFrame]], [NSValue valueWithCGRect:[self navBarFrame]], [NSValue valueWithCGRect:[self rightFrame]], [NSValue valueWithCGRect:[self leftFrame]] ])
    {
    
        CGRect frame = [orgFrame CGRectValue];
        switch (tag) {
            case 444:
                // TooLBar
                frame.origin.y+=frame.size.height;
                break;
            case 445:
                // NavBar
                frame.origin.y-=frame.size.height;
                break;
            case 446:
                // Right
                frame.origin.x+=frame.size.width;
                break;
            case 447:
                // Left
                frame.origin.x-=frame.size.width;
                break;
        }
        
        UIView * view = [self.view viewWithTag:tag];
        if (!view)
        {
//            NSLog(@"New view");
            view = [[UIView alloc] initWithFrame:frame];
        }
        view.frame = frame;
        view.tag = tag;
        view.backgroundColor = [UIColor darkGrayColor];
        view.alpha = 0.5;
        [self.view addSubview:view];
        
        tag++;
        
        [UIView animateWithDuration:FULLSCREE_HINT_ANIMATION_DURATION
                              delay:0
                            options:UIViewAnimationCurveEaseIn
                         animations:^{
                             CGRect frame = view.frame;
                             switch (view.tag) {
                                 case 444:
                                     // TooLBar
                                     frame.origin.y-=frame.size.height;
                                     break;
                                 case 445:
                                     // NavBar
                                     frame.origin.y+=frame.size.height;
                                     break;
                                 case 446:
                                     // Right
                                     frame.origin.x-=frame.size.width;
                                     break;
                                 case 447:
                                     // Left
                                     frame.origin.x+=frame.size.width;
                                     break;
                             }
                             
                             view.frame = frame;
                         }
                         completion:^(BOOL finished)
         {
             if (tag == 447)
             {
                 [self performSelector:@selector(hideFullScreenExitViews) withObject:nil afterDelay:2.5];
             }
         }];
    }
}


- (void) hideFullScreenExitViews
{
    DLogFuncName();
    [UIView animateWithDuration:FULLSCREE_HINT_ANIMATION_DURATION
                          delay:.0
                        options:UIViewAnimationCurveEaseIn
                     animations:^{
                         UIView * view = [self.view viewWithTag:444];
                         CGRect frame;
                         if (view)
                         {
                             frame = view.frame;
                             
                             // TooLBar
                             frame.origin.y+=frame.size.height;
                             view.frame = frame;
                         }
                         
                         view = [self.view viewWithTag:445];
                         if (view)
                         {
                             frame = view.frame;
                             
                             // NavBar
                             frame.origin.y-=frame.size.height;
                             view.frame = frame;
                         }
                         
                         view = [self.view viewWithTag:446];
                         if (view)
                         {
                             frame = view.frame;
                             
                             // Right
                             frame.origin.x+=frame.size.width;
                             view.frame = frame;
                         }
                         
                         view = [self.view viewWithTag:447];
                         if (view)
                         {
                             frame = view.frame;
                             
                             // Left
                             frame.origin.x-=frame.size.width;
                             view.frame = frame;
                         }
                     }
                     completion:^(BOOL finished)
                    {

                    }];
}


- (void) showFullScreen:(BOOL) shouldShow
{
    DLogFuncName();
    CGFloat duration = 2.5f;

    [self setStatusBarAndNavigationBarHidden:shouldShow withDuration:duration];

    [UIView animateWithDuration:duration
                          delay:0
                        options: UIViewAnimationOptionTransitionNone | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionOverrideInheritedDuration | UIViewAnimationOptionAllowAnimatedContent
                     animations:^
                            {


                            CGRect statusBarFrame = UIApplication.sharedApplication.statusBarFrame;
                            CGFloat statusBarHeight = fminf(CGRectGetHeight(statusBarFrame),CGRectGetWidth(statusBarFrame));
                                
                            // Update navigation bar frame
                            UINavigationBar *navBar = self.navigationController.navigationBar;
//                            NSLog(@"%@",NSStringFromCGRect(navBar.frame));
                            navBar.frame = CGRectMake(0.f,shouldShow ? -CGRectGetHeight(navBar.frame) : statusBarHeight, CGRectGetWidth(self.view.frame), CGRectGetHeight(navBar.frame));
//                            NSLog(@"%@",NSStringFromCGRect(navBar.frame));
                                
                                CGRect frame = self.mapView.frame;
                                frame.origin.y = 0;
                                frame.size.height = 768-40-20;
                                self.mapView.frame = frame;
                                
                                
                                frame = self.toolBar.frame;
                                frame.origin.y -= frame.size.height;
                                self.toolBar.frame = frame;


                        }
                     completion:^(BOOL finished)
                        {

                            [UIView animateWithDuration:duration animations:^{
                                [self.navigationController setNavigationBarHidden:shouldShow animated:YES];

                            }];
                        }];



}


- (void) exitFullScreen
{
    DLogFuncName();
    
    [[PSMapAtmoUserDefaults sharedInstance] setLeavingFullScreenMode];
    [[PSMapAtmoMapAnalytics sharedInstance] trackEventLeavedFullScreen];
    
    [self hideFullScreenExitViews];

    [self.view setUserInteractionEnabled:NO];
    [self setStatusBarAndNavigationBarHidden:NO withDuration:1.5];

    if (SYSTEM_VERSION_LESS_THAN(@"7.0"))
    {
        [self showFullScreen:NO];
//        [self exitFullScreenForIos6];
    }
    else
    {
        [self exitFullScreenForIos7];
    }
}


- (void) exitFullScreenForIos7
{
    DLogFuncName();
    [UIView animateWithDuration:1.5
                          delay:0
                        options: UIViewAnimationCurveLinear
                     animations:^{
                         
                         [self.navigationController setNavigationBarHidden:NO animated:NO];
                         
                          CGRect statusBarFrame = UIApplication.sharedApplication.statusBarFrame;
                          CGFloat statusBarHeight = fminf(CGRectGetHeight(statusBarFrame),CGRectGetWidth(statusBarFrame));
                         
                          CGRect frame = self.toolBar.frame;
                          frame.origin.y -= frame.size.height;
                          self.toolBar.frame = frame;
                         
                          UINavigationBar *navBar = self.navigationController.navigationBar;
//                          NSLog(@"%@",NSStringFromCGRect(navBar.frame));
                          navBar.frame = CGRectMake(0.f,statusBarHeight, CGRectGetWidth(self.view.frame), CGRectGetHeight(navBar.frame));
//                          NSLog(@"%@",NSStringFromCGRect(navBar.frame));
                      }
                      completion:^(BOOL finished)
                      {
//                          NSLog(@"Completion Finished = %d", finished);
//                          if (finished)
//                          {
//                              
//                          }
                          [self.view setUserInteractionEnabled:YES];
                      }];
}


- (void) exitFullScreenForIos6
{
    DLogFuncName();
    [UIView animateWithDuration:1.5
                          delay:0
                        options: UIViewAnimationCurveLinear
                     animations:^{

//
//                         
//                     }
//                     completion:^(BOOL finished){
//                         
//                         //                     }];
//                         //
//                         [UIView animateWithDuration:1.5
//                                               delay:0
//                                             options: UIViewAnimationCurveEaseIn
//                                          animations:^{

                                              
                                              CGRect statusBarFrame = UIApplication.sharedApplication.statusBarFrame;
                                              CGFloat statusBarHeight = fminf(CGRectGetHeight(statusBarFrame),CGRectGetWidth(statusBarFrame));
                                              
                                              //                         CGRect frame = CGRectZero;
                                              
//                                              CGRect frame = self.toolBar.frame;
//                                              frame.origin.y -= frame.size.height;
//                                              self.toolBar.frame = frame;

                                              if (SYSTEM_VERSION_LESS_THAN(@"7.0"))
                                              {

                                                  CGRect frame = self.mapView.frame;
                                                  frame.origin.y = 0;
                                                  frame.size.height = 768-44-20;
                                                  self.mapView.frame = frame;
                                              }
                                              //                         else
                                              //                         {
                                              //                             frame = self.navigationController.navigationBar.frame;
                                              //                             frame.origin.y = 0;
                                              //                             frame.size.height = 48 + 20;
                                              //                             self.navigationController.navigationBar.frame = frame;
                                              //                         }
                                              
                                              UINavigationBar *navBar = self.navigationController.navigationBar;
//                                              NSLog(@"%@",NSStringFromCGRect(navBar.frame));
                                              navBar.frame = CGRectMake(0.f,statusBarHeight, CGRectGetWidth(self.view.frame), CGRectGetHeight(navBar.frame));
//                                              NSLog(@"%@",NSStringFromCGRect(navBar.frame));
                         
                                              
                                          }
                                          completion:^(BOOL finished){
                                              [self.navigationController setNavigationBarHidden:NO animated:NO];

//                                              NSLog(@"Completion Finished = %d", finished);
                                          }];
//                     }];
}

#pragma mark - Debug
- (void)debugViewFrames
{
    return;
    DLog(@"View Frame = %@",NSStringFromCGRect(self.view.frame));
    DLog(@"View Bounds = %@",NSStringFromCGRect(self.view.bounds));
    DLog(@"Map Frame = %@",NSStringFromCGRect(self.mapView.frame));
    DLog(@"Map Bounds = %@",NSStringFromCGRect(self.mapView.bounds));
    DLog(@"NavBar Frame = %@",NSStringFromCGRect(self.navigationController.navigationBar.frame));
    DLog(@"NavBar Bounds= %@",NSStringFromCGRect(self.navigationController.navigationBar.bounds));
    DLog(@"ToolBar Frame = %@",NSStringFromCGRect(self.toolBar.frame));
    DLog(@"ToolBar Bounds = %@",NSStringFromCGRect(self.toolBar.bounds));
    DLog(@"Window Frame = %@",NSStringFromCGRect(self.view.window.frame));
    DLog(@"Window Bounds = %@",NSStringFromCGRect(self.view.window.bounds));
}


#pragma mark -
- (void) mapUpdateUserLocation:(NSNotification*)notification
{
    DLogFuncName();
    if (![NSThread isMainThread])
    {
        dispatch_async(dispatch_get_main_queue(),^{
            [self mapUpdateUserLocation:notification];
        });
        return;
    }
    
//    MKUserLocation * userLocation = [notification.userInfo objectForKey:@"userLocation"];
    
//    [TSMessage showNotificationInViewController:self
//                                          title:NSLocalizedString(@"UserLocationUpdate", nil)
//                                       subtitle:[NSString stringWithFormat:@"Date %@ => horizontal %.2f, vertical %.2f",userLocation.location.timestamp , userLocation.location.horizontalAccuracy, userLocation.location.verticalAccuracy ]
//                                           type:TSMessageNotificationTypeSuccess
//                                       duration:TSMessageNotificationDurationAutomatic
//                                       callback:nil
//                                    buttonTitle:NSLocalizedString(@"Ok",nil)
//                                 buttonCallback:nil
//                                     atPosition:TSMessageNotificationPositionBottom
//                            canBeDismisedByUser:YES];
    
}


#pragma mark - Api Request
- (NSString*)humanReadableSizeFromInt:(int)sizeInInt
{
    DLogFuncName();
    int intSize = sizeInInt;
    float floatSize = (float) (sizeInInt*1.0);
    
    NSString *formatted = nil;
    
    if (intSize < 1023) {
        formatted = [NSString stringWithFormat:@"%i bytes", intSize];
    }
    
    floatSize = floatSize / 1024;
    
    if (floatSize > 1 && floatSize < 1023) {
        formatted = [NSString stringWithFormat:@"%1.1f KB", floatSize];
    }
    
    floatSize = floatSize / 1024;
    
    if (floatSize > 1 && floatSize < 1023) {
        formatted = [NSString stringWithFormat:@"%1.1f MB", floatSize];
    }
    
    floatSize = floatSize / 1024;
    
    if (!formatted) {
        formatted = [NSString stringWithFormat:@"%1.1f GB", floatSize];
    }
    
    DLog(@"Formatted = %@", formatted);
    return formatted;
}


#pragma mark - Notifications
- (void) clearMap:(NSNotification*)notification
{
    DLogFuncName();
    if (![NSThread isMainThread])
    {
        dispatch_async(dispatch_get_main_queue(),^{
            [self clearMap:notification];
        });
        return;
    }

    id userLocation = [self.mapView userLocation];
    [self.mapView removeAnnotations:[self.mapView annotations]];

    if ( userLocation != nil && [self.mapView showsUserLocation])
    {
        [self.mapView addAnnotation:userLocation]; // will cause user location pin to blink
    }

    [self updateToolBar];
}


- (void) changeType:(NSNotification*)notification
{
    DLogFuncName();

    if (![NSThread isMainThread])
    {
        dispatch_async(dispatch_get_main_queue(),^{
            [self changeType:notification];
        });
        return;
    }

    if ([notification userInfo][@"mapType"])
    {
        MKMapType mapType= (MKMapType) [[notification userInfo][@"mapType"] intValue];
        self.mapView.mapType = mapType;
    }
}


- (void) firstStart:(NSNotification*)note
{
    DLogFuncName();
    if (![NSThread isMainThread])
    {
        dispatch_async(dispatch_get_main_queue(),^{
            [self firstStart:note];
        });
        return;
    }
    
    [self infoButtonTouched:nil];
}


- (void) receivedData:(NSNotification*)note
{
    DLogFuncName();
    if (![NSThread isMainThread])
    {
        dispatch_async(dispatch_get_main_queue(),^{
            [self receivedData:note];
        });
        return;
    }
    
    
    int bytes = [note.userInfo[@"size"] integerValue];
    self.bytesReceived += bytes;
    DLog(@"Size = %d",self.bytesReceived);

    [self updateToolBarSizeItem];
}



- (void) addDevice:(NSNotification*)notification
{
    DLogFuncName();
    PSMapAtmoPublicDeviceDict * device = notification.userInfo[@"device"];
    if (device)
    {
        dispatch_sync(dispatch_get_main_queue(),^{
            [self.mapView addAnnotation:device];
            [self updateToolBarCountItem];
        });
    }
}


- (void) mapChanged:(NSNotification*)notification
{
    DLogFuncName();
    
    if (![NSThread isMainThread])
    {
        dispatch_async(dispatch_get_main_queue(),^{
            [self updateToolBarCountItem];
            [self updateToolBarLocateItem];
        });
        return;
    }
    
    [self updateToolBarCountItem];
    [self updateToolBarLocateItem];
}



#pragma mark - ToolBar
#define TABBAR_LOCATE_ITEM_INDEX    0
#define TABBAR_SIZE_ITEM_INDEX      1
#define TABBAR_COUNT_ITEM_INDEX     3
#define TABBAR_INFO_ITEM_INDEX      5

- (void) initToolBar
{
    DLogFuncName();
    UIBarButtonItem * flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                    target:nil
                                                                                    action:nil];
    
    UIBarButtonItem * sizeItem = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"... received"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:nil
                                                                 action:nil];
    sizeItem.enabled = NO;
    
    UIBarButtonItem * countItem = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"%d Weatherstations found (%d presented)", [[PSMapAtmoLocalStorage sharedInstance] numberOfPublicDevices], [[self.mapView annotationsInMapRect:self.mapView.visibleMapRect] count]]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:nil
                                                                  action:nil];
    countItem.enabled = NO;

    UIBarButtonItem * locateItem = [[UIBarButtonItem alloc] initWithImage:[[PSMapAtmoAppearance sharedInstance] locateImage]
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(locateItemTouched:)];

    UIImage * infoImage = nil;

    UIBarButtonItem * infoItem = [[UIBarButtonItem alloc] initWithImage:[[PSMapAtmoAppearance sharedInstance] infoImage]
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(infoButtonTouched:)];

    NSMutableArray * items = [[NSMutableArray alloc] initWithCapacity:10];

    [items insertObject:locateItem atIndex: TABBAR_LOCATE_ITEM_INDEX];
    [items insertObject:sizeItem atIndex:TABBAR_SIZE_ITEM_INDEX];
    [items insertObject:flexibleSpace atIndex:2];
    [items insertObject:countItem atIndex:TABBAR_COUNT_ITEM_INDEX];
    [items insertObject:flexibleSpace atIndex:4];
    [items insertObject:infoItem atIndex:TABBAR_INFO_ITEM_INDEX];

    [self.toolBar setItems:items];
}


- (void) updateToolBar
{
    DLogFuncName();
    [self updateToolBarSizeItem];
    [self updateToolBarCountItem];
    [self updateToolBarLocateItem];
}


- (void) updateToolBarSizeItem
{
    DLogFuncName();
    if (![NSThread isMainThread])
    {
        dispatch_async(dispatch_get_main_queue(),^{
            [self updateToolBarSizeItem];
        });
        return;
    }
    
    UIBarButtonItem * sizeItem = self.toolBar.items[TABBAR_SIZE_ITEM_INDEX];
    sizeItem.title = [NSString stringWithFormat:@"%@ received", [self humanReadableSizeFromInt:self.bytesReceived]];
}


- (void) updateToolBarCountItem
{
    DLogFuncName();
    if (![NSThread isMainThread])
    {
        dispatch_async(dispatch_get_main_queue(),^{
            [self updateToolBarCountItem];
        });
        return;
    }
    
    int visibleCount = [[self.mapView annotationsInMapRect:self.mapView.visibleMapRect] count];
    if (self.mapView.userLocationVisible)
    {
        if ([[self.mapView annotationsInMapRect:self.mapView.visibleMapRect] containsObject:self.mapView.userLocation])
        {
            DLog(@"Shows UserLocation ");
            visibleCount = visibleCount-1;
        }
    }
    
    int overallCount = [[PSMapAtmoLocalStorage sharedInstance] numberOfPublicDevices];
    
    if (visibleCount > WARNING_LIMIT && !self.warningAlreadyShown)
    {
        self.warningAlreadyShown = YES;
        
        [TSMessage showNotificationInViewController:self
                                              title:NSLocalizedString(@"Warning", nil)
                                           subtitle:NSLocalizedString(@"You have reached a cirtical number of POIs. You'll get the best performance when zooming in!", nil)
                                               type:TSMessageNotificationTypeWarning
                                           duration:TSMessageNotificationDurationEndless
                                           callback:nil
                                        buttonTitle:NSLocalizedString(@"Ok",nil)
                                     buttonCallback:nil
                                         atPosition:TSMessageNotificationPositionBottom
                                canBeDismisedByUser:YES];

    }

    if (self.lastCheck < [[NSDate date] timeIntervalSince1970] - 60)
    {
        [[PSMapAtmoMapAnalytics sharedInstance] trackOverallCount:overallCount];
        [[PSMapAtmoMapAnalytics sharedInstance] trackVisibleCount:visibleCount];
    
        [[PSMapAtmoMapAnalytics sharedInstance] trackOverallCountAfter60Seconds:overallCount];
        [[PSMapAtmoMapAnalytics sharedInstance] trackVisibleCounterAfter60Seconds:visibleCount];
    }
    
    UIBarButtonItem * sizeItem = self.toolBar.items[TABBAR_COUNT_ITEM_INDEX];
    sizeItem.title = [NSString stringWithFormat:@"%d Weatherstations found (%d presented)", overallCount , visibleCount];
}


- (void) updateToolBarStorageSize
{
    DLogFuncName();
    return;
    
    if (![NSThread isMainThread])
    {
        dispatch_async(dispatch_get_main_queue(),^{
            [self updateToolBarStorageSize];
        });
        return;
    }
    
    UIBarButtonItem * sizeItem = self.toolBar.items[TABBAR_LOCATE_ITEM_INDEX];
    sizeItem.title = [NSString stringWithFormat:@"%@ cached", [self humanReadableSizeFromInt:[[PSMapAtmoLocalStorage sharedInstance] storageSize] ]];
}


- (void) updateToolBarLocateItem
{
    DLogFuncName();
    
    [self highlightToolBarLocateItem:([(PSMapAtmoMapViewDelegate*)self.mapView.delegate mapViewShowsUserLocationCentered:self.mapView])];
}


- (void) highlightToolBarLocateItem:(BOOL)highlight
{
    DLogFuncName();
    
    UIBarButtonItem * locateItem = self.toolBar.items[TABBAR_LOCATE_ITEM_INDEX];
    if (highlight)
    {
        DLog(@"HIGHLIHGT");
        locateItem.image = [[PSMapAtmoAppearance sharedInstance] locateImageActive];
    }
    else if (!highlight)
    {
        DLog(@"UNHIGHLIGH")
        locateItem.image = [[PSMapAtmoAppearance sharedInstance] locateImageInactive];
    }
}


#pragma mark - Button Touched
- (void) locateItemTouched:(id)sender
{
    DLogFuncName();
//    UIBarButtonItem item = sender;

    DLog(@"showsLocation %d, isVisible %d", self.mapView.showsUserLocation, self.mapView.userLocationVisible);
    
    if ([(PSMapAtmoMapViewDelegate*)self.mapView.delegate mapViewShowsUserLocationCentered:self.mapView])
    {
        if (!self.mapView.userLocationVisible)
        {
            [[PSMapAtmoMapAnalytics sharedInstance] trackEventLocateOff];
        }
        
        self.mapView.showsUserLocation = NO;
        [self highlightToolBarLocateItem:NO];    
    }
    else
    {
        if (!self.mapView.showsUserLocation)
        {
            [[PSMapAtmoMapAnalytics sharedInstance] trackEventLocateOn];
            self.mapView.userTrackingMode = MKUserTrackingModeNone;
            self.mapView.showsUserLocation = YES;
        }
        else
        {
            // Karte wurde nur bewegt und muss neu zentriert werden!!!
//            [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate animated:YES];
            [(PSMapAtmoMapViewDelegate*)self.mapView.delegate mapView:self.mapView zoomToUserLocation:self.mapView.userLocation];
        }
        
        [self highlightToolBarLocateItem:YES];
    }
}


- (void) infoButtonTouched:(id)sender
{
    DLogFuncName();
    PSMapAtmoNavigationController * navigationController = [[PSMapAtmoNavigationController alloc] initWithRootViewController: [[PSMapAtmoSettingsViewController alloc]init] ];
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - Map
- (MKCoordinateRegion) currentRegion
{
    DLogFuncName();
    return self.mapView.region;
}

@end
