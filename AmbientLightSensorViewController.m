/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "AmbientLightSensorViewController.h"
#import "BluetoothDefines.h"

static NSString* const UNIT = @" lux";

@implementation AmbientLightSensorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sensor = self.device.ambientLightSensor;
    chartAutoScale = false;
    chartMin = 0;

    self.imageView.tintColor = UIColorWithRGB(0xCFD8DC);
    self.batteryWarningImage.hidden = YES;
    self.batteryWarningImage.tintColor = UIColorWithRGB(0xB71C1C);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.imageViewHeightConstraint.constant = self.view.frame.size.height * 0.45f;
}

- (ChartDataEntryBuffer*) graphData {
    return self.device.ambientLightGraphData;
}

- (void) updateUI {
    if (!self.sensor.validValue)
        return;

    AmbientLightSensor* sensor = (AmbientLightSensor*) self.sensor;
    int value = (int) sensor.displayValue;
    self.displayLabel.text = [NSString stringWithFormat:@"%d%@", value, UNIT];

    int adjust = MIN(value * 128 / 5000, 128);
    self.imageView.tintColor = UIColorWithRGB(0xCFD8DC - 0x010000 * adjust - 0x000100 * (adjust / 2));
    self.batteryWarningImage.hidden = !sensor.lowVoltage;
}

- (void) updateChartMinMax:(LineChartData*)data {
    chartMax = ((int) data.yMax / 1000 + 1) * 1000;
}

@end
