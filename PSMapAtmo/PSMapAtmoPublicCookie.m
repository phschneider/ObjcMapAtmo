//
// Created by Philip Schneider on 18.01.15.
// Copyright (c) 2015 phschneider.net. All rights reserved.
//

#import "PSMapAtmoPublicCookie.h"
#import "PSMapAtmoMapAnalytics.h"


@interface PSMapAtmoPublicCookie() <UIWebViewDelegate>
@property(nonatomic, strong) UIWebView * webView;
@end


@implementation PSMapAtmoPublicCookie

static PSMapAtmoPublicCookie* instance = nil;

+ (PSMapAtmoPublicCookie*) sharedInstance {
    @synchronized (self)
    {
        if (instance == nil)
        {
            [PSMapAtmoPublicCookie new];
        }
    }
    return instance;
}


- (id)init
{

    DLogFuncName();
    NSAssert(!instance, @"Instance of PSMapAtmoPublicCookie already exists");
    self = [super init];
    if (self)
    {
        self.webView = [[UIWebView alloc] init];
        self.webView.delegate = self;

        [self checkAndRequestCookieIfNeeded];
    }
    instance = self;
    return self;
}


- (void) requestCookie
{
    DLogFuncName();
//    [self requestWebViewCookie];
    [self requestNsurlCookie];
    [[PSMapAtmoMapAnalytics sharedInstance] trackEventCookieRequested];
}


- (void)requestWebViewCookie
{
    DLogFuncName();
//    NSString * urlString = @"https://www.netatmo.com/de-DE/weathermap";
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:WEATHERMAP_URL_NSURL];
    [request setHTTPMethod:@"GET"];
    [self.webView loadRequest:request];
}

- (void) requestNsurlCookie
{
    DLogFuncName();

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSURLRequest *request = [NSURLRequest requestWithURL:WEATHERMAP_URL_NSURL];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
    {
        [self saveCookieFromResponse:(NSHTTPURLResponse *)response];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
}



#pragma mark - webView
- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    DLogFuncName();
    if (webView == self.webView)
    {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}


- (void) webViewDidStartLoad:(UIWebView *)webView
{
    DLogFuncName();
    if (webView == self.webView)
    {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    DLogFuncName();
    if (webView == self.webView)
    {
        NSCachedURLResponse *resp = [[NSURLCache sharedURLCache] cachedResponseForRequest:webView.request];
        // NSLog(@"%@",[(NSHTTPURLResponse*)resp.response allHeaderFields]);
        [self saveCookieFromResponse:(NSHTTPURLResponse*)resp.response];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}


#pragma mark -
/*
curl -X POST -H "X-Requested-With: XMLHttpRequest"
-H "Cookie: netatmocomci_csrf_cookie_na=2f991a88e67df5a47e8119108b28af43"
-H "Referer: https://www.netatmo.com/weathermap"
-H "Content-Type: application/x-www-form-urlencoded"
-H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.9; rv:25.0) Gecko/20100101 Firefox/25.0"
-H "Host: www.netatmo.com" "https://www.netatmo.com/weathermap/getPublicMeasures"
-d "limit=3&divider=12&quality=7&lat_ne=55.438847&lon_ne=19.239265&lat_sw=47.112491&lon_sw=1.428038&ci_csrf_netatmo=2f991a88e67df5a47e8119108b28af43"

COOKIE MUSS unbedingt die netatmolocale enthalten da sonst keine ergebnisse von der anfrage kommen!!!

curl -X POST -H "X-Requested-With: XMLHttpRequest"
-H "Cookie: netatmocomci_csrf_cookie_na=2f991a88e67df5a47e8119108b28af43; netatmocomlocale=de-DE"
-H "Referer: https://www.netatmo.com/weathermap"
-H "Content-Type: application/x-www-form-urlencoded"
-H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.9; rv:25.0) Gecko/20100101 Firefox/25.0"
-H "Host: www.netatmo.com" "https://www.netatmo.com/weathermap/getPublicMeasures"
-d "limit=3&divider=12&quality=7&lat_ne=55.166564&lon_ne=18.691361&lat_sw=46.785963&lon_sw=0.880134&ci_csrf_netatmo=2f991a88e67df5a47e8119108b28af43"
 */
- (void) saveCookieFromResponse:(NSHTTPURLResponse*)response
{
    DLogFuncName();
    NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse*)response;
    NSDictionary *fields = [HTTPResponse allHeaderFields];
    NSString *cookie = [fields valueForKey:@"Set-Cookie"];
    NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:fields forURL:HTTPResponse.URL];

    if (cookie || cookies)
    {
//        NSLog((@"[FUNCNAME] %@ %s [Line %d] "), THREAD_LOG, __PRETTY_FUNCTION__, __LINE__);
//        NSLog(@"Header = %@", fields);
        NSLog(@"[COOKIE] GetCookies = \n\n%@\n\n", cookies);

    //    // achtung response url enhälte die locale ...
    //    // URL: https://www.netatmo.com/en-US/weathermap
    //    // daher lieber auf defines wert setzen
    //    //            [[NSHTTPCookieStorage sharedHTTPCookieStorage]  setCookies: cookies forURL:response.URL mainDocumentURL: nil ];
        if (![self hasValidCookie])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:PSMAPATMO_COOKIE_UPDATED_NOTIFICICATION object:nil];
        }
        [[NSHTTPCookieStorage sharedHTTPCookieStorage]  setCookies: cookies forURL:WEATHERMAP_URL_NSURL mainDocumentURL: nil ];
        [[PSMapAtmoMapAnalytics sharedInstance] trackEventCookieRequested];
    }
}


