/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "ProximitySensorViewController.h"
#import "BluetoothDefines.h"

static UIColor* PROXIMITY_COLOR_ON;
static UIColor* PROXIMITY_COLOR_OFF;

@implementation ProximitySensorViewController

+ (void)initialize {
    if (self != [ProximitySensorViewController class])
        return;

    PROXIMITY_COLOR_ON = UIColorWithRGB(0x42A5F5);
    PROXIMITY_COLOR_OFF = UIColorWithRGB(0xCFD8DC);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sensor = self.device.proximitySensor;
    self.imageView.tintColor = UIColorWithRGB(0xCFD8DC);
    self.batteryWarningImage.hidden = YES;
    self.batteryWarningImage.tintColor = UIColorWithRGB(0xB71C1C);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.imageViewHeightConstraint.constant = self.view.frame.size.height * 0.45f;
}

- (void) updateUI {
    if (!self.sensor.validValue)
        return;

    ProximitySensor* sensor = (ProximitySensor*) self.sensor;
    BOOL objectNearby = sensor.objectNearby;
    self.imageView.tintColor = objectNearby ? PROXIMITY_COLOR_ON : PROXIMITY_COLOR_OFF;
    self.displayLabel.text = objectNearby ? @"ON" : @"OFF";
    self.batteryWarningImage.hidden = !sensor.lowVoltage;
}

- (void) updateChart {
}

@end
