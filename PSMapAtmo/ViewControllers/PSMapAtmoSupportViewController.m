//
// Created by Philip Schneider on 18.01.14.
// Copyright (c) 2014 phschneider.net. All rights reserved.
//

#import "PSMapAtmoSupportViewController.h"

@interface PSMapAtmoSupportViewController ()

@property (nonatomic) UITableView * tableView;
@property (nonatomic) NSArray * sectionTitles;

@end


@implementation PSMapAtmoSupportViewController

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

        self.sectionTitles = @[ @"Your name", @"Your email", @"Subject", @"Message" ];

    }
    return self;
}


- (void) doneButtonTouched:(id)sender
{
    DLogFuncName();
    #warning todo - check if we should submit?
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - TableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLogFuncName();
    NSString * cellIdentifier = @"SettingsCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    NSString * key = [self.sectionTitles objectAtIndex:indexPath.section];
    
//    cell.textLabel.text = [[section objectAtIndex:indexPath.row] objectForKey:@"title"];
    if ( [[key lowercaseString] isEqualToString:@"subject"])
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    return cell;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    DLogFuncName();
    return [self.sectionTitles count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    DLogFuncName();
    return 1;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    DLogFuncName();
    return [self.sectionTitles objectAtIndex:section];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLogFuncName();
    if (indexPath.section == [self.sectionTitles count] - 1)
    {
        return 132.0;
    }

    return 44.0;
}


#pragma mark - TableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLogFuncName();

    [tableView deselectRowAtIndexPath:indexPath animated:NO];


}
@end