//
// Created by Philip Schneider on 19.01.14.
// Copyright (c) 2014 phschneider.net. All rights reserved.
//

#import "PSMapAtmoFilterViewController.h"
#import "PSMapAtmoUserDefaults.h"
#import "PSMapAtmoAlertViewDelegate.h"
#import "PSMapAtmoMapAnalytics.h"
#import "NSObject+Runtime.h"
#import "PSMapAtmoConverter.h"
#import "TDBadgedCell.h"
#import "PSMapAtmoFilter.h"

@interface PSMapAtmoFilterViewController()

@property (nonatomic) UITableView * tableView;
@property (nonatomic) NSArray * tableData;
@property (nonatomic) PSMapAtmoFilter *filter;

@end


@implementation PSMapAtmoFilterViewController

- (id)init
{
    DLogFuncName();
    self = [super init];
    if (self)
    {
        self.title = [NSLocalizedString(@"filter", nil) capitalizedString];
        self.filter = [[PSMapAtmoUserDefaults sharedInstance] filter];

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
    [[PSMapAtmoMapAnalytics sharedInstance] trackView:@"settings-filter"];
}


- (void)viewDidDisappear:(BOOL)animated
{
    DLogFuncName();

    NSLog(@"DidDissappear!!!");
    #warning todo - set userdefaults if value isn't default!!!
}

- (void) updateDataSource
{
    DLogFuncName();

    BOOL useFilter = [self.filter isEnabled];
    BOOL useDefaultFilter = [self.filter isDefault];

    NSLog(@"UseFilter = %@", (useFilter) ? @"YES" : @"NO");
    NSLog(@"useDefaultFilter = %@", (useDefaultFilter) ? @"YES" : @"NO");
    
    NSDictionary *filterEnabled = @{ @"title" : @"Filter enabled" , @"selected" : [NSNumber numberWithBool:useFilter], @"selector" : NSStringFromSelector(@selector(setFilter:)) };
    NSDictionary *filterDefault = @{ @"title" : @"Use default value" , @"selected" : [NSNumber numberWithBool:useDefaultFilter] , @"selector" : NSStringFromSelector(@selector(setFilter:)), @"level" : @1 };
    NSDictionary *filterDisabled = @{ @"title" : @"Filter disabled", @"selected" : [NSNumber numberWithBool:!useFilter] , @"selector" : NSStringFromSelector(@selector(setFilter:))};
    NSMutableDictionary *filterCustom = [NSMutableDictionary dictionaryWithDictionary:@{ @"title" : @"Use custom value (pro)" , @"selected" : [NSNumber numberWithBool:!useDefaultFilter] , @"selector" : NSStringFromSelector(@selector(setFilter:)), @"canSelect" : [NSNumber numberWithBool:NO], @"level" : @1 }];
    NSDictionary *filterSlider = @{ @"title" : @"Slider" , @"selected" : [NSNumber numberWithBool:NO] , @"canSelect" : [NSNumber numberWithBool:NO], @"level" : @1 };

    
    if (useFilter)
    {
        if (useDefaultFilter)
        {
        self.tableData = @[
                           @{
                               @"title" : @"",
                               @"subtitle" : @"",
                               @"rows" :
                                   @[
                                           filterEnabled,
                                           filterDefault,
                                           filterCustom,
                                           filterDisabled
                                       ]
                               }];
        }
        else
        {
            [filterCustom setObject:@"wird über den filtervalue as string gesetzt" forKey:@"badge"];
            self.tableData = @[
                               @{
                                   @"title" : @"",
                                   @"subtitle" : @"",
                                   @"rows" :
                                       @[
                                           filterEnabled,
                                           filterDefault,
                                           filterCustom,
                                           filterSlider,
                                           filterDisabled
                                           ]
                                   }];
        }
    }
    else
    {
        self.tableData = @[
                           @{
                               @"title" : @"",
                               @"subtitle" : @"",
                               @"rows" :
                                   @[
                                           filterEnabled,
                                           filterDisabled
                                       ]
                               }
                           ];

    }
}


- (void) reload
{
    DLogFuncName();

    [self updateDataSource];
    [self.tableView reloadData];
}


- (void)viewWillDisappear:(BOOL)animated
{
    DLogFuncName();
    [super viewWillDisappear:animated];

     if ([self.filter isEqual: [[PSMapAtmoUserDefaults sharedInstance] filter]])
     {
         [[PSMapAtmoMapAnalytics sharedInstance] trackView:@"settings-filter-alert"];

         UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Filter"
                                                              message:@"Changing filter will invalidate the map.\nShould we clear it?"
                                                             delegate:[PSMapAtmoAlertViewDelegate sharedInstance]
                                                    cancelButtonTitle:@"cancel"
                                                    otherButtonTitles:@"change without clearing", @"ok, clear", nil ];
         [alertView show];
     }
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
    return [self.tableData count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    DLogFuncName();
    return [[[self.tableData objectAtIndex:section] objectForKey:@"rows"] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLogFuncName();
    NSString * cellIdentifier = @"FilterCell";
    TDBadgedCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell)
    {
        cell = [[TDBadgedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.indentationWidth = 20.0;
    }

    NSDictionary * section = [self.tableData objectAtIndex:indexPath.section];
    NSDictionary * row = [[section objectForKey:@"rows"] objectAtIndex:indexPath.row];

    if ([[row allKeys] containsObject:@"level"])
    {
        cell.indentationLevel = [[row objectForKey:@"level"] integerValue];
    }
    else
    {
        cell.indentationLevel = 0;
    }

    
    cell.textLabel.text = [row objectForKey:@"title"];
    cell.accessoryType = ([[row objectForKey:@"selected"] boolValue]) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    cell.userInteractionEnabled = (![[row objectForKey:@"selected"] boolValue]);

    
    if ([[[row objectForKey:@"title"] lowercaseString] isEqualToString:@"slider"])
    {
        NSLog(@"Show Slider!!!");
        cell.textLabel.text = @"";
        float min = 1;
        float max = 14;

        int viewWidth = 40;
        int cellContentSpacing = 15;
        int fontSize = 12;

        CGRect cellBounds = cell.bounds;

        #warning todo - prüfen ob slider nicht schon in der zelle vorhanden ist!!!
        
        // Min
        UIView *minView = [cell.contentView viewWithTag:111];
        if (!minView)
        {
            minView = [[UIView alloc] initWithFrame:CGRectMake(cell.indentationLevel * cell.indentationWidth + cellContentSpacing ,0,cellBounds.size.height,viewWidth)];
            minView.tag = 111;
            //        minView.backgroundColor = [UIColor blueColor];
            minView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
            
            UILabel *minCelsiusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,40,ceil(cellBounds.size.height/2))];
            minCelsiusLabel.textAlignment = UITextAlignmentLeft;
            minCelsiusLabel.font = [UIFont systemFontOfSize:fontSize];
            minCelsiusLabel.text = [NSString stringWithFormat:@"%.1f°C", min];
            [minView addSubview:minCelsiusLabel];
            
            UILabel *minFahrenheitLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,ceil(cellBounds.size.height/2),40,ceil(cellBounds.size.height/2))];
            minFahrenheitLabel.textAlignment = UITextAlignmentLeft;
            minFahrenheitLabel.font = [UIFont systemFontOfSize:fontSize];
            minFahrenheitLabel.text = [NSString stringWithFormat:@"%.1f°F", [[PSMapAtmoConverter sharedInstance] convertCelsiusToFahrenheit:min] ];
            [minView addSubview:minFahrenheitLabel ];
            
            [cell.contentView addSubview:minView];
        }
        
        // Max
        UIView *maxView = [cell.contentView viewWithTag:999];
        if (!maxView)
        {
            maxView = [[UIView alloc] initWithFrame:CGRectMake(cellBounds.size.width-40-cellContentSpacing ,0,cellBounds.size.height,viewWidth)];
            maxView.tag = 999;
            maxView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            //        maxView.backgroundColor = [UIColor redColor];
            
            UILabel *maxCelsiusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,40,ceil(cellBounds.size.height/2))];
            maxCelsiusLabel.font = [UIFont systemFontOfSize:fontSize];
            maxCelsiusLabel.textAlignment = UITextAlignmentRight;
            maxCelsiusLabel.text = [NSString stringWithFormat:@"%.1f°C", max];
            [maxView addSubview:maxCelsiusLabel];
            
            UILabel *maxFahrenheitLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,ceil(cellBounds.size.height/2),40,ceil(cellBounds.size.height/2))];
            maxFahrenheitLabel.font = [UIFont systemFontOfSize:fontSize];
            maxFahrenheitLabel.textAlignment = UITextAlignmentRight;
            maxFahrenheitLabel.text = [NSString stringWithFormat:@"%.1f°F", [[PSMapAtmoConverter sharedInstance] convertCelsiusToFahrenheit:max]];
            [maxView addSubview:maxFahrenheitLabel];
            
            
            [cell.contentView addSubview:maxView];
        }
        
        // Slider
        UISlider *slider = nil;
        for (UIView *view in cell.contentView.subviews)
        {
            if ([view isKindOfClass:[UISlider class]])
            {
                slider = (UISlider*)view;
            }
        }
        
        if (!slider)
        {
            int paddingX = cell.indentationLevel * cell.indentationWidth + cellContentSpacing + viewWidth + cellContentSpacing;
            CGRect sliderFrame = CGRectMake(paddingX, 0, cellBounds.size.width - paddingX - paddingX, cellBounds.size.height);
            slider = [[UISlider alloc] initWithFrame:sliderFrame];
            [slider addTarget:self action:@selector(sliderUpdate:) forControlEvents:UIControlEventValueChanged];
            //        slider.bounds = CGRectMake(viewWidth + cellContentSpacing  + cellContentSpacing , 0, cell.contentView.bounds.size.width - cellContentSpacing - viewWidth - cellContentSpacing , slider.bounds.size.height);
            //        slider.center = CGPointMake(CGRectGetMidX(cell.contentView.bounds), CGRectGetMidY(cell.contentView.bounds));
            slider.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
            slider.minimumValue = min;
            slider.maximumValue = max;
            slider.tag = 666;
            [cell.contentView addSubview:slider];
        }
        
        slider.value = [[self.filter value] floatValue];
    }
    else
    {
        [[cell.contentView viewWithTag:111] removeFromSuperview];
        [[cell.contentView viewWithTag:999] removeFromSuperview];
        [[cell.contentView viewWithTag:666] removeFromSuperview];
    }

    if ([[row allKeys] containsObject:@"badge"] && ![[row objectForKey:@"badge"] isEqualToString:@""])
    {
        cell.badgeString = [self.filter stringValue];
        cell.badge.radius = 9;
        cell.badgeColor =  [UIColor colorWithRed:0.32 green:0.55 blue:0.98 alpha:1];
    }
    else
    {
        cell.badgeString = nil;
    }
    
    
    if ([[row allKeys] containsObject:@"canSelect"] && ![[row objectForKey:@"canSelect"] boolValue])
    {
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    else
    {
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
   
    return cell;
}


- (void) sliderUpdate:(id)sender
{
    DLogFuncName();

    UISlider *slider =sender;
    NSLog(@"VALUE = %f", slider.value);

    float newStep = roundf((slider.value));
    NSLog(@"VALUE = %f", newStep);

    // Convert "steps" back to the context of the sliders values.
    slider.value = newStep;
 
    self.filter.value = [NSNumber numberWithFloat:slider.value];
    
    [self updateDataSource];
    [self.tableView reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:2 inSection:0] ] withRowAnimation:UITableViewRowAnimationNone];
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
            
            switch (indexPath.row)
            {
                case 0:
                    [self.filter setEnabled];
                    break;
                case 1:
                    {
                        if ([self.filter isEnabled])
                        {
                            [self.filter setIsDefault];
                        }
                        else
                        {
                            [self.filter setDisabled];
                        }
                    }
                    break;
                case 2:
                    // DO NOTHING => CUSTOM
                    if ([self.filter isEnabled])
                    {
                        [self.filter setIsCustom];
                    }
                    break;
                case 3:
                    // DO NOTHING => SLIDER
                    if ([self.filter isDefault]) // kein Slider wird angezeigt
                    {
                        if ([self.filter isEnabled])
                        {
                            [self.filter setDisabled];
                        }
                    }
                    break;
                    
                case 4:
                    {
                        if ([self.filter isEnabled])
                        {
                            [self.filter setDisabled];
                        }
                    }
                    break;
                default:
                    break;
            }
            
            [[PSMapAtmoUserDefaults sharedInstance] performSelector:selector withObject:self.filter];
            [self reload];
        }
    }
}


