//
//  PSMapAtmoPublicApi.m
//  PSMapAtmo
//
//  Created by Philip Schneider on 15.12.13.
//  Copyright (c) 2013 phschneider.net. All rights reserved.
//

#define DEFAULTS_USE_COOKIE        YES
#define DEFAULTS_PUBLIC_COOKIE     @"DEFAULTS_PUBLIC_COOKIE"

#import "PSMapAtmoPublicApi.h"
#import "PSMapAtmoNotifications.h"
#import "NSMutableURLRequest+CurlDescription.h"
#import "PSMapAtmoMapAnalytics.h"
#import "PSMapAtmoUserDefaults.h"
#import "NSString+NXOAuth2.h"
#import "PSMapAtmoFilter.h"
#import "PSMapAtmoAccount.h"

#import <NXOAuth2Client/NXOAuth2.h>
#import "PSMapAtmoAccount.h"

@interface PSMapAtmoPublicApi()
@property (nonatomic) int numberOfRequest;
@property (nonatomic) PSMapAtmoFilter *filter;
@end

@implementation PSMapAtmoPublicApi

//+ (NSArray*)userAgents
//{
//    Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1650.63 Safari/537.36
//}
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
    NSAssert(!instance, @"Instance of PSMapAtmoAnalytics already exists");
    self = [super init];
    if (self)
    {
        self.numberOfRequest = 0;
        self.filter = [[PSMapAtmoUserDefaults sharedInstance] filter];

//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
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
- (void) willResignActive:(NSNotification*)notification
{
    DLogFuncName();
    
}


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


#pragma mark - Cookie
- (void) saveCookieFromResponse:(NSURLResponse*)response
{
    DLogFuncName();
    if ([response isKindOfClass:[NSHTTPURLResponse class]])
    {
        NSString * cookie = [[((NSHTTPURLResponse*)response) allHeaderFields] objectForKey:@"Set-Cookie" ];
        [[NSUserDefaults standardUserDefaults] setObject:cookie  forKey:DEFAULTS_PUBLIC_COOKIE];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}


- (NSString*)cookie
{
    DLogFuncName();
    NSString * cookie = [[NSUserDefaults standardUserDefaults] objectForKey:DEFAULTS_PUBLIC_COOKIE];
    DLog(@"cookie = |%@|", cookie);
    return cookie;
}


- (BOOL) hasCookie
{
    DLogFuncName();
    BOOL hasCookie = ([[NSUserDefaults standardUserDefaults] objectForKey:DEFAULTS_PUBLIC_COOKIE] != nil);
    DLog(@"hasCookie = %@", hasCookie ? @"YES" : @"NO");
    return hasCookie;
}


#pragma mark - Requests
- (NSString*)postStringForCurrentFilterSettings
{
    DLogFuncName();
    return [NSString stringWithFormat:@"%d",[[self.filter value] intValue]];

//    if (self.useFilter)
//    {
//        return @"7";
//    }
//    else
//    {
//        return @"-1";
//    }
}


- (void) meassuresForSw:(CLLocationCoordinate2D)sw andNe:(CLLocationCoordinate2D)ne
{
    DLogFuncName();
    
    NSString * urlString = @"https://www.netatmo.com/weathermap/getPublicMeasures";
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    
    NSMutableData *postBody = [NSMutableData data];
    //    NSString *postString = @"limit=100&divider=12&quality=7&lat_ne=52.482780222078226&lon_ne=-2.8125&lat_sw=49.38237278700955&lon_sw=-7.734375";
    
    // Quality = 2 -> Temperature ?

    // Je höher das Limit desto mehr ergebnisse werden gefunden .... :(
    // Limit kleiner 3000, 300 funktioniert noch
    // Je kleiner der Divider, desto weniger wird gefunden (divider =1 => nur die mitte der karte wird geladen ..
    // Divider muss kleiner gleich 15 sein!
    NSString *postString = [NSString stringWithFormat:@"limit=3&divider=12&quality=%@&lat_ne=%f&lon_ne=%f&lat_sw=%f&lon_sw=%f", [self postStringForCurrentFilterSettings], sw.latitude, sw.longitude, ne.latitude,ne.longitude];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    DLog(@"PostString = %@", postString);
//    for (NSString * localeIdentifier in [NSLocale availableLocaleIdentifiers])
//    {
//        NSLocale * locale = [NSLocale localeWithLocaleIdentifier:localeIdentifier];
//        DLog(@"%@ \t => \t%@",localeIdentifier, [[locale localeIdentifier] stringByReplacingOccurrencesOfString:@"_" withString:@"-"] );
//    }
    
    NSString * localeString = [[[NSLocale currentLocale] identifier] stringByReplacingOccurrencesOfString:@"_" withString:@"-"];
    DLog(@"CurrentLocale String = %@ => %@",[[NSLocale currentLocale] identifier], localeString);
    
    NSString * netAtmoLocaleString = [NSString stringWithFormat:@"netatmocomlocale=%@; ",localeString];
    if (DEFAULTS_USE_COOKIE && [self hasCookie])
    {
        DLog(@"Setting cookie from userdefaults");
        [request setValue:[self cookie] forHTTPHeaderField:@"Cookie"];
    }
    else
    {
        DLog(@"Using Cookie from UserLocale");
        [request setValue:netAtmoLocaleString forHTTPHeaderField:@"Cookie"];
    }

    [request addValue:@"www.netatmo.com" forHTTPHeaderField:@"Host"];
    [request addValue:@"http://www.netatmo.com/weathermap" forHTTPHeaderField:@"Referer"];
    [request addValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
    [request addValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.9; rv:25.0) Gecko/20100101 Firefox/25.0" forHTTPHeaderField:@"User-Agent"];
    //    [request setValue:@"netatmocomlocale=de-DE; __utma=162861987.708650259.1386881166.1386881166.1386881166.1; __utmb=162861987.3.10.1386881166; __utmc=162861987; __utmz=162861987.1386881166.1.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none)" forHTTPHeaderField:@"Cookie"];
    
    
    DLog(@"URL: %@", urlString);
    DLog(@"PostBody: %@", [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]);
    DLog(@"Request = \n%@\n",request);
    
    if ([NSURLConnection canHandleRequest:request])
    {
        //        usleep(2);
        self.numberOfRequest++;
        [[PSMapAtmoMapAnalytics sharedInstance] trackApiCall];
        [self sendRequest:request];
        //        usleep(2);
        //        [self sendRequest:request];
        //        usleep(2);
        //        [self sendRequest:request];
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc] initWithTitle:@"Request error" message:@"Unable to handle request" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
        });
    }
}


