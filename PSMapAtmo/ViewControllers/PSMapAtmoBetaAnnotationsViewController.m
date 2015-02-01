//
// Created by Philip Schneider on 01.02.15.
// Copyright (c) 2015 phschneider.net. All rights reserved.
//

#import <TDBadgedCell/TDBadgedCell.h>
#import "PSMapAtmoBetaAnnotationsViewController.h"
#import "PSMapAtmoUserDefaults.h"
#import "PSMapAtmoMapAnalytics.h"
#import "PSMapAtmoAnnotationSettings.h"


@interface PSMapAtmoBetaAnnotationsViewController()

@property (nonatomic) UITableView * tableView;
@property (nonatomic) NSMutableArray * tableData;
@property (nonatomic) PSMapAtmoAnnotationSettings *annotationSettings;

@end



@implementation PSMapAtmoBetaAnnotationsViewController

- (id)init
{
    DLogFuncName();
    self = [super init];
    if (self)
    {
        self.title = [NSLocalizedString(@"annotations", nil) capitalizedString];
        self.annotationSettings = [[PSMapAtmoUserDefaults sharedInstance] annotationSettings];

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
    [[PSMapAtmoMapAnalytics sharedInstance] trackView:@"settings-annotations"];
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

    BOOL showsCustomAnnotation = [self.annotationSettings showsCustomImage];
    BOOL showsValueInAnnotation = [self.annotationSettings showsValueInAnnotation];
    BOOL changeBackgroundSizeAutomatically = [self.annotationSettings changeBackgroundSizeAutomatically];
    
    NSLog(@"showCustomAnnotation = %@", (showsCustomAnnotation) ? @"YES" : @"NO");
    NSLog(@"showValueInAnnotation = %@", (showsValueInAnnotation) ? @"YES" : @"NO");

    NSMutableDictionary *showCustomAnnotation = [NSMutableDictionary dictionaryWithDictionary:@{ @"title" : @"Show custom annotation" , @"selected" : @(showsCustomAnnotation), @"selector" : NSStringFromSelector(@selector(setAnnotationSettings:)) }];
    NSDictionary *hideCustomAnnotation = @{ @"title" : @"Hide custom annotation", @"selected" : @(!showsCustomAnnotation), @"selector" : NSStringFromSelector(@selector(setAnnotationSettings:))};
    NSDictionary *customAnnotationSizeSlider = @{ @"title" : @"slider" , @"selected" : @NO, @"canSelect" : @NO, @"level" : @1 };

    NSMutableDictionary *showValueInAnnotation = [NSMutableDictionary dictionaryWithDictionary:@{ @"title" : @"Show value in annotation" , @"selected" : @(showsValueInAnnotation), @"selector" : NSStringFromSelector(@selector(setAnnotationSettings:)) }];
    NSDictionary *hideValueInAnnotation = @{ @"title" : @"Hide value in annotation", @"selected" : @(!showsValueInAnnotation), @"selector" : NSStringFromSelector(@selector(setAnnotationSettings:))};
    NSDictionary *valueFontSizeSlider = @{ @"title" : @"slider" , @"selected" : @NO, @"canSelect" : @NO, @"level" : @1 };

    NSMutableDictionary *customizeBackground = [NSMutableDictionary dictionaryWithDictionary:@{ @"title" : @"Change background size manually" , @"selected" : @(!changeBackgroundSizeAutomatically), @"selector" : NSStringFromSelector(@selector(setAnnotationSettings:)) }];
    NSDictionary *adjustBackgroundAutomatically = @{ @"title" : @"Change background size automatically", @"selected" : @(changeBackgroundSizeAutomatically), @"selector" : NSStringFromSelector(@selector(setAnnotationSettings:))};
    NSDictionary *valueBackgroundSizeSlider = @{ @"title" : @"slider" , @"selected" : @NO, @"canSelect" : @NO, @"level" : @1 };

    // Annotation
    if (showsCustomAnnotation)
    {
        showCustomAnnotation[@"badge"] = @"wird über den filtervalue as string gesetzt";
        self.tableData = [@[
                @{
                        @"title" : @"Images",
                        @"subtitle" : @"",
                        @"rows" :
                        @[
                                showCustomAnnotation,
                                customAnnotationSizeSlider,
                                hideCustomAnnotation
                        ]
                }
        ] mutableCopy];
    }
    else
    {
        self.tableData = [@[
                @{
                        @"title" : @"Images",
                        @"subtitle" : @"",
                        @"rows" :
                        @[
                                showCustomAnnotation,
                                hideCustomAnnotation
                        ]
                }
        ] mutableCopy];
    }

    //Value
    NSArray *fontArray = nil;
    if (showsValueInAnnotation)
    {
        showValueInAnnotation[@"badge"] = @"wird über den filtervalue as string gesetzt";
        fontArray = @[
            @{
                            @"title" : @"Values (font)",
                            @"subtitle" : @"",
                            @"rows" :
                            @[
                                    showValueInAnnotation,
                                    valueFontSizeSlider,
                                    hideValueInAnnotation
                            ]
                    }
            ];
    }
    else
    {
        fontArray = @[
                    @{
                            @"title" : @"Values (font)",
                            @"subtitle" : @"",
                            @"rows" :
                            @[
                                    showValueInAnnotation,
                                    hideValueInAnnotation
                            ]
                    }
            ];
    }

    [self.tableData addObjectsFromArray:fontArray];

    //Value
    NSArray *backgroundArray = nil;
    if (!changeBackgroundSizeAutomatically)
    {
        customizeBackground[@"badge"] = @"wird über den filtervalue as string gesetzt";
        backgroundArray = @[
                @{
                        @"title" : @"Values (background)",
                        @"subtitle" : @"",
                        @"rows" :
                        @[
                                customizeBackground,
                                valueBackgroundSizeSlider,
                                adjustBackgroundAutomatically
                        ]
                }
        ];
    }
    else
    {
        backgroundArray = @[
                @{
                        @"title" : @"Values (background)",
                        @"subtitle" : @"",
                        @"rows" :
                        @[
                                customizeBackground,
                                adjustBackgroundAutomatically
                        ]
                }
        ];
    }

    [self.tableData addObjectsFromArray:backgroundArray];
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
//
//    if ([self.filter isEqual: [[PSMapAtmoUserDefaults sharedInstance] filter]])
//    {
//        [[PSMapAtmoMapAnalytics sharedInstance] trackView:@"settings-filter-alert"];
//
//        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Filter"
//                                                             message:@"Changing filter will invalidate the map.\nShould we clear it?"
//                                                            delegate:[PSMapAtmoAlertViewDelegate sharedInstance]
//                                                   cancelButtonTitle:@"cancel"
//                                                   otherButtonTitles:@"change without clearing", @"ok, clear", nil ];
//        [alertView show];
//    }
}


#pragma mark - TableView
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


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    DLogFuncName();
    return [self.tableData count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    DLogFuncName();
    return [[self.tableData[(NSUInteger) section] objectForKey:@"rows"] count];
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

    NSDictionary * section = self.tableData[(NSUInteger) indexPath.section];
    NSDictionary * row = [section[@"rows"] objectAtIndex:(NSUInteger) indexPath.row];

    if ([[row allKeys] containsObject:@"level"])
    {
        cell.indentationLevel = [row[@"level"] integerValue];
    }
    else
    {
        cell.indentationLevel = 0;
    }


    cell.textLabel.text = row[@"title"];
    cell.accessoryType = ([row[@"selected"] boolValue]) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    cell.userInteractionEnabled = (![row[@"selected"] boolValue]);

    BOOL imageSizeSlider = indexPath.section == 0;
    BOOL fontSizeSlider = indexPath.section == 1 && indexPath.row == 1;
    if ([[row[@"title"] lowercaseString] isEqualToString:@"slider"])
    {
        NSLog(@"Show Slider!!!");
        cell.textLabel.text = @"";
        
        float min = .0;
        float max = .0;
        if (imageSizeSlider)
        {
            min = [self.annotationSettings minImageSize];
            max = [self.annotationSettings maxImageSize];
        }
        else if (fontSizeSlider)
        {
            min = [self.annotationSettings minFontSize];
            max = [self.annotationSettings maxFontSize];
        }
        else
        {
           min = [self.annotationSettings minBackgroundSize];
           max = [self.annotationSettings maxBackgroundSize];
        }

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
            minView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;

            UILabel *minCelsiusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,40, (CGFloat) ceil(cellBounds.size.height))];
            minCelsiusLabel.textAlignment = NSTextAlignmentLeft;
            minCelsiusLabel.font = [UIFont systemFontOfSize:fontSize];
            minCelsiusLabel.text = [NSString stringWithFormat:@"%.fpx", min];
            [minView addSubview:minCelsiusLabel];

            [cell.contentView addSubview:minView];
        }

        // Max
        UIView *maxView = [cell.contentView viewWithTag:999];
        if (!maxView)
        {
            maxView = [[UIView alloc] initWithFrame:CGRectMake(cellBounds.size.width-40-cellContentSpacing ,0,cellBounds.size.height,viewWidth)];
            maxView.tag = 999;
            maxView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;

            UILabel *maxCelsiusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,40, (CGFloat) ceil(cellBounds.size.height))];
            maxCelsiusLabel.font = [UIFont systemFontOfSize:fontSize];
            maxCelsiusLabel.textAlignment = NSTextAlignmentRight;
            maxCelsiusLabel.text = [NSString stringWithFormat:@"%.fpx", max];
            [maxView addSubview:maxCelsiusLabel];

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
            int paddingX = (int) (cell.indentationLevel * cell.indentationWidth + cellContentSpacing + viewWidth + cellContentSpacing);
            CGRect sliderFrame = CGRectMake(paddingX, 0, cellBounds.size.width - paddingX - paddingX, cellBounds.size.height);
            slider = [[UISlider alloc] initWithFrame:sliderFrame];
            if (imageSizeSlider)
            {
                [slider addTarget:self action:@selector(sliderUpdateImageSize:) forControlEvents:UIControlEventValueChanged];
            }
            else if (fontSizeSlider)
            {
                [slider addTarget:self action:@selector(sliderUpdateFontSize:) forControlEvents:UIControlEventValueChanged];
            }
            else
            {
                [slider addTarget:self action:@selector(sliderUpdateBackgroundSize:) forControlEvents:UIControlEventValueChanged];
            }
            slider.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
            slider.minimumValue = min;
            slider.maximumValue = max;
            slider.tag = 666;
            [cell.contentView addSubview:slider];
        }

        if (imageSizeSlider)
        {
            slider.value = [self.annotationSettings.imageSize floatValue];
        }
        else if (fontSizeSlider)
        {
            slider.value = [self.annotationSettings.fontSize floatValue];
        }
        else
        {
            slider.value = [self.annotationSettings.backgroundSize floatValue];
        }
    }
    else
    {
        [[cell.contentView viewWithTag:111] removeFromSuperview];
        [[cell.contentView viewWithTag:999] removeFromSuperview];
        [[cell.contentView viewWithTag:666] removeFromSuperview];
    }

    if ([[row allKeys] containsObject:@"badge"] && ![row[@"badge"] isEqualToString:@""])
    {
        if (imageSizeSlider)
        {
            cell.badgeString = [NSString stringWithFormat:@"%d", [[self.annotationSettings imageSize] integerValue]];
        }
        else if (fontSizeSlider)
        {
            cell.badgeString = [NSString stringWithFormat:@"%d", [[self.annotationSettings fontSize] integerValue]];
        }
        else
        {
            cell.badgeString = [NSString stringWithFormat:@"%d", [[self.annotationSettings backgroundSize] integerValue]];
        }
        cell.badge.radius = 9;
        cell.badgeColor =  [UIColor colorWithRed:0.32 green:0.55 blue:0.98 alpha:1];
    }
    else
    {
        cell.badgeString = nil;
    }


    if ([[row allKeys] containsObject:@"canSelect"] && ![row[@"canSelect"] boolValue])
    {
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    else
    {
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }

    return cell;
}


