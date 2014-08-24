//
//  PSNetAtmoWebViewController.m
//  PSNetAtmo
//
//  Created by Philip Schneider on 05.12.13.
//  Copyright (c) 2013 phschneider.net. All rights reserved.
//

#import "PSMapAtmo.h"
#import "PSMapAtmoWebViewController.h"

@interface PSMapAtmoWebViewController ()
@property (nonatomic) UIWebView * webView;
@property (nonatomic) NSURL * url;
@end

@implementation PSMapAtmoWebViewController

- (id)initWithUrl:(NSURL*)url
{
    DLogFuncName();
    self = [super init];
    if (self)
    {
        self.url = url;
    }
    return self;
}


- (void) viewDidAppear:(BOOL)animated
{
    DLogFuncName();
    [super viewDidAppear:animated];
    if (!self.webView)
    {
        self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        self.webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.webView.delegate = self;
        [self.view addSubview:self.webView];
    }
    
    if (self.url)
    {
        NSURLRequest * request = [NSURLRequest requestWithURL:self.url];
        [self.webView loadRequest:request];
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"cancel",nil) style:UIBarButtonItemStyleDone target:self action:@selector(cancelButtonTouched)];
}


- (void) cancelButtonTouched
{
    DLogFuncName();
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.webView stopLoading];
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - WebViewDelegate
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    DLogFuncName();
    NSLog(@"Error = %@", error);
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    DLogFuncName();
//    NSLog(@"Request = %@ (%d)",[request.URL absoluteString],navigationType);
//    if ([[request.URL absoluteString] hasPrefix:@"http://api.netatmo.net/oauth2/dashatmo?code="])
//    {
//        [self dismissViewControllerAnimated:YES completion:nil];
//    }
//    
//    return YES;

    if ([[request.URL absoluteString] hasPrefix:@"http://dash.atmo"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:PSMAPATMO_RECEIVED_REDIRECT_URL object:nil userInfo:@{@"url" : request.URL}];
        [self cancelButtonTouched];
        return NO;
    }
    return YES;
    
//    if (navigationType == 1 || navigationType == 5)
//    {
//        return YES;
//    }
//    return NO;
}


- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script
{
    DLogFuncName();
    NSLog(@"Script = %@", script);
    return script;
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    DLogFuncName();
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}


- (void)webViewDidStartLoad:(UIWebView *)webView
{
    DLogFuncName();
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}


@end
