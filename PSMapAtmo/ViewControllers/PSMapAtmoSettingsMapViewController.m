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

@interface PSMapAtmoSettingsMapViewController ()

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
                                   @{ @"title" : @"Standard" , @"selected" : [NSNumber numberWithBool:(mapType == MKMapTypeStandard)], @"selector" : NSStringFromSelector(@selector(setMapType:)) },
                                   @{ @"title" : @"Satellite", @"selected" : [NSNumber numberWithBool:(mapType == MKMapTypeSatellite)] , @"selector" : NSStringFromSelector(@selector(setMapType:))},
                                   @{ @"title" : @"Hybrid", @"selected" : [NSNumber numberWithBool:(mapType == MKMapTypeHybrid)] , @"selector" : NSStringFromSelector(@selector(setMapType:))}
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
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLogFuncName();
    NSString * cellIdentifier = @"MapCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary * section = [self.tableData objectAtIndex:indexPath.section];
    NSDictionary * row = [[section objectForKey:@"rows"] objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [row objectForKey:@"title"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
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

            [[PSMapAtmoUserDefaults sharedInstance] performSelector:selector withObject:[NSNumber numberWithInt:indexPath.row]];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PSMAPATMO_CHANGE_MAP_TYPE"  object:nil userInfo:@{@"mapType" : [NSNumber numberWithInt:indexPath.row]}];
            [self reload];
        }
    }
}


- (void)trackAnalyticsEventForSelectorName:(NSString *)selectorName andObject:(NSIndexPath*)indexPath
{
    DLogFuncName();

    NSDictionary * section = [self.tableData objectAtIndex:indexPath.section];
    NSDictionary * row = [[section objectForKey:@"rows"] objectAtIndex:indexPath.row];
    NSString * title = [row objectForKey:@"title"];

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