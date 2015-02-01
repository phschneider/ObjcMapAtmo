//
//  PSNetAtmoBetaViewController.m
//  PSNetAtmo
//
//  Created by Philip Schneider on 19.01.14.
//  Copyright (c) 2014 phschneider.net. All rights reserved.
//

#import "PSMapAtmoBetaFeedbackViewController.h"
#import "PSMapAtmoFeedbackCell.h"
#import "PSMapAtmoFeedbackTextViewCell.h"
#import "PSMapAtmoFeedbackTextFieldCell.h"
#import "PSMapAtmoUserDefaults.h"
#import "SVProgressHUD.h"


#ifndef CONFIGURATION_AppStore
    #import "TestFlight.h"
#endif


@interface PSMapAtmoBetaFeedbackViewController ()

@property (nonatomic) NSMutableArray *cellArray;
@property (nonatomic) PSMapAtmoFeedbackCell *editingCell;
@property (nonatomic) UITableView * tableView;
@property (nonatomic) NSIndexPath * selectedIndexPath;
@property (nonatomic) UIEdgeInsets tableViewEdgeInsets;
@property (nonatomic, strong)  UIButton * clearButton;
@property (nonatomic, strong)  UIButton * sendButton;
@end

@implementation PSMapAtmoBetaFeedbackViewController

- (id) init
{
    DLogFuncName();
    self = [super init];
    if (self)
    {
        self.title = [NSLocalizedString(@"feedback",nil) capitalizedString];
        
        self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:self.tableView];
        
        self.cellArray = [[NSMutableArray alloc] initWithCapacity:3];
        self.editingCell = nil;
    }
    return self;
}


- (void)viewDidAppear:(BOOL)animated
{
    DLogFuncName();
    [super viewDidAppear:animated];
#ifndef CONFIGURATION_AppStore
    [TestFlight passCheckpoint:@"settings-beta"];
#endif

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}


- (void) viewWillDisappear:(BOOL)animated
{
    DLogFuncName();
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    DLogFuncName();
    return 3;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    DLogFuncName();
    return 1;
}


- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    DLogFuncName();
    switch (section) {
        case 0:
            return [NSString stringWithFormat:@"%@",[NSLocalizedString(@"name", nil) capitalizedString]];
            
        case 1:
            return [NSString stringWithFormat:@"%@",[NSLocalizedString(@"e-mail", nil) capitalizedString]];
            
        case 2:
            return [NSString stringWithFormat:@"%@",[NSLocalizedString(@"message", nil) capitalizedString]];
            
        default:
            return @"";
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    DLogFuncName();
    if (section == 2)
    {
        return 100;
    }
    return 0;
}


