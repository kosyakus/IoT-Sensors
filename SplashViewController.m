/*
 *******************************************************************************
 *
 * Copyright (C) 2016-2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "SplashViewController.h"

@interface SplashViewController ()

@property NSTimer *timer;

@end

@implementation SplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(showMain) userInfo:nil repeats:NO];

    UITapGestureRecognizer *detectClick = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClick)];
    [self.view addGestureRecognizer:detectClick];
}

- (void) onClick {
    if (self.timer && self.timer.isValid) {
        [self.timer invalidate];
        self.timer = nil;
    }
    [self showMain];
}

- (void) showMain {
    [self performSegueWithIdentifier:@"showMain" sender:self];
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
