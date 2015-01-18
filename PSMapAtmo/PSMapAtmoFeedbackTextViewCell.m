//
//  ToProwlMessageCell.m
//  ToProwl
//
//  Created by Philip Schneider on 02.11.13.
//  Copyright (c) 2013 PhSchneider.net. All rights reserved.
//

#import "PSMapAtmoFeedbackTextView.h"
#import "PSMapAtmoFeedbackTextViewCell.h"

@interface PSMapAtmoFeedbackTextViewCell()
@property (nonatomic, strong)  PSMapAtmoFeedbackTextView * textView;
@end

@implementation PSMapAtmoFeedbackTextViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    DLogFuncName();
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.textView = [[PSMapAtmoFeedbackTextView alloc] initWithFrame:self.bounds];
        self.textView.userInteractionEnabled = NO;

        [self.contentView addSubview: self.textView];
        [self.contentView bringSubviewToFront:self.textView];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if ([self respondsToSelector:@selector(separatorInset)])
        {
            self.textView.frame = CGRectInset(
                                               self.contentView.frame,
                                               [self separatorInset].left,
                                               [self separatorInset].top + 10
                                               );
        }
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    DLogFuncName();
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void) layoutSubviews
{
    DLogFuncName();
    [super layoutSubviews];
    
    if ([self respondsToSelector:@selector(separatorInset)])
    {
        self.textView.frame = CGRectInset(
                                           self.contentView.frame,
                                           [self separatorInset].left,
                                           [self separatorInset].top + 10
                                           );
    }
    
    [self.contentView bringSubviewToFront:self.textView];
}


- (NSString*)message
{
    DLogFuncName();
    return self.textView.text;
}


- (void) setDelegate:(id<UITextViewDelegate>) delegate
{
    DLogFuncName();
    if (delegate == nil)
    {
        [self.textView resignFirstResponder];
    }
    else
    {
        self.textView.delegate = delegate;
    }
}


- (void) setText:(NSString*)text
{
    DLogFuncName();
    self.textView.text = text;
}


- (void) clear
{
    DLogFuncName();
    self.textView.text = @"";
    self.textLabel.text = @"";
    self.detailTextLabel.text = @"";
}


- (void) textFieldBecomeFirstResponder
{
    DLogFuncName();
    self.textView.userInteractionEnabled = YES;
    [self.textView becomeFirstResponder];
}


- (void) textFieldResignResponder
{
    DLogFuncName();
    self.textView.userInteractionEnabled = NO;
    [self.textView resignFirstResponder];
}



@end