- (NSHTTPCookie *)netAtmoCookie
{
    DLogFuncName();

    NSHTTPCookie *netAtmoCookie = nil;
    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:WEATHERMAP_URL_NSURL])
    {
        if ([cookie.name isEqualToString:NETATMO_COOKIE_NAME])
        {
            netAtmoCookie = cookie;
//            NSLog(@"NetAtmoCookie = %@", cookie);
            break;
        }
    }
    return netAtmoCookie;
}


- (BOOL) hasCookie
{
    DLogFuncName();

    NSHTTPCookie *cookie = [self netAtmoCookie];
    if (!cookie)
    {
        [[PSMapAtmoMapAnalytics sharedInstance] trackEventCookieMissed];
    }
    return (cookie != nil);
}


- (BOOL) cookieIsValid
{
    DLogFuncName();

    NSHTTPCookie *cookie = [self netAtmoCookie];
    if (cookie && cookie.value)
    {
        NSDate *now = [NSDate date];
        NSDate *cookieDate = cookie.expiresDate;

        if ([now compare:cookieDate] == NSOrderedDescending)
        {
            NSLog((@"[FUNCNAME] %@ %s [Line %d] "), THREAD_LOG, __PRETTY_FUNCTION__, __LINE__);
            NSLog(@"[COOKIE] now is later than cookieDate => invalid");
            [[PSMapAtmoMapAnalytics sharedInstance] trackEventCookieInvalid];
            return NO;
        }
        else if ([now compare:cookieDate] == NSOrderedAscending)
        {
            NSLog((@"[FUNCNAME] %@ %s [Line %d] "), THREAD_LOG, __PRETTY_FUNCTION__, __LINE__);
            NSLog(@"[COOKIE] now is earlier than cookieDate => isValid");
            return YES;
        }
        else
        {
            NSLog((@"[FUNCNAME] %@ %s [Line %d] "), THREAD_LOG, __PRETTY_FUNCTION__, __LINE__);
            NSLog(@"[COOKIE] dates are the same => invalid");
            [[PSMapAtmoMapAnalytics sharedInstance] trackEventCookieInvalid];
            return NO;
        }
    }
    [[PSMapAtmoMapAnalytics sharedInstance] trackEventCookieInvalid];
    return  NO;
}


- (BOOL)hasValidCookie
{

    DLogFuncName();
    return ([self hasCookie] && [self cookieIsValid]);
}


- (void) checkAndRequestCookieIfNeeded
{

    DLogFuncName();
    if (![self hasValidCookie])
    {
        [self requestCookie];
    }
}


- (NSString*)httpHeaderCookie
{
    DLogFuncName();

    if ([self cookieIsValid])
    {
        NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:WEATHERMAP_URL_NSURL];
        NSDictionary *cookieHeaders = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
        NSString *value = [cookieHeaders objectForKey:@"Cookie"];

        NSLog((@"[FUNCNAME] %@ %s [Line %d] "), THREAD_LOG, __PRETTY_FUNCTION__, __LINE__);
        NSLog(@"CLASS = %@\n Value = %@", NSStringFromClass([value class]), value);
        NSLog(@"[COOKIE] SendCookies = \n\n%@\n\n", cookies);
        return value;
    }
    return nil;
}


- (NSString*)cookieValue
{
    DLogFuncName();
    if ([self cookieIsValid])
    {
        return [[self netAtmoCookie] value];
    }
    return nil;
}

@end
