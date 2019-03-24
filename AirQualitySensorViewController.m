/*
 *******************************************************************************
 *
 * Copyright (C) 2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "AirQualitySensorViewController.h"
#import "BluetoothDefines.h"

@implementation AirQualitySensorViewController {
    CGFloat accuracyLabelHeightOrg;
    CGFloat accuracyLabelTopMarginOrg;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sensor = self.device.airQualitySensor;
    chartAutoScale = false;
    chartMin = 0;

    self.imageView.tintColor = UIColorWithRGB(0xCFD8DC);
    accuracyLabelHeightOrg = self.accuracyLabelHeight.constant;
    accuracyLabelTopMarginOrg = self.accuracyLabelTopMargin.constant;
    self.accuracyLabelHeight.constant = 0;
    self.accuracyLabelTopMargin.constant = 0;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.imageViewHeightConstraint.constant = self.view.frame.size.height * 0.45f;
}

- (ChartDataEntryBuffer*) graphData {
    return self.device.airQualityGraphData;
}

- (void) updateUI {
    if (!self.sensor.validValue)
        return;

    AirQualitySensor* sensor = (AirQualitySensor*) self.sensor;

    int index = sensor.airQualityIndex;
    if (index == AIR_QUALITY_INDEX_UNKNOWN)
        return;
    self.displayLabel.text = AIR_QUALITY_TEXT[index];
    self.imageView.tintColor = UIColorWithRGB(AIR_QUALITY_COLOR[index]);

    int accuracy = sensor.accuracy;
    self.accuracyLabelHeight.constant = accuracyLabelHeightOrg;
    self.accuracyLabelTopMargin.constant = accuracyLabelTopMarginOrg;
    self.accuracyLabel.text = AIR_QUALITY_ACCURACY_TEXT[accuracy];
}

- (void) updateChartMinMax:(LineChartData*)data {
    chartMax = ((int) data.yMax / 50 + 1) * 50;
}

@end
