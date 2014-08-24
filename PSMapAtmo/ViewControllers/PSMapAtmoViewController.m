//
//  PSNetAtmoViewController.m
//  PSNetAtmo
//
//  Created by Philip Schneider on 14.12.13.
//  Copyright (c) 2013 phschneider.net. All rights reserved.
//

#import "PSMapAtmoViewController.h"

@interface PSMapAtmoViewController ()

@end

@implementation PSMapAtmoViewController


#pragma mark - ModalViews
// Bugfix da FormSheet ModalView keine Keyboard dimissen kann
- (void)presentModalViewControllerInFormSheetSizeWithoutKeyboardDismissBug:(UIViewController*)viewController
{
    viewController.modalPresentationStyle = UIModalPresentationPageSheet;
    viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self presentViewController: viewController animated:YES completion:nil];
    
    viewController.view.superview.autoresizingMask =
    UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleBottomMargin;
    viewController.view.superview.frame = CGRectMake(viewController.view.superview.frame.origin.x,
                                                     viewController.view.superview.frame.origin.y,
                                                     540.0f,
                                                     529.0f);
    
    //    CGRect bounds = [self.view bounds];
    //    CGPoint centerPoint = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    
    viewController.view.superview.center = self.view.center;
}


#pragma mark - Rotation
-(BOOL)shouldAutorotate
{
    DLogFuncName();
    return YES;
}


-(NSUInteger)supportedInterfaceOrientations
{
    DLogFuncName();
    return UIInterfaceOrientationMaskLandscape;
}


- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    DLogFuncName();
    return UIInterfaceOrientationLandscapeRight;
}


// iOS 5 - Start Orientation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (UIInterfaceOrientationIsLandscape(interfaceOrientation));
}

@end
