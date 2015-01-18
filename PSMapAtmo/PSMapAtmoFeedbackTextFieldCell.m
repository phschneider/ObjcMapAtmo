//
//  PSMapAtmoFeedbackTextFieldCell.m
//  MapAtmo
//
//  Created by Philip Schneider on 11.04.14.
//  Copyright (c) 2014 phschneider.net. All rights reserved.
//

#import "PSMapAtmoFeedbackTextField.h"
#import "PSMapAtmoFeedbackTextFieldCell.h"

@interface PSMapAtmoFeedbackTextFieldCell()
@property (nonatomic, strong)  PSMapAtmoFeedbackTextField * textField;
@end

@implementation PSMapAtmoFeedbackTextFieldCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    DLogFuncName();
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.textField = [[PSMapAtmoFeedbackTextField alloc] initWithFrame:self.bounds];
        self.textField.userInteractionEnabled = NO;
        self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.textField.backgroundColor = [UIColor redColor];
        [self.contentView addSubview: self.textField];
        [self.contentView bringSubviewToFront:self.textField];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if ([self respondsToSelector:@selector(separatorInset)])
        {
            self.textField.frame = CGRectInset(
                                              self.contentView.frame,
                                              [self separatorInset].left,
                                              [self separatorInset].top + 10
                                              );
        }
    }
    return self;
}


- (void) layoutSubviews
{
    DLogFuncName();
    [super layoutSubviews];
    
    if ([self respondsToSelector:@selector(separatorInset)])
    {
        self.textField.frame = CGRectInset(
                                          self.contentView.frame,
                                          [self separatorInset].left,
                                          [self separatorInset].top + 10
                                          );
    }
    
    [self.contentView bringSubviewToFront:self.textField];
}


- (NSString*)message
{
    DLogFuncName();
    return self.textField.text;
}


- (void) setDelegate:(id<UITextFieldDelegate>) delegate
{
    DLogFuncName();
    if (delegate == nil)
    {
        [self.textField resignFirstResponder];
    }
    else
    {
        self.textField.delegate = delegate;
    }
}


- (void) setText:(NSString*)text
{
    DLogFuncName();
    self.textField.text = text;
}


- (void) clear
{
    DLogFuncName();
    self.textField.text = @"";
    self.textLabel.text = @"";
    self.detailTextLabel.text = @"";
}


- (void) textFieldBecomeFirstResponder
{
    DLogFuncName();
    self.textField.userInteractionEnabled = YES;
    [self.textField becomeFirstResponder];
}


- (void) textFieldResignResponder
{
    DLogFuncName();
    [self.textField resignFirstResponder];
    self.textField.userInteractionEnabled = NO;
}
@end
