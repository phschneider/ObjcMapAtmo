//
//  PSNetAtmoSettingsViewController.m
//  PSNetAtmo
//
//  Created by Philip Schneider on 14.12.13.
//  Copyright (c) 2013 phschneider.net. All rights reserved.
//

#import "PSMapAtmoSettingsViewController.h"
#import "PSMapAtmoMapImprintViewController.h"
#import "PSMapAtmoUnitsViewController.h"
#import "PSMapAtmoSettingsMapViewController.h"
#import "PSMapAtmoSettingsLocationViewController.h"

#import "PSMapAtmoAppVersion.h"

#warning SOCIAL NOT IOS5

#import "iTellAFriend.h"
#import "iRate.h"
#import "TDBadgedCell.h"
#import "PSMapAtmoFilterViewController.h"
#import "PSMapAtmoMapAnalytics.h"
#import "EDSemver.h"

#ifndef CONFIGURATION_AppStore
    #import "PSMapAtmoBetaFeedbackViewController.h"
    #import "PSMapAtmoDebugViewController.h"
    #import "PSMapAtmoBetaFeedbackViewController.h"
    #import "PSMapAtmoBetaViewController.h"
#endif

@interface PSMapAtmoSettingsViewController ()

@property (nonatomic) UITableView * tableView;
@property (nonatomic) NSArray * tableData;
@end

@implementation PSMapAtmoSettingsViewController


- (id)init
{
    DLogFuncName();
    self = [super init];
    if (self)
    {
        self.title = [@"settings" capitalizedString];

        self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        [self.view addSubview:self.tableView];

        // On first start, nothing is new
        // Show New only if feature is new in current Version
        NSString *currentAppVersion = [[PSMapAtmoAppVersion sharedInstance] currentAppVersion];

        EDSemver *lastAppVersion = [[EDSemver alloc] initWithString:[[PSMapAtmoAppVersion sharedInstance] previousAppVersion]];
        EDSemver  *appVersionOne = [[EDSemver alloc] initWithString:@"1.0"];
        EDSemver  *appVersionOneDotOne = [[EDSemver alloc] initWithString:@"1.1"];
        EDSemver  *appVersionOneDotTwo = [[EDSemver alloc] initWithString:@"1.2"];


        BOOL showNewBadgeForVersionOneDotOne =  ( ![[PSMapAtmoAppVersion sharedInstance] isFirstVersion] && [lastAppVersion isLessThan:appVersionOneDotOne]);
        BOOL showNewBadgeForVersionOneDotTwo =  ( ![[PSMapAtmoAppVersion sharedInstance] isFirstVersion]);        
        BOOL showUpdateBadgeForVersionOneDotTwo = ( ![[PSMapAtmoAppVersion sharedInstance] isFirstVersion] && [lastAppVersion isLessThan:appVersionOneDotTwo] && [lastAppVersion isGreaterThan:appVersionOne]);
        
        #warning todo - show updated badge

        NSLog(@"isFirstVersion => %d", [[PSMapAtmoAppVersion sharedInstance] isFirstVersion]);
        NSLog(@"previousAppVersion => %@", lastAppVersion);
        NSLog(@"currentAppVersion => %@", currentAppVersion);
        NSLog(@"showNewBadgeForVersionOneDotOne => %d", showNewBadgeForVersionOneDotOne);
        NSLog(@"showNewBadgeForVersionOneDotTwo => %d", showNewBadgeForVersionOneDotTwo);

        self.tableData = @[
                            @[
                                @{
                                    @"title" : @"Units",
                                    @"viewController" : [[PSMapAtmoUnitsViewController alloc] init],
                                    @"badge" : (showNewBadgeForVersionOneDotOne) ? @"new" : @""
                                },

                                @{
                                    @"title" : @"Filter",
                                    @"viewController" : [[PSMapAtmoFilterViewController alloc] init],
                                    @"badge" : (showNewBadgeForVersionOneDotOne) ? @"new" : (showUpdateBadgeForVersionOneDotTwo) ? @"updated" : @""
                                },
                                
                                @{
                                    @"title" : @"Map",
                                    @"viewController" : [[PSMapAtmoSettingsMapViewController alloc] init],
                                    @"badge" : (showNewBadgeForVersionOneDotTwo) ? @"new" : @""
                                 },

                                @{
                                    @"title" : @"Location",
                                    @"viewController" : [[PSMapAtmoSettingsLocationViewController alloc] init],
                                    @"badge" : (showNewBadgeForVersionOneDotTwo) ? @"new" : @""
                                 }

                               ],
                            @[
                                @{
                                    @"title" : @"Imprint",
                                    @"viewController" : [[PSMapAtmoMapImprintViewController alloc] init]
                                },

                                @{
                                        @"title" : @"Visit website" ,
                                        @"selector" : @"showMapAtmoWebSite",
                                        @"badge" : (showNewBadgeForVersionOneDotOne) ? @"new" : @""
                                 },
                                //@{ @"title" : @"Follow us on twitter"},
                                @{
                                        @"title" :  @"Tell a friend",
                                        @"selector" : @"showTellAFriend",
                                        @"badge" : (showNewBadgeForVersionOneDotOne) ? @"new" : @""
                                },
                                //@{ @"title" : @"View in AppStore" },
                                @{
                                        @"title" : @"Rate this app",
                                        @"selector" : @"showAppRating",
                                        @"badge" : (showNewBadgeForVersionOneDotOne) ? @"new" : @""
                                },
                                //@{ @"title" : @"About this app"}
                              ]
#ifndef CONFIGURATION_AppStore
                            ,
                            @[
    #ifdef CONFIGURATION_Beta
                                @{
                                    @"title" : @"Beta",
                                    @"viewController" : [[PSMapAtmoBetaViewController alloc] init],
                                    @"badge" : (showNewBadgeForVersionOneDotOne) ? @"new" : @""
                                    }
    #else
                                @{
                                     @"title" : @"Debug",
                                     @"viewController" : [[PSMapAtmoBetaViewController alloc] init],
                                      @"badge" : (showNewBadgeForVersionOneDotOne) ? @"new" : @""
                                }
    #endif
                            ]
#endif


                            ];

        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"done" style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonTouched:)];

    }
    return self;
}


