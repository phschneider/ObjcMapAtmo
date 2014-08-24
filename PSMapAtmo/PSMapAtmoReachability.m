//
// Created by Philip Schneider on 02.01.14.
// Copyright (c) 2014 phschneider.net. All rights reserved.
//

#import "Reachability.h"
#import "PSMapAtmoReachability.h"
#import "PSMapAtmoMapAnalytics.h"

@interface PSMapAtmoReachability()
@property (nonatomic) Reachability *internetReachability;
@property (nonatomic) NetworkStatus currentNetworkStatus;
@property (nonatomic) BOOL wasDisconnected;
@end

@implementation PSMapAtmoReachability

static PSMapAtmoReachability* instance = nil;
+ (PSMapAtmoReachability*) sharedInstance {
    @synchronized (self)
    {
        if (instance == nil)
        {
            [PSMapAtmoReachability new];
        }
    }
    return instance;
}


- (id)init
{
    DLogFuncName();
    NSAssert(instance,@"Instance of PSNetAtmoReachability already exists");
    self = [super init];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkReachabilityChanged:) name:kReachabilityChangedNotification object:nil];

        _currentNetworkStatus = -1; // Absicht damit initial ein Netzwerkwechsel erkannt wird

        self.internetReachability = [Reachability reachabilityForInternetConnection];
        [self.internetReachability startNotifier];

    }
    instance = self;
    return self;
}


- (BOOL) isReachable
{
    DLogFuncName();

    BOOL reachable = ([_internetReachability currentReachabilityStatus] > NotReachable);
    return  reachable;
}


- (NSString*)currentReachabilityAsString
{
    DLogFuncName();
    NSString * status = @"";
    switch (_currentNetworkStatus) {
        case -1:
            status = @"NotSet";
            break;
        case ReachableViaWiFi:
            status = @"WiFi";
            break;
        case ReachableViaWWAN:
            status = @"WWAN";
            break;
        default:
            status = @"NotAvailable";
            break;
    }
    
    DLog(@"Status = %@",status);
    return status;
}


#pragma mark - Notification
- (void) networkReachabilityChanged: (NSNotification*) notification
{
    DLogFuncName();

    [self checkNetworkSwitchForNewNetworkStatus: [_internetReachability currentReachabilityStatus]];
}


- (void) checkNetworkSwitchForNewNetworkStatus:(NetworkStatus) networkStatus
{
    DLogFuncName();

    BOOL networkStatusChanged = (networkStatus != _currentNetworkStatus);
    BOOL networkWasReachableBefore = (_currentNetworkStatus == ReachableViaWiFi || _currentNetworkStatus == ReachableViaWWAN);
    BOOL networkIsReachable = (networkStatus != NotReachable);

    // Achtung, changeFromOnlineToOffline != !changedFromOfflineToOnline => es gibt zusätzliche Fälle!!!
    BOOL changedFromOfflineToOnline = (!networkWasReachableBefore && networkIsReachable);
    BOOL changeFromOnlineToOffline = (networkWasReachableBefore && !networkIsReachable);

    DLog(@"NetWorkStatus = %d _currentNetworkStatus = %d,networkStatusChanged = %d ",networkStatus, _currentNetworkStatus, networkStatusChanged);
    if (networkStatusChanged)
    {
        if (networkIsReachable)
        {
            DLog(@"Is Reachable");
            [[PSMapAtmoMapAnalytics sharedInstance] trackConnection];
        }
        else
        {
            DLog(@"NOT Is Reachable");
        }


        if (changedFromOfflineToOnline)
        {
            _currentNetworkStatus = networkStatus;
            DLog(@"AppDelegate networkStatus = handleWasDisconnected => wasDisconnected");
            [[PSMapAtmoMapAnalytics sharedInstance] trackConnectionOnline];
        }
        else if (changeFromOnlineToOffline)
        {
            _currentNetworkStatus = networkStatus;
            DLog(@"Not Reachable");
            [[PSMapAtmoMapAnalytics sharedInstance] trackConnectionOffline];
        }
        else
        {
            _currentNetworkStatus = networkStatus;
            DLog(@"Just changed from WWAN to WIFI or from WIFI to WWAN");
        }

    }
}
@end