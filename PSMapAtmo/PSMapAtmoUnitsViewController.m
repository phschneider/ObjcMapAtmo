//
// Created by Philip Schneider on 12.01.14.
// Copyright (c) 2014 phschneider.net. All rights reserved.
//

#import "PSMapAtmoUnitsViewController.h"
#import "PSMapAtmoUserDefaults.h"
#import "PSMapAtmoMapAnalytics.h"

@interface PSMapAtmoUnitsViewController()

@property (nonatomic) UITableView * tableView;
@property (nonatomic) NSArray * tableData;

@end

@implementation PSMapAtmoUnitsViewController

- (id)init
{
    DLogFuncName();
    self = [super init];
    if (self)
    {
        self.title = [NSLocalizedString(@"units", nil) capitalizedString];

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
    [[PSMapAtmoMapAnalytics sharedInstance] trackView:@"settings-units"];
}


- (void) reload
{
    DLogFuncName();

    BOOL useFahrenheit = [[PSMapAtmoUserDefaults sharedInstance] useFahrenheit];
    BOOL useMiles = [[PSMapAtmoUserDefaults sharedInstance] useMiles];

    self.tableData = @[
                           @{
                                @"title" : @"Temperature",
                                @"subtitle" : @"",
                                @"rows" :
                                    @[
                                        @{ @"title" : @"Fahrenheit" , @"selected" : @(useFahrenheit), @"selector" : NSStringFromSelector(@selector(setUseFahrenheitAsTempUnit)) },
                                        @{ @"title" : @"Celsius", @"selected" : @(!useFahrenheit), @"selector" : NSStringFromSelector(@selector(setUseCelsiusAsTempUnit))}
                                    ]
                            },

                           @{
                               @"title" : @"Distance",
                               @"subtitle" : @"Distance will be calculated for each pin, but is only shown when location tracking is enabled. You can enable location tracking by tapping the gps-icon in the lower left corner of the screen.",
                               @"rows" :
                                   @[
                                       @{ @"title" : @"Miles" , @"selected" : @(useMiles), @"selector" : NSStringFromSelector(@selector(setUseMilesAsDistanceUnit))},
                                       @{ @"title" : @"Kilometers", @"selected" : @(!useMiles), @"selector" : NSStringFromSelector(@selector(setUseKilometersAsDistanceUnit))  }
                                    ]
                            }
                           ];

    [self.tableView reloadData];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    DLogFuncName();
    NSDictionary * dict = self.tableData[(NSUInteger) section];
    return dict[@"title"];
}


- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    DLogFuncName();
    NSDictionary * dict = self.tableData[(NSUInteger) section];
    return dict[@"subtitle"];
}


#pragma mark - TableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLogFuncName();
    NSString * cellIdentifier = @"UnitsCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    NSDictionary * section = self.tableData[(NSUInteger) indexPath.section];
    NSDictionary * row = [section[@"rows"] objectAtIndex:(NSUInteger) indexPath.row];

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = row[@"title"];
    cell.accessoryType = (UITableViewCellAccessoryType) (([row[@"selected"] boolValue]) ? UITableViewCellAccessoryCheckmark : nil);
    cell.userInteractionEnabled = (![row[@"selected"] boolValue]);
    
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
    NSDictionary * dict= self.tableData[(NSUInteger) section];
    
    return [dict[@"rows"] count];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLogFuncName();
    NSDictionary * section = self.tableData[(NSUInteger) indexPath.section];
    NSDictionary * row = [section[@"rows"] objectAtIndex:(NSUInteger) indexPath.row];
    NSString * selectorName = row[@"selector"];

    BOOL selectionChanged = (![row[@"selected"] boolValue]);
    if (selectionChanged)
    {
        [self trackAnalyticsEventForSelectorName:selectorName];
       
        SEL selector = NSSelectorFromString(selectorName);
        if ([[PSMapAtmoUserDefaults sharedInstance] respondsToSelector:selector])
        {
            [[PSMapAtmoUserDefaults sharedInstance] performSelector:selector];
            [self reload];
        }
    }
}


- (void)trackAnalyticsEventForSelectorName:(NSString *)selectorName
{
    DLogFuncName();

    if ([selectorName isEqualToString:@"setUseKilometersAsDistanceUnit"])
        {
            [[PSMapAtmoMapAnalytics sharedInstance] trackEventSystemUnitsKilometers];
        }
        else if ([selectorName isEqualToString:@"setUseMilesAsDistanceUnit"])
        {
            [[PSMapAtmoMapAnalytics sharedInstance] trackEventSystemUnitsMiles];
        }
        else if ([selectorName isEqualToString:@"setUseCelsiusAsTempUnit"])
        {
            [[PSMapAtmoMapAnalytics sharedInstance] trackEventSystemUnitsCelsius];
        }
        else if ([selectorName isEqualToString:@"setUseFahrenheitAsTempUnit"])
        {
            [[PSMapAtmoMapAnalytics sharedInstance] trackEventSystemUnitsFahrenheit];
        }
}

@end