- (void) sendRequest:(NSURLRequest*)request
{
    DLogFuncName();
#ifdef    OFFLINE_API
    return;
#endif
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         [self saveCookieFromResponse:response];
         [[NSNotificationCenter defaultCenter] postNotificationName:PSMAPATMO_API_DATA_RECEIVED object:nil userInfo:@{ @"size" : [NSNumber numberWithInt:[data length]]}];

         DLog(@"Response Data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
         DLog(@"Response Error: %@", error);
         
         NSError * jsonError = nil;
         NSArray *dict = nil;
         if ([data length])
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
         
         if ([data length ] > 0 && !jsonError)
         {
             [[NSNotificationCenter defaultCenter] postNotificationName:PSMAPATMO_PUBLIC_MEASURES_UPDATE_NOTIFICATION object:nil userInfo:@{PSMAPATMO_PUBLIC_MEASURES_UPDATE_NOTIFICATION_USERINFO_KEY : dict}];
         }
         else if (jsonError)
         {
             NSLog(@"JsonError = %@", jsonError);
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


- (void) getMeasureForImprint
{
    DLogFuncName();

    [[PSMapAtmoAccount sharedInstance] requestAccountWithUser:@"netatmo@mapatmoapp.com" andPass:@"ieKKAYjy7qVqDnTcojefLPaFTv9BXg"];

    NXOAuth2Account * account = [[PSMapAtmoAccount sharedInstance] account];
    NSAssert(account,@"no account given");
    
    [NXOAuth2Request performMethod:@"GET"
                        onResource:[NSURL URLWithString:@"http://www.netatmo.com/api/getmeasure"]
                   usingParameters: @{  @"access_token" : account.accessToken.accessToken,
                                        @"device_id" : @"70:ee:50:00:51:26",
                                        @"scale" : @"max",
                                        @"type" : @"temperature",
                                        @"module_id" : @"02:00:00:00:4f:30",
                                        @"date_begin" : [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] - 60*60*24]
                                        }
                       withAccount:account
               sendProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal)  {  }// e.g., update a progress indicator }
                   responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error){
                       // Process the response
                       
                       NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                       NSLog(@"ResponseString = %@", responseString);
                       NSError * jsonError = nil;
                        NSDictionary *dict = nil;
                        if ([responseData length])
                        {
                            dict = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
                            // hole letzten wert und zeige letzten wert an ...
                           NSLog(@"Dict = %@", dict);
                        }

                       
                       //                       NSLog(@"account.accessToken.accessToken = %@", account.accessToken.accessToken);
                       NSLog(@"Responsed = %@", response);
                       NSLog(@"Error = %@", error);
                   }];
}


