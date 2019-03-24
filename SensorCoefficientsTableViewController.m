/*
 *******************************************************************************
 *
 * Copyright (C) 2016-2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "SensorCoefficientsTableViewController.h"

@implementation SensorCoefficientsTableViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    self.manager = self.device.sensorFusionSettingsManager;
}

- (void) updateUI {
    [super updateUI];
    [self setItemEnabled:self.buttonStoreToNV enabled:itemsEnabled];
    [self setItemEnabled:self.buttonResetCurrentSet enabled:itemsEnabled];
}

- (IBAction) onStoreToNV:(id)sender {
    [self.device.manager sendCalStoreNvCommand];
    [self showMessage:@"Settings stored"];
}

- (IBAction) onResetCurrentSet:(id)sender {
    [self.device.manager sendCalResetCommand];
    [self.manager readConfiguration];
    [self showMessage:@"Settings reset"];
}

@end