- (UIView*) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    DLogFuncName();
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0,tableView.bounds.size.width,200)];
    if (section == 2)
    {
        if (!self.clearButton)
        {
            self.clearButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            self.clearButton.frame = CGRectMake(20,40, (CGFloat) (ceil((tableView.bounds.size.width-40)/2)-10), 40);
            [self.clearButton setTitle:[NSLocalizedString(@"clear", nil) capitalizedString] forState:UIControlStateNormal];
            [self.clearButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            [self.clearButton addTarget:self action:@selector(clearButtonTouched) forControlEvents:UIControlEventTouchUpInside];
            self.clearButton.backgroundColor = [UIColor redColor];
        }
        if (![view.subviews containsObject:self.clearButton])
        {
            [view addSubview:self.clearButton];
        }
        
        if (!self.sendButton)
        {
            self.sendButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            self.sendButton.frame = CGRectMake((CGFloat) (20+ceil((tableView.bounds.size.width-40)/2)+10),40, (CGFloat) (ceil((tableView.bounds.size.width-40)/2)-10), 40);
            [self.sendButton setTitle:[NSLocalizedString(@"send", nil) capitalizedString] forState:UIControlStateNormal];
            [self.sendButton addTarget:self action:@selector(sendButtonTouched) forControlEvents:UIControlEventTouchUpInside];
            [self.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            self.sendButton.backgroundColor = [UIColor greenColor];
            
        }
        if (![view.subviews containsObject:self.sendButton])
        {
            [view addSubview:self.sendButton];
        }
        view.backgroundColor = [UIColor clearColor];
        
        [self checkButtons];
        
        return view;
    }
    return nil;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLogFuncName();
    if (indexPath.section == 2)
    {
        return 200;
    }
    return 44;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLogFuncName();
    
    PSMapAtmoFeedbackCell *cell = nil;
    switch (indexPath.section) {
        case 0:
            {
                cell = [[PSMapAtmoFeedbackTextFieldCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"TextFieldCell"];
                [(PSMapAtmoFeedbackTextFieldCell*)cell setText:[[PSMapAtmoUserDefaults sharedInstance] betaName]];
            }
            break;
        
        case 1:
            {
                cell = [[PSMapAtmoFeedbackTextFieldCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"TextFieldCell"];
                [(PSMapAtmoFeedbackTextFieldCell*)cell setText:[[PSMapAtmoUserDefaults sharedInstance] betaMail]];
            }
            break;
           
        case 2:
            {
                cell = [[PSMapAtmoFeedbackTextViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"TextViewCell"];
                [(PSMapAtmoFeedbackTextViewCell*)cell setText:@""];
            }
            break;

        default:
            break;
    }
        

    if (cell && self.cellArray)
    {
        if ([self.cellArray count] < indexPath.section + 1 || !self.cellArray[(NSUInteger) indexPath.section])
        {
            [self.cellArray insertObject:cell atIndex:(NSUInteger) indexPath.section];
        }
        else
        {
            self.cellArray[(NSUInteger) indexPath.section] = cell;
        }
    }
    return cell;
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLogFuncName();
    
    if (self.editingCell)
    {
        [self.editingCell textFieldResignResponder];
        [self.editingCell setDelegate:nil];
    }
    
    PSMapAtmoFeedbackCell *cell = self.cellArray[(NSUInteger) indexPath.section];
    self.editingCell = cell;
    self.selectedIndexPath = indexPath;
    
    [self.editingCell setDelegate:self];
    [self.editingCell textFieldBecomeFirstResponder];

    if (indexPath.section == 2)
    {
        self.tableViewEdgeInsets = self.tableView.contentInset;
        [UIView animateWithDuration:.3
                              delay:0.0
                            options: UIViewAnimationCurveEaseOut
                         animations:^
         {
             [[self tableView] setContentInset:UIEdgeInsetsMake(0,0, 240, 0)];
             [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
         }
                         completion:^(BOOL finished)
         {

         }
         ];
    }
}


- (void) setSelectedIndexPath:(NSIndexPath *)selectedIndexPath
{
    DLogFuncName();
    _selectedIndexPath = selectedIndexPath;
}


#pragma mark - UITextFieldDelegate
- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    DLogFuncName();
    return YES;
}

- (void) textViewDidBeginEditing:(UITextView *)textView
{
    DLogFuncName();
    [self checkButtons];
}


- (BOOL) textViewShouldEndEditing:(UITextView *)textView
{
    DLogFuncName();
    [self checkButtons];
    return YES;
}


- (void) textViewDidEndEditing:(UITextView *)textView
{
    DLogFuncName();
    [self checkButtons];
}


- (void)textViewDidChange:(UITextView *)textView
{
    DLogFuncName();
    [self checkButtons];
}


- (void)textViewDidChangeSelection:(UITextView *)textView
{
    DLogFuncName();
    [self checkButtons];
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    DLogFuncName();
    [self checkButtons];
    return YES;
}


#pragma mark - TextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    DLogFuncName();
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    DLogFuncName();
    
}


- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    DLogFuncName();
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    DLogFuncName();
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    DLogFuncName();
    if (self.selectedIndexPath.section == 1)
    {
        return ([string rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].location == NSNotFound);
    }
    else
    {
        return YES;
    }
}


- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    DLogFuncName();
    return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    DLogFuncName();
    return YES;
}


#pragma mark -
- (void) keyboardDidShow:(NSNotification*)notification
{
    DLogFuncName();

}


- (void) keyboardDidHide:(NSNotification*)notification
{
    DLogFuncName();
    
    if (self.selectedIndexPath.section == 2)
    {
        [UIView animateWithDuration:.3
                              delay:0.0
                            options: UIViewAnimationCurveEaseOut
                         animations:^
         {
             [[self tableView] setContentInset:UIEdgeInsetsMake(40,0, 0, 0)];
         }
                         completion:^(BOOL finished)
         {
             
         }
         ];

    }
}


#pragma mark - Button
- (void) clearButtonTouched
{
    DLogFuncName();
#ifndef CONFIGURATION_AppStore
    [TestFlight passCheckpoint:@"settings-beta-clear"];
#endif
    #warning todo - anlytics
    
    [self clear];
}


- (void) clear
{
    DLogFuncName();
    if ([self.cellArray count] == 3)
    {
        [(PSMapAtmoFeedbackTextViewCell*) self.cellArray[2] clear];
    }
    
    [self.tableView reloadData];
}


- (void) sendButtonTouched
{
    DLogFuncName();
    // Resign First Responder
    
    NSMutableString *feedBackString = [[NSMutableString alloc] init];
    for (PSMapAtmoFeedbackCell *cell in self.cellArray)
    {
        NSIndexPath *path = [self.tableView indexPathForCell:cell];
        if (path.section == 0)
        {
            [[PSMapAtmoUserDefaults sharedInstance] setBetaName:[cell message]];
        }
        else if ( path.section == 1)
        {
            [[PSMapAtmoUserDefaults sharedInstance] setBetaMail:[cell message]];
        }
        [feedBackString appendFormat:@"%@\n\n",[cell message]];
        [cell textFieldResignResponder];
    }

#warning todo - anlytics
#ifndef CONFIGURATION_AppStore

    [TestFlight submitFeedback:feedBackString];
    [TestFlight passCheckpoint:@"settings-beta-send"];
    
#endif
    [SVProgressHUD showSuccessWithStatus:@"Message send"];
    
    [self clear];
}


- (void) enableButton:(UIButton*)button enabled:(BOOL) enabled
{
    button.alpha = (CGFloat) ((enabled) ? 1 : 0.1);
    button.enabled = enabled;
}


- (void) checkButtons
{
    DLogFuncName();
    BOOL enableClearButton = YES;
    
    for (PSMapAtmoFeedbackCell *cell in self.cellArray)
    {
        if ([cell.message length] < 2)
        {
            enableClearButton = NO;
        }
    }
    
    [self enableButton:self.clearButton enabled:enableClearButton];
    [self enableButton:self.sendButton enabled:enableClearButton];
}


@end