- (void) sliderUpdateImageSize:(id)sender
{
    DLogFuncName();

    UISlider *slider =sender;
    NSLog(@"VALUE = %f", slider.value);

    int stepValue = 2;
    float newStep = roundf((slider.value) / stepValue);

    // Convert "steps" back to the context of the sliders values.
    slider.value = newStep * stepValue;
    
    if (![self.annotationSettings.imageSize isEqual:@(slider.value)])
    {
        self.annotationSettings.imageSize = @(slider.value);

        [self updateDataSource];
        [self.tableView reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:0 inSection:0] ] withRowAnimation:UITableViewRowAnimationNone];
        [[PSMapAtmoUserDefaults sharedInstance] performSelector:@selector(setAnnotationSettings:) withObject:self.annotationSettings];
    }
}


- (void) sliderUpdateFontSize:(id)sender
{
    DLogFuncName();
    
    UISlider *slider =sender;
    NSLog(@"VALUE = %f", slider.value);
    
    int stepValue = 1;
    float newStep = roundf((slider.value) / stepValue);
    
    // Convert "steps" back to the context of the sliders values.
    slider.value = newStep * stepValue;

    if (![self.annotationSettings.fontSize isEqual:@(slider.value)])
    {
        self.annotationSettings.fontSize = @(slider.value);
        
        [self updateDataSource];
        [self.tableView reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:0 inSection:1] ] withRowAnimation:UITableViewRowAnimationNone];
        [[PSMapAtmoUserDefaults sharedInstance] performSelector:@selector(setAnnotationSettings:) withObject:self.annotationSettings];
    }
}


