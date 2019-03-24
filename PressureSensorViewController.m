/*
 *******************************************************************************
 *
 * Copyright (C) 2016-2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "PressureSensorViewController.h"

static NSString* const UNIT = @" hPa";

@implementation PressureSensorViewController {
    float previousValue;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    self.sensor = self.device.pressureSensor;
    chartAutoScale = FALSE;
    previousValue = 0;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.imageViewHeightConstraint.constant = self.view.frame.size.height * 0.4f;
}

- (ChartDataEntryBuffer*) graphData {
    return self.device.pressureGraphData;
}

- (void) updateUI {
    if (!self.sensor.validValue)
        return;

    float value = self.sensor.displayValue;
    self.displayLabel.text = [NSString stringWithFormat:@"%.1f%@", value / 100.f, UNIT];

    if (previousValue != 0) {
        float difference = MAX(-20, MIN(20, previousValue - value));
        self.imageViewVerticalAlignConstraint.constant = difference / 5;
        [self.view setNeedsUpdateConstraints];
        [UIView animateWithDuration:1.0f animations:^{
            [self.view layoutIfNeeded];
        }];
    }
    previousValue = value;
}

- (void) updateChartMinMax:(LineChartData*)data {
    chartMin = (float) data.yMin / 1.001f;
    chartMax = (float) data.yMax * 1.001f;
}

@end
