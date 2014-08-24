//
// Created by Philip Schneider on 02.01.14.
// Copyright (c) 2014 phschneider.net. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "PSMapAtmoMapImprintViewController.h"
#import "PSMapAtmoMapAnalytics.h"

@interface PSMapAtmoMapImprintViewController()
@property (nonatomic) UIWebView * webView;
@property (nonatomic) MKMapView * mapView;
@property (nonatomic) MKPointAnnotation * mapAnnotation;
@property (nonatomic) UIView * webViewBackgroundView;
@property (nonatomic) UIActivityIndicatorView * activityIndicatorView;
@end

#define IMPRINT_MAP_VIEW_REGION_DEFAULT_SIZE    10000


@implementation PSMapAtmoMapImprintViewController

- (id) init
{
    DLogFuncName();
    self = [super init];
    if (self)
    {
        self.title = [NSLocalizedString(@"imprint", nil) capitalizedString];

        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"done" style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonTouched:)];
        
        self.mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
        self.mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        // nicht in iOS6
        if ([self.mapView respondsToSelector:@selector(setShowsBuildings:)])
        {
            self.mapView.showsBuildings = YES;
        }
        
        CLLocationCoordinate2D myCoord = CLLocationCoordinate2DMake(49.232284,7.001005);
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(myCoord, IMPRINT_MAP_VIEW_REGION_DEFAULT_SIZE, IMPRINT_MAP_VIEW_REGION_DEFAULT_SIZE);
        MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
        
        self.mapView.centerCoordinate = myCoord;
        [self.mapView setRegion:adjustedRegion animated:YES];
        
        self.mapAnnotation = [[MKPointAnnotation alloc] init];
        [self.mapAnnotation setCoordinate:myCoord];
        [self.mapAnnotation setTitle:@"Headquarter"]; //You can set the subtitle too
        [self.mapView addAnnotation:self.mapAnnotation];
        
        [self.view addSubview:self.mapView];
        
        
        self.webViewBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
        self.webViewBackgroundView.backgroundColor = [UIColor whiteColor];
        self.webViewBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.webViewBackgroundView.alpha = 0.7;
        [self.view addSubview:self.webViewBackgroundView];
        
        
        self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        self.webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.webView.backgroundColor =[UIColor clearColor];
        self.webView.opaque = NO;
        self.webView.dataDetectorTypes = UIDataDetectorTypeNone;
        self.webView.delegate = self;

        // wegen hässlichem webView schatten bei scrollen...
        if (SYSTEM_VERSION_LESS_THAN(@"7.0"))
        {
            self.webView.userInteractionEnabled = NO;
        }
        [self.view addSubview:self.webView];

        self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        self.activityIndicatorView.center = self.webView.center;

        [self.activityIndicatorView startAnimating];
        [self.view addSubview:self.activityIndicatorView];
    }
    return self;
}


- (void) viewDidLoad
{
    DLogFuncName();
    [super viewDidLoad];
}


- (void) viewWillAppear:(BOOL)animated
{
    DLogFuncName();
    [super viewWillAppear:animated];

    self.webViewBackgroundView.frame = CGRectMake(0,self.view.bounds.size.height-220,self.view.bounds.size.width,self.view.bounds.size.height-355);
    // ios6 self.webViewBackgroundView.frame = CGRectMake(0,self.view.bounds.size.height-220,self.view.bounds.size.width,self.view.bounds.size.height-400);
//    self.webView.frame = CGRectMake(0,self.view.bounds.size.height-220,self.view.bounds.size.width,self.view.bounds.size.height-400);
    self.webView.frame = CGRectMake(0,self.view.bounds.size.height-220,self.view.bounds.size.width,self.view.bounds.size.height-355);
    self.activityIndicatorView.center = self.webViewBackgroundView.center;


    NSString * style = @"<style>* {font-family: TrajanPro-Regular, 'Lucida Grande', sans-serif; font-color: #ffffff;} body { background-color: transparent;} h1 { margin-top: 20px; margin-left: 135px;} p {margin: 10px; margin-left: 135px;}</style>";
    NSString * imprint = @"<h1>Philip Schneider</h1><p>Neugäßchen 20 <br />66111 Saarbrücken, Deutschland</p><p>Tel:&nbsp; &nbsp; +49 681 41 098 168 1<br />Fax: &nbsp; +49 681 41 098 168 9</p><p>Mail: contact@mapatmoapp.com</p>";
    NSString * html = [NSString stringWithFormat:@"<html><head></head><body>%@%@</body></html>",style,imprint];
    
    [self.webView loadHTMLString:html baseURL:nil];
}


- (void) viewDidAppear:(BOOL)animated
{
    DLogFuncName();
    [super viewDidAppear:animated];

    [[PSMapAtmoMapAnalytics sharedInstance] trackView:@"settings-imprint"];

    [self.mapView selectAnnotation:self.mapAnnotation animated:YES];
}


#pragma mark - ActivityIndicator
- (void) showActivityIndicator
{
    DLogFuncName();
    self.activityIndicatorView.alpha = 1.0;
}

- (void) hideActivityIndicator
{
    DLogFuncName();
    self.activityIndicatorView.alpha = .0;
}


#pragma mark - WebView Delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    DLogFuncName();
    return YES;
}


- (void)webViewDidStartLoad:(UIWebView *)webView
{
    DLogFuncName();
    [self showActivityIndicator];
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    DLogFuncName();
    [self hideActivityIndicator];
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    DLogFuncName();
}

@end