- (void) sliderUpdateBackgroundSize:(id)sender
{
    DLogFuncName();
    
    UISlider *slider =sender;
    NSLog(@"VALUE = %f", slider.value);
    
    int stepValue = 2;
    float newStep = roundf((slider.value) / stepValue);
    
    // Convert "steps" back to the context of the sliders values.
    slider.value = newStep * stepValue;
    
    if (![self.annotationSettings.backgroundSize isEqual:@(slider.value)])
    {
        self.annotationSettings.backgroundSize = @(slider.value);
        
        [self updateDataSource];
        [self.tableView reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:0 inSection:2] ] withRowAnimation:UITableViewRowAnimationNone];
        [[PSMapAtmoUserDefaults sharedInstance] performSelector:@selector(setAnnotationSettings:) withObject:self.annotationSettings];
    }
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
        SEL selector = NSSelectorFromString(selectorName);
        if ([[PSMapAtmoUserDefaults sharedInstance] respondsToSelector:selector])
        {
//            [self trackAnalyticsEventForSelectorName:selectorName andObject:indexPath];
//
            switch (indexPath.section)
            {
                case 0:
                {
                    switch (indexPath.row)
                    {
                        case 0:
                            [self.annotationSettings setShowsCustomImage:YES];
                            break;

    
                        case 2:
                            [self.annotationSettings setShowsCustomImage:NO];
                            break;
                        default:
                            break;
                    }
                }
                    break;
                case 1:
                {
                    switch (indexPath.row)
                    {
                        case 0:
                            [self.annotationSettings setShowsValueInAnnotation:YES];
                            break;

                        case 2:
                            [self.annotationSettings setShowsValueInAnnotation:NO];
                            break;
                        default:
                            break;
                    }
                }
                    break;
                case 2:
                {
                    switch (indexPath.row)
                    {
                        case 0:
                            [self.annotationSettings setChangeBackgroundSizeAutomatically:NO];
                            break;
                            
                        case 2:
                            [self.annotationSettings setChangeBackgroundSizeAutomatically:YES];
                            break;
                        default:
                            break;
                    }
                }
                    
                    break;
                default:
                    break;

            }


            [[PSMapAtmoUserDefaults sharedInstance] performSelector:selector withObject:self.annotationSettings];
            [self reload];
        }
    }
}


