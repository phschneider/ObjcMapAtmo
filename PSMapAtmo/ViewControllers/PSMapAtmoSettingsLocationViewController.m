//
//  PSMapAtmoSettingsLocationViewController.m
//  MapAtmo
//
//  Created by Philip Schneider on 17.02.14.
//  Copyright (c) 2014 phschneider.net. All rights reserved.
//

#import "PSMapAtmoSettingsLocationViewController.h"
#import "PSMapAtmoUserDefaults.h"
#import "PSMapAtmoMapAnalytics.h"
#import "PSMapAtmoLocation.h"


@interface PSMapAtmoSettingsLocationViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic) UITableView * tableView;
@property (nonatomic) NSArray * tableData;

@end

@implementation PSMapAtmoSettingsLocationViewController

- (id)init
{
    DLogFuncName();
    self = [super init];
    if (self)
    {
        self.title = [NSLocalizedString(@"location", nil) capitalizedString];
        
        self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        [self.view addSubview:self.tableView];
        
        [self reload];
    }
    return self;
}


- (void)viewDidAppear:(BOOL)animated
{
    DLogFuncName();
    [super viewDidAppear:animated];
    [[PSMapAtmoMapAnalytics sharedInstance] trackView:@"settings-location"];
}


- (void) reload
{
    DLogFuncName();
    
    BOOL useFilter = YES;

    PSMapAtmoLocation *location = [[PSMapAtmoUserDefaults sharedInstance] location];

    self.tableData = @[
                       @{
                           @"title" : @"",
                           @"subtitle" : @"",
                           @"rows" :
                               @[
                                   @{ @"title" : @"Default (country from iOS-Settings)" , @"selected" : @(location.locationType == PSMapAtmoLocationTypeDefault), @"selector" : NSStringFromSelector(@selector(setLocation:)) },
                                   @{ @"title" : @"My location", @"selected" : @(location.locationType == PSMapAtmoLocationTypeUserLocation), @"selector" : NSStringFromSelector(@selector(setLocation:))},
                                   @{ @"title" : @"Current view", @"selected" : @(location.locationType == PSMapAtmoLocationTypeCurrentLocation), @"selector" : NSStringFromSelector(@selector(setLocation:))},
                                   @{ @"title" : @"Open as leaved", @"selected" : @(location.locationType == PSMapAtmoLocationTypeLastLocation), @"selector" : NSStringFromSelector(@selector(setLocation:))}
                                   ]
                           }
                       ];
    
    [self.tableView reloadData];
}


#pragma mark - TableView
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    DLogFuncName();
    if (tableView == self.tableView)
    {
        NSDictionary *dict = self.tableData[(NSUInteger) section];
        return dict[@"title"];
    }
    return nil;
}


- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    DLogFuncName();
    if (tableView == self.tableView)
    {
        NSDictionary *dict = self.tableData[(NSUInteger) section];
        return dict[@"subtitle"];
    }
    return nil;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    DLogFuncName();
    if (tableView == self.tableView)
    {
        return 1;
    }
    return 0;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    DLogFuncName();
    if (tableView == self.tableView)
    {
        return 4;
    }
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLogFuncName();
    NSString * cellIdentifier = @"LocationCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary * section = self.tableData[(NSUInteger) indexPath.section];
    NSDictionary * row = [section[@"rows"] objectAtIndex:(NSUInteger) indexPath.row];
    
    cell.textLabel.text = row[@"title"];
    cell.accessoryType = (UITableViewCellAccessoryType) (([row[@"selected"] boolValue]) ? UITableViewCellAccessoryCheckmark : nil);
    cell.userInteractionEnabled = (![row[@"selected"] boolValue]);
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLogFuncName();
    if (tableView == self.tableView)
    {
        NSDictionary * section = self.tableData[(NSUInteger) indexPath.section];
        NSDictionary * row = [section[@"rows"] objectAtIndex:(NSUInteger) indexPath.row];
        NSString * selectorName = row[@"selector"];

        BOOL selectionChanged = (![row[@"selected"] boolValue]);
        if (selectionChanged)
        {
            SEL selector = NSSelectorFromString(selectorName);
            if ([[PSMapAtmoUserDefaults sharedInstance] respondsToSelector:selector])
            {
                [self trackAnalyticsEventForSelectorName:selectorName andObject:indexPath];

                PSMapAtmoLocation *location = nil;
                switch (indexPath.row)
                {
                    case 0:
                        location = [PSMapAtmoLocation defaultLocation];

                        break;
                    case 1:
                        location = [PSMapAtmoLocation userLocation];

                        break;
                    case 2:
                        location = [PSMapAtmoLocation currentLocation];

                        break;
                    case 3:
                        location = [PSMapAtmoLocation lastLocation];

                        break;
                    default:
                        break;
                }

                [[PSMapAtmoUserDefaults sharedInstance] performSelector:selector withObject:location];
                [self reload];
            }

            [[NSNotificationCenter defaultCenter] postNotificationName:@"PSMAPATMO_CHANGE_MAP_TYPE" object:nil];
        }
    }
}


- (void)trackAnalyticsEventForSelectorName:(NSString *)selectorName andObject:(NSIndexPath*)indexPath
{
    DLogFuncName();

//    NSDictionary * section = self.tableData[(NSUInteger) indexPath.section];
//    NSDictionary * row = [section[@"rows"] objectAtIndex:(NSUInteger) indexPath.row];

    [[PSMapAtmoMapAnalytics sharedInstance] trackEventSystemLocationChange];

    switch (indexPath.row)
    {
        case 0:
            [[PSMapAtmoMapAnalytics sharedInstance] trackEventSystemLocationDefault];

            break;
        case 1:
            [[PSMapAtmoMapAnalytics sharedInstance] trackEventSystemLocationUserLocation];

            break;
        case 2:
            [[PSMapAtmoMapAnalytics sharedInstance] trackEventSystemLocationCurrentLocation];

            break;
        case 3:
            [[PSMapAtmoMapAnalytics sharedInstance] trackEventSystemLocationLastLocation];

            break;
        default:
            break;
    }
}

@end
