/*
 *******************************************************************************
 *
 * Copyright (C) 2016-2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "TemperatureSensorViewController.h"

static NSString* const UNIT_CELSIUS = @" °C";
static NSString* const UNIT_FAHRENHEIT = @" °F";

@implementation TemperatureSensorViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    self.sensor = self.device.temperatureSensor;
    chartAutoScale = FALSE;
    chartMin = 10;
    chartMax = 50;

    self.fullLevelImage = [UIImage imageNamed:@"icon-temp-filled"];
    self.imageLevel = 0;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.imageViewHeightConstraint.constant = self.view.frame.size.height * 0.4f;
}

- (ChartDataEntryBuffer*) graphData {
    return self.device.temperatureGraphData;
}

- (void) updateUI {
    if (!self.sensor.validValue)
        return;

    TemperatureSensor* sensor = (TemperatureSensor*) self.sensor;
    self.displayLabel.text = [NSString stringWithFormat:@"%.1f%@", sensor.displayValue, sensor.displayUnit == TEMPERATURE_UNIT_CELSIUS ? UNIT_CELSIUS : UNIT_FAHRENHEIT];
    int value = (int) [sensor getTemperature:TEMPERATURE_UNIT_CELSIUS];
    self.imageLevel = value * 2; // [0-50] degrees to [0-100] percent
}

@end