- (void)trackAnalyticsEventForSelectorName:(NSString *)selectorName andObject:(NSIndexPath*)indexPath
{
    DLogFuncName();

//    NSDictionary * section = self.tableData[(NSUInteger) indexPath.section];
//    NSDictionary * row = [section[@"rows"] objectAtIndex:(NSUInteger) indexPath.row];

//    [[PSMapAtmoMapAnalytics sharedInstance] trackEventSystemFilterChange];
//    switch (indexPath.row)
//    {
//        case 0:
//            [[PSMapAtmoMapAnalytics sharedInstance] trackEventSystemFilterUseFilter];
//            break;
//        case 1:
//        {
//            if ([self.filter isEnabled])
//            {
//                [[PSMapAtmoMapAnalytics sharedInstance] trackEventSystemFilterUseDefaultFilter];
//            }
//            else
//            {
//                [[PSMapAtmoMapAnalytics sharedInstance] trackEventSystemFilterIgnoreFilter];
//            }
//        }
//            break;
//        case 2:
//            // DO NOTHING => CUSTOM
//            if ([self.filter isEnabled])
//            {
//                [[PSMapAtmoMapAnalytics sharedInstance] trackEventSystemFilterUseCustomFilter];
//                [[PSMapAtmoMapAnalytics sharedInstance] trackEventSystemFilterUseCustomFilterWithValue:self.filter.value];
//            }
//            break;
//        case 3:
//            // DO NOTHING => SLIDER
//            if ([self.filter isDefault]) // kein Slider wird angezeigt
//            {
//                if ([self.filter isEnabled])
//                {
//                    [[PSMapAtmoMapAnalytics sharedInstance] trackEventSystemFilterIgnoreFilter];
//                }
//            }
//            break;
//
//        case 4:
//        {
//            if ([self.filter isEnabled])
//            {
//                [[PSMapAtmoMapAnalytics sharedInstance] trackEventSystemFilterIgnoreFilter];
//            }
//        }
//            break;
//        default:
//            break;
//    }

}

@end