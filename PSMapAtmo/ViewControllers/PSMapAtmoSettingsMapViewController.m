//
//  PSMapAtmoSettingsMapViewController.m
//  MapAtmo
//
//  Created by Philip Schneider on 16.02.14.
//  Copyright (c) 2014 phschneider.net. All rights reserved.
//

#import "PSMapAtmoSettingsMapViewController.h"
#import "PSMapAtmoUserDefaults.h"
#import "PSMapAtmoMapAnalytics.h"

@interface PSMapAtmoSettingsMapViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) UITableView * tableView;
@property (nonatomic) NSArray * tableData;

@end

@implementation PSMapAtmoSettingsMapViewController

- (id)init
{
    DLogFuncName();
    self = [super init];
    if (self)
    {
        self.title = [NSLocalizedString(@"map", nil) capitalizedString];
        
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
    [[PSMapAtmoMapAnalytics sharedInstance] trackView:@"settings-map"];
}


- (void) reload
{
    DLogFuncName();
    
    MKMapType mapType = [[PSMapAtmoUserDefaults sharedInstance] mapType];

    self.tableData = @[
                       @{
                           @"title" : @"",
                           @"subtitle" : @"",
                           @"rows" :
                               @[
                                   @{ @"title" : @"Standard" , @"selected" : @(mapType == MKMapTypeStandard), @"selector" : NSStringFromSelector(@selector(setMapType:)) },
                                   @{ @"title" : @"Satellite", @"selected" : @(mapType == MKMapTypeSatellite), @"selector" : NSStringFromSelector(@selector(setMapType:))},
                                   @{ @"title" : @"Hybrid", @"selected" : @(mapType == MKMapTypeHybrid), @"selector" : NSStringFromSelector(@selector(setMapType:))}
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
        NSDictionary * dict = self.tableData[(NSUInteger) section];
        return dict[@"title"];
    }
    return nil;
}


- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    DLogFuncName();
    if (tableView== self.tableView)
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
        return 3;
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLogFuncName();
    if (tableView == self.tableView)
    {
        NSString *cellIdentifier = @"MapCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }

        NSDictionary *section = self.tableData[(NSUInteger) indexPath.section];
        NSDictionary *row = [section[@"rows"] objectAtIndex:(NSUInteger) indexPath.row];

        cell.textLabel.text = row[@"title"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = (UITableViewCellAccessoryType) (([row[@"selected"] boolValue]) ? UITableViewCellAccessoryCheckmark : nil);
        cell.userInteractionEnabled = (![row[@"selected"] boolValue]);

        return cell;
    }
    return nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLogFuncName();
    if (tableView == self.tableView)
    {
        NSDictionary *section = self.tableData[(NSUInteger) indexPath.section];
        NSDictionary *row = [section[@"rows"] objectAtIndex:(NSUInteger) indexPath.row];
        NSString *selectorName = row[@"selector"];

        BOOL selectionChanged = (![row[@"selected"] boolValue]);
        if (selectionChanged)
        {
            SEL selector = NSSelectorFromString(selectorName);
            if ([[PSMapAtmoUserDefaults sharedInstance] respondsToSelector:selector])
            {
                [self trackAnalyticsEventForSelectorName:selectorName andObject:indexPath];

                [[PSMapAtmoUserDefaults sharedInstance] performSelector:selector withObject:@(indexPath.row)];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"PSMAPATMO_CHANGE_MAP_TYPE" object:nil userInfo:@{@"mapType" : @(indexPath.row)}];
                [self reload];
            }
        }
    }
}


- (void)trackAnalyticsEventForSelectorName:(NSString *)selectorName andObject:(NSIndexPath*)indexPath
{
    DLogFuncName();

//    NSDictionary * section = self.tableData[(NSUInteger) indexPath.section];
//    NSDictionary * row = [section[@"rows"] objectAtIndex:(NSUInteger) indexPath.row];
//    NSString * title = row[@"title"];

    [[PSMapAtmoMapAnalytics sharedInstance] trackEventSystemMapChange];

    switch (indexPath.row)
    {
        case 0:
            [[PSMapAtmoMapAnalytics sharedInstance] trackEventSystemMapStandard];

            break;
        case 1:
            [[PSMapAtmoMapAnalytics sharedInstance] trackEventSystemMapSatellite];

            break;
        case 2:
            [[PSMapAtmoMapAnalytics sharedInstance] trackEventSystemMapHybrid];

            break;
        default:
            break;
    }
}

@end