#pragma mark - One Device (Testweise implementiert)
- (void) getMeasure
{
    DLogFuncName();

    NSString * urlString = @"http://www.netatmo.com/api/getmeasure";
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];

    NSString *postString = [NSString stringWithFormat:@"date_begin=1391412321&date_end=1391592321&scale=max&device_id=70%3Aee%3A50%3A00%3A14%3A8e&module_id=02%3A00%3A00%3A00%3A12%3A7c&type=Temperature%2CHumidity&access_token=52d42bfc1777599b298b456c%7C200573b0618ab23808fbcdd2e77b0308"];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];

    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    DLog(@"PostString = %@", postString);

    NSString * localeString = [[[NSLocale currentLocale] identifier] stringByReplacingOccurrencesOfString:@"_" withString:@"-"];
    DLog(@"CurrentLocale String = %@ => %@",[[NSLocale currentLocale] identifier], localeString);
    NSString * netAtmoLocaleString = [NSString stringWithFormat:@"netatmocomlocale=%@; ",localeString];
    if (DEFAULTS_USE_COOKIE && [self hasCookie])
    {
        DLog(@"Setting cookie from userdefaults");
        [request setValue:@"netatmocomlocale=de-DE; __utma=162861987.850805182.1391801739.1391801739.1391801739.1; __utmb=162861987.2.10.1391801739; __utmc=162861987; __utmz=162861987.1391801739.1.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none)" forHTTPHeaderField:@"Cookie"];
    }
    else
    {
        DLog(@"Using Cookie from UserLocale");
        [request setValue:@"netatmocomlocale=de-DE; __utma=162861987.850805182.1391801739.1391801739.1391801739.1; __utmb=162861987.2.10.1391801739; __utmc=162861987; __utmz=162861987.1391801739.1.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none)" forHTTPHeaderField:@"Cookie"];
    }

    [request addValue:@"www.netatmo.com" forHTTPHeaderField:@"Host"];
    [request addValue:@"http://www.netatmo.com/weathermap" forHTTPHeaderField:@"Referer"];
    [request addValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
    [request addValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.9; rv:25.0) Gecko/20100101 Firefox/25.0" forHTTPHeaderField:@"User-Agent"];
    //    [request setValue:@"netatmocomlocale=de-DE; __utma=162861987.708650259.1386881166.1386881166.1386881166.1; __utmb=162861987.3.10.1386881166; __utmc=162861987; __utmz=162861987.1386881166.1.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none)" forHTTPHeaderField:@"Cookie"];


    DLog(@"URL: %@", urlString);
    DLog(@"PostBody: %@", [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]);
    DLog(@"Request = \n%@\n",request);

    if ([NSURLConnection canHandleRequest:request])
    {
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
        {
            [self saveCookieFromResponse:response];
//            [[NSNotificationCenter defaultCenter] postNotificationName:PSMapAtmo_API_DATA_RECEIVED object:nil userInfo:@{ @"size" : [NSNumber numberWithInt:[data length]]}];

            DLog(@"Response Data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            DLog(@"Response Error: %@", error);

            NSError * jsonError = nil;
            NSDictionary *dict = nil;
            if ([data length])
            {
                dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            }

            DLog(@"ParsedObject = %@", dict);
            DLog(@"ParsedObject Count = %d", [dict count]);
            DLog(@"ParsedObject Error = %@", jsonError);

//            [[NSNotificationCenter defaultCenter] postNotificationName:PSMapAtmo_PUBLIC_MEASURES_UPDATE_NOTIFICATION object:nil userInfo:dict];

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
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc] initWithTitle:@"Request error" message:@"Unable to handle request" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
        });
    }
}


- (void)getToken
{
    DLogFuncName();

    NSString * urlString = @"https://api.netatmo.net/oauth2/token";
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];

    NSString *postString = [[NSString stringWithFormat:@"grant_type=password&client_id=52f537481877591e747b250d&client_secret=OCTFNv5bGIn6alwyp3CZesHha7yuKvJoTNatjAQwVV&username=info@philip-schneider.com&password=7qUQVRLdPffg6p"] nxoauth2_URLEncodedString];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];

    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    DLog(@"PostString = %@", postString);



    [request addValue:@"www.netatmo.com" forHTTPHeaderField:@"Host"];
    [request addValue:@"http://www.netatmo.com/weathermap" forHTTPHeaderField:@"Referer"];
    [request addValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
    [request addValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.9; rv:25.0) Gecko/20100101 Firefox/25.0" forHTTPHeaderField:@"User-Agent"];
    //    [request setValue:@"netatmocomlocale=de-DE; __utma=162861987.708650259.1386881166.1386881166.1386881166.1; __utmb=162861987.3.10.1386881166; __utmc=162861987; __utmz=162861987.1386881166.1.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none)" forHTTPHeaderField:@"Cookie"];


    DLog(@"URL: %@", urlString);
    DLog(@"PostBody: %@", [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]);
    DLog(@"Request = \n%@\n",request);

    if ([NSURLConnection canHandleRequest:request])
    {
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
        {
            [self saveCookieFromResponse:response];
//            [[NSNotificationCenter defaultCenter] postNotificationName:PSMapAtmo_API_DATA_RECEIVED object:nil userInfo:@{ @"size" : [NSNumber numberWithInt:[data length]]}];

            NSString * responseData =  [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            // <!doctype html>

            DLog(@"Response Data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            DLog(@"Response Error: %@", error);

            NSError * jsonError = nil;
            NSDictionary *dict = nil;
            if ([data length])
            {
                dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            }

            DLog(@"ParsedObject = %@", dict);
            DLog(@"ParsedObject Count = %d", [dict count]);
            DLog(@"ParsedObject Error = %@", jsonError);

//            [[NSNotificationCenter defaultCenter] postNotificationName:PSMapAtmo_PUBLIC_MEASURES_UPDATE_NOTIFICATION object:nil userInfo:dict];

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
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc] initWithTitle:@"Request error" message:@"Unable to handle request" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
        });
    }
}

@end
