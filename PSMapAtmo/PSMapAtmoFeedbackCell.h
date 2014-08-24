//
//  PSMapAtmoFeedbackCell.h
//  MapAtmo
//
//  Created by Philip Schneider on 11.04.14.
//  Copyright (c) 2014 phschneider.net. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PSMapAtmoFeedbackCell : UITableViewCell

- (NSString*)message;
- (void) setDelegate:(id<UITextFieldDelegate>) delegate;
- (void) setText:(NSString*)text;
- (void) clear;

- (void) textFieldBecomeFirstResponder;
- (void) textFieldResignResponder;

@end
