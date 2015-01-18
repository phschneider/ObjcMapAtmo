//
//  PSMapAtmoPublicApi.m
//  PSMapAtmo
//
//  Created by Philip Schneider on 15.12.13.
//  Copyright (c) 2013 phschneider.net. All rights reserved.
//

#import "PSMapAtmoPublicApi.h"
#import "PSMapAtmoMapAnalytics.h"
#import "PSMapAtmoUserDefaults.h"
#import "PSMapAtmoFilter.h"
#import "PSMapAtmoPublicCookie.h"
#import "UIAlertView+NSCookbook.h"


@interface PSMapAtmoPublicApi()
@property (nonatomic) int numberOfRequest;
@property (nonatomic) PSMapAtmoFilter *filter;
@property (nonatomic) UIWebView *webView;
@end

@implementation PSMapAtmoPublicApi


static PSMapAtmoPublicApi* instance = nil;

+ (PSMapAtmoPublicApi*) sharedInstance {
    @synchronized (self)
    {
        if (instance == nil)
        {
            [PSMapAtmoPublicApi new];
        }
    }
    return instance;
}


- (id)init
{
    DLogFuncName();
    NSAssert(!instance, @"Instance of PSMapAtmoPublicApi already exists");
    self = [super init];
    if (self)
    {
        self.numberOfRequest = 0;
        self.filter = [[PSMapAtmoUserDefaults sharedInstance] filter];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearAll:) name:PSMAPATMO_PUBLIC_CLEAR_ALL object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFilter) name:PSMAPATMO_API_UPDATE_FILTER object:nil];
    }
    instance = self;
    return self;
}


#pragma mark - Filter
// Wird Getriggert wenn Filter-Settings geschlossen werden!!!
- (void) updateFilter
{
    DLogFuncName();
    self.filter = [[PSMapAtmoUserDefaults sharedInstance] filter];
}


#pragma mark - Notifications
- (void) didEnterBackground:(NSNotification*)notification
{
    DLogFuncName();
    [[PSMapAtmoMapAnalytics sharedInstance] trackNumberOfApiCallsForAppSession:self.numberOfRequest];
    self.numberOfRequest = 0;
}


- (void) clearAll:(NSNotification*)notification
{
    DLogFuncName();
#warning todo
}


#pragma mark - Requests
- (NSString*)postStringForCurrentFilterSettings
{
    DLogFuncName();
    return [NSString stringWithFormat:@"%d",[[self.filter value] intValue]];
}


// Limit:
// Limit kleiner 3000, 300 funktioniert noch
// Je höher das Limit desto mehr ergebnisse werden gefunden .... :(
// Divider:
// Je kleiner der Divider, desto weniger wird gefunden (divider =1 => nur die mitte der karte wird geladen ..
// Divider muss kleiner gleich 15 sein!
- (void) meassuresForSw:(CLLocationCoordinate2D)sw andNe:(CLLocationCoordinate2D)ne
{
    DLogFuncName();

    [[PSMapAtmoPublicCookie sharedInstance] checkAndRequestCookieIfNeeded];

    NSString * localeString = [[[NSLocale currentLocale] identifier] stringByReplacingOccurrencesOfString:@"_" withString:@"-"];
    DLog(@"CurrentLocale String = %@ => %@",[[NSLocale currentLocale] identifier], localeString);

    NSString *postString = [NSString stringWithFormat:@"limit=3&divider=12&quality=%@&lat_ne=%f&lon_ne=%f&lat_sw=%f&lon_sw=%f&ci_csrf_netatmo=%@", [self postStringForCurrentFilterSettings], sw.latitude, sw.longitude, ne.latitude,ne.longitude, [[PSMapAtmoPublicCookie sharedInstance] cookieValue]];
    DLog(@"PostString = %@", postString);

    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:WEATHERMAP_API_NSURL];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request addValue:@"www.netatmo.com" forHTTPHeaderField:@"Host"];
    [request addValue:WEATHERMAP_URL_NSSTRING forHTTPHeaderField:@"Referer"];
    [request addValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
    [request addValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.9; rv:25.0) Gecko/20100101 Firefox/25.0" forHTTPHeaderField:@"User-Agent"];
    [request setValue:[[PSMapAtmoPublicCookie sharedInstance] httpHeaderCookie] forHTTPHeaderField:@"Cookie"];

    DLog(@"PostBody: %@", [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]);
    DLog(@"Request = \n%@\n",request);

    if ([NSURLConnection canHandleRequest:request])
    {
        if ( [[PSMapAtmoPublicCookie sharedInstance] cookieIsValid])
        {
            self.numberOfRequest++;
            [[PSMapAtmoMapAnalytics sharedInstance] trackApiCall];
            [self sendAsyncNsurlRequest:request];
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Request error" message:@"Unable to handle request" delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles:@"retry", nil];
                    [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
//                        [[[UIAlertView alloc] initWithTitle:@"Retry" message:nil delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] show];
                        [self meassuresForSw:sw andNe:ne];
                        return;
                    }];
            });
        }
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc] initWithTitle:@"Request error" message:@"Unable to handle request" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
        });
    }
}