- (void)trackAnalyticsEventForSelectorName:(NSString *)selectorName andObject:(NSIndexPath*)indexPath
{
    DLogFuncName();
    
    NSDictionary * section = [self.tableData objectAtIndex:indexPath.section];
    NSDictionary * row = [[section objectForKey:@"rows"] objectAtIndex:indexPath.row];
    
    [[PSMapAtmoMapAnalytics sharedInstance] trackEventSystemFilterChange];
    switch (indexPath.row)
    {
        case 0:
            [[PSMapAtmoMapAnalytics sharedInstance] trackEventSystemFilterUseFilter];
            break;
        case 1:
        {
            if ([self.filter isEnabled])
            {
                [[PSMapAtmoMapAnalytics sharedInstance] trackEventSystemFilterUseDefaultFilter];
            }
            else
            {
                [[PSMapAtmoMapAnalytics sharedInstance] trackEventSystemFilterIgnoreFilter];
            }
        }
            break;
        case 2:
            // DO NOTHING => CUSTOM
            if ([self.filter isEnabled])
            {
                [[PSMapAtmoMapAnalytics sharedInstance] trackEventSystemFilterUseCustomFilter];
                [[PSMapAtmoMapAnalytics sharedInstance] trackEventSystemFilterUseCustomFilterWithValue:self.filter.value];
            }
            break;
        case 3:
            // DO NOTHING => SLIDER
            if ([self.filter isDefault]) // kein Slider wird angezeigt
            {
                if ([self.filter isEnabled])
                {
                    [[PSMapAtmoMapAnalytics sharedInstance] trackEventSystemFilterIgnoreFilter];
                }
            }
            break;
            
        case 4:
        {
            if ([self.filter isEnabled])
            {
                [[PSMapAtmoMapAnalytics sharedInstance] trackEventSystemFilterIgnoreFilter];
            }
        }
            break;
        default:
            break;
    }

}

@end