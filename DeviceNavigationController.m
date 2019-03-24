/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "DeviceNavigationController.h"

@implementation DeviceNavigationController

- (void) viewDidLoad {
    [super viewDidLoad];
    self.device = BluetoothManager.instance.device;

    // Set initial sensor view
    if (self.device.sensorMenuLayout) {
        UIViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:self.device.sensorMenuLayout[0][@"view"]];
        [self setViewControllers:@[vc] animated:NO];
    }
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