- (void)viewDidAppear:(BOOL)animated
{
    DLogFuncName();
    [super viewDidAppear:animated];
    [[PSMapAtmoMapAnalytics sharedInstance] trackView:@"settings"];
}


#pragma mark - TableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLogFuncName();
    NSString * cellIdentifier = @"SettingsCell";
    TDBadgedCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell)
    {
        cell = [[TDBadgedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    NSArray * section = self.tableData[(NSUInteger) indexPath.section];
    NSDictionary * row = section[(NSUInteger) indexPath.row];
    cell.textLabel.text = row[@"title"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;

    if ([[row allKeys] containsObject:@"badge"] && ![row[@"badge"] isEqualToString:@""])
    {
        NSString *badgeTitle = row[@"badge"];
        cell.badgeString = badgeTitle;
        if ([badgeTitle isEqualToString:@"new"])
        {
            cell.badgeColor = [UIColor colorWithRed:0.792 green:0.197 blue:0.219 alpha:1.000];
        }
        else
        {
            cell.badgeColor = [UIColor colorWithRed:0/255.0f green:219/255.0f blue:87/255.0f alpha:1.0f];
        }
    }

    return cell;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    DLogFuncName();
    return [self.tableData count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    DLogFuncName();
    return [self.tableData[(NSUInteger) section] count];
}


#pragma mark - TableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLogFuncName();
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    NSArray * section = self.tableData[(NSUInteger) indexPath.section];
    NSDictionary * row = section[(NSUInteger) indexPath.row];
    if ([[row allKeys] containsObject:@"viewController"])
    {
        [self.navigationController pushViewController:[section[(NSUInteger) indexPath.row] objectForKey:@"viewController"] animated:YES];
    }
    else if  ([[row allKeys] containsObject:@"selector"])
    {
        NSString * selector = row[@"selector"];
        if ([self respondsToSelector:NSSelectorFromString(selector)])
        {
            [self performSelector:NSSelectorFromString(selector)];
        }
        else
        {
            NSLog(@"Doesn't respond to selector %@", selector);
        }
    }
    else
    {
        NSLog(@"No ViewController to present and no selector to perform %@", row[@"title"]);
    }
}


#pragma mark - selectors
- (void)showMapAtmoWebSite
{
    DLogFuncName();

    [[PSMapAtmoMapAnalytics sharedInstance] trackView:@"settings-mapAtmoAppDotCom"];
    
    NSString * url = @"http://mapatmoapp.com";
    NSURL * websiteUrl = [NSURL URLWithString:url];
    if ([[UIApplication sharedApplication] canOpenURL:websiteUrl])
    {
        [[UIApplication sharedApplication] openURL:websiteUrl];
    }
    else
    {
        #warning TODO
        NSLog(@"Doesn't support http:// scheme for url %@", url);
    }
}


- (void)showTellAFriend
{
    DLogFuncName();

    [[PSMapAtmoMapAnalytics sharedInstance] trackView:@"settings-tellAFriend"];
    
    if ([[iTellAFriend sharedInstance] canTellAFriend])
    {
        // [[PSNetAtmoAppearance sharedInstance] applyComposerInterfaceApperance];

        MFMailComposeViewController * tellAFriendController = (MFMailComposeViewController*)[[iTellAFriend sharedInstance] tellAFriendController];
        tellAFriendController.mailComposeDelegate = self;
        
        [self presentViewController:tellAFriendController animated:YES completion:nil];
    }
    else
    {
        NSLog(@"Doesn't support 'tell a friend'");
    }
}


- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result) {
        case MFMailComposeResultSent:
            [[PSMapAtmoMapAnalytics sharedInstance] trackEventSettingsTellAFriendSend];
            break;
        case MFMailComposeResultCancelled:
            [[PSMapAtmoMapAnalytics sharedInstance] trackEventSettingsTellAFriendCancelled];
            break;
        case MFMailComposeResultSaved:
            [[PSMapAtmoMapAnalytics sharedInstance] trackEventSettingsTellAFriendSaved];
            break;
        case MFMailComposeResultFailed:
            [[PSMapAtmoMapAnalytics sharedInstance] trackEventSettingsTellAFriendFailed];
            break;
    }
    [controller dismissModalViewControllerAnimated:YES];
}


- (void)showAppRating
{
    DLogFuncName();
    [[PSMapAtmoMapAnalytics sharedInstance] trackView:@"settings-appRating"];
    
    [[iRate sharedInstance] openRatingsPageInAppStore];
}


@end
