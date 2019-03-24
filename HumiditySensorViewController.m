/*
 *******************************************************************************
 *
 * Copyright (C) 2016-2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "HumiditySensorViewController.h"

static NSString* const UNIT = @"%";

@implementation HumiditySensorViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    self.sensor = self.device.humiditySensor;
    chartAutoScale = FALSE;
    chartMin = 0;
    chartMax = 100;

    self.fullLevelImage = [UIImage imageNamed:@"icon-humid-filled"];
    self.imageLevel = 0;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.imageViewHeightConstraint.constant = self.view.frame.size.height * 0.4f;
}

- (ChartDataEntryBuffer*) graphData {
    return self.device.humidityGraphData;
}

- (void) updateUI {
    if (!self.sensor.validValue)
        return;

    int value = (int) self.sensor.displayValue;
    self.displayLabel.text = [NSString stringWithFormat:@"%d%@", value, UNIT];
    self.imageLevel = value;
}

@end
