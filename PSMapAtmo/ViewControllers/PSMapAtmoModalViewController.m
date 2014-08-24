//
// Created by Philip Schneider on 18.01.14.
// Copyright (c) 2014 phschneider.net. All rights reserved.
//

#import "PSMapAtmoModalViewController.h"


@implementation PSMapAtmoModalViewController

- (id) init
{
    DLogFuncName();
    self = [super init];
    if (self)
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"done" style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonTouched:)];
    }
    return self;
}

- (void) doneButtonTouched:(id)sender
{
    DLogFuncName();
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end