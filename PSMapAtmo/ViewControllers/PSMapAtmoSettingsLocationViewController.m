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


@interface PSMapAtmoSettingsLocationViewController ()
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
                                   @{ @"title" : @"Default (country from iOS-Settings)" , @"selected" : [NSNumber numberWithBool:(location.locationType == PSMapAtmoLocationTypeDefault)], @"selector" : NSStringFromSelector(@selector(setLocation:)) },
                                   @{ @"title" : @"My location", @"selected" : [NSNumber numberWithBool:(location.locationType == PSMapAtmoLocationTypeUserLocation)] , @"selector" : NSStringFromSelector(@selector(setLocation:))},
                                   @{ @"title" : @"Current view", @"selected" : [NSNumber numberWithBool:(location.locationType == PSMapAtmoLocationTypeCurrentLocation)] , @"selector" : NSStringFromSelector(@selector(setLocation:))},
                                   @{ @"title" : @"Open as leaved", @"selected" : [NSNumber numberWithBool:(location.locationType == PSMapAtmoLocationTypeLastLocation)] , @"selector" : NSStringFromSelector(@selector(setLocation:))}
                                   ]
                           }
                       ];
    
    [self.tableView reloadData];
}


#pragma mark - TableView
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    DLogFuncName();
    NSDictionary * dict = [self.tableData objectAtIndex:section];
    return [dict objectForKey:@"title"];
}


- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    DLogFuncName();
    NSDictionary * dict = [self.tableData objectAtIndex:section];
    return [dict objectForKey:@"subtitle"];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    DLogFuncName();
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    DLogFuncName();
    return 4;
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
    
    NSDictionary * section = [self.tableData objectAtIndex:indexPath.section];
    NSDictionary * row = [[section objectForKey:@"rows"] objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [row objectForKey:@"title"];
    cell.accessoryType = ([[row objectForKey:@"selected"] boolValue]) ? UITableViewCellAccessoryCheckmark : nil;
    cell.userInteractionEnabled = (![[row objectForKey:@"selected"] boolValue]);
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLogFuncName();
    NSDictionary * section = [self.tableData objectAtIndex:indexPath.section];
    NSDictionary * row = [[section objectForKey:@"rows"] objectAtIndex:indexPath.row];
    NSString * selectorName = [row objectForKey:@"selector"];
    
    BOOL selectionChanged = (![[row objectForKey:@"selected"] boolValue]);
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


- (void)trackAnalyticsEventForSelectorName:(NSString *)selectorName andObject:(NSIndexPath*)indexPath
{
    DLogFuncName();

    NSDictionary * section = [self.tableData objectAtIndex:indexPath.section];
    NSDictionary * row = [[section objectForKey:@"rows"] objectAtIndex:indexPath.row];

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
