/*
 *******************************************************************************
 *
 * Copyright (C) 2016-2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "AccelerometerSensorViewController.h"

@implementation AccelerometerSensorViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    self.sensor = self.device.accelerometer;
    chartAutoScale = FALSE;
    chartMin = 0;
    chartMax = 4;

    self.modelView.model = [GLModel modelWithContentsOfFile:@"cube.obj"];
    self.modelView.blendColor = [UIColor colorWithRed:0.400 green:0.725 blue:0.929 alpha:1.000];
    self.modelView.modelTransform = CATransform3DMakeTranslation(0.0f, 0.0f, -2.0f);

    self.accelerometerIntegrationLabel.text = [NSString stringWithUTF8String:"\xce\xb4V"]; // delta V
    self.accelerometerIntegrationLabel.hidden = YES;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onConfigurationReport:) name:IotSensorsManagerConfigurationReport object:nil];
    if (self.device.features.hasIntegrationEngine)
        self.accelerometerIntegrationLabel.hidden = !self.device.integrationEngine;
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IotSensorsManagerConfigurationReport object:nil];
}

- (void) onConfigurationReport:(NSNotification*)notification {
    if (self.device.features.hasIntegrationEngine)
        self.accelerometerIntegrationLabel.hidden = !self.device.integrationEngine;
}

- (ChartDataEntryBuffer3D*) graphData3D {
    return self.device.accelerometerGraphData;
}

- (void) updateUI {
    if (!self.sensor.validValue)
        return;

    IotSensorValue* value = !self.device.integrationEngine ? self.sensor.value : [(AccelerometerIntegration*)self.sensor accelerationInG];
    self.modelView.modelTransform = CATransform3DMakeTranslation(value.x / 2.f, value.z / 2.f, value.y / 2.f - 2.f);
}

@end


@implementation AccelerometerGraphValueProcessor

#define ACCELEROMETER_GRAPH_HEIGHT 4

- (IotSensorValue*) process:(IotSensorValue*)v {
    return [[IotSensorValue3D alloc] initWithX:v.x + ACCELEROMETER_GRAPH_HEIGHT / 2
                                             Y:v.y + ACCELEROMETER_GRAPH_HEIGHT / 2
                                             Z:v.z + ACCELEROMETER_GRAPH_HEIGHT / 2];
}

@end
