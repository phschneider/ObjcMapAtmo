//
//  PSNetAtmoSettingsViewController.h
//  PSNetAtmo
//
//  Created by Philip Schneider on 14.12.13.
//  Copyright (c) 2013 phschneider.net. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

#import "PSMapAtmoViewController.h"
#import "PSMapAtmoModalViewController.h"

@interface PSMapAtmoSettingsViewController : PSMapAtmoModalViewController <UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate>

@end