- (void)sendAsyncNsurlRequest:(NSURLRequest*)request
{
    DLogFuncName();
#ifdef    OFFLINE_API
    return;
#endif
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         [[PSMapAtmoPublicCookie sharedInstance] saveCookieFromResponse:(NSHTTPURLResponse*)response];
         [[NSNotificationCenter defaultCenter] postNotificationName:PSMAPATMO_API_DATA_RECEIVED object:nil userInfo:@{ @"size" : [NSNumber numberWithInt:[data length]]}];

        DLog(@"Response Data Lenght: %d", [data length]);
         DLog(@"Response Data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
         DLog(@"Response Error: %@", error);
         
         NSError * jsonError = nil;
         NSArray *dict = nil;
         if ([data length] > 10)
         {
             dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
         }
         
         DLog(@"ParsedObject = %@", dict);
         DLog(@"ParsedObject Count = %d", [dict count]);
         DLog(@"ParsedObject Error = %@", jsonError);
         
         if (![dict isKindOfClass:[NSArray class]])
         {
             NSLog(@"! is Array ...");
         }
         
         if ([data length ] > 0 && !jsonError && dict)
         {
             [[NSNotificationCenter defaultCenter] postNotificationName:PSMAPATMO_PUBLIC_MEASURES_UPDATE_NOTIFICATION object:nil userInfo:@{PSMAPATMO_PUBLIC_MEASURES_UPDATE_NOTIFICATION_USERINFO_KEY : dict}];
         }
         else if (jsonError)
         {
             NSLog(@"JsonError = %@", jsonError);
            #ifdef CONFIGURATION_Debug
            dispatch_async(dispatch_get_main_queue(), ^{
                 [[[UIAlertView alloc] initWithTitle:@"JSON error" message:[NSString stringWithFormat:@"%@",[jsonError userInfo]] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
             });
            #endif
         }
         
#warning todo - auslagern in errorhandling
#warning todo - dict is nil
         
         if ([data length] > 0 && error == nil)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 //                     [[[UIAlertView alloc] initWithTitle:@"Un-Registration" message:[[NSString alloc] initWithData:data encoding:STRING_ENCODING] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
             });
         }
         else if ([data length] == 0 && error == nil)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [[[UIAlertView alloc] initWithTitle:@"Request error" message:@"no data" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
             });
         }
         else if (error != nil && error.code == NSURLErrorTimedOut)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [[[UIAlertView alloc] initWithTitle:@"Request error" message:@"timeout" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
             });
         }
         else if (error != nil)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [[[UIAlertView alloc] initWithTitle:@"Request error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
             });
         }
         
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
     }];
}

@end
