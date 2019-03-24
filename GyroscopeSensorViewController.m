/*
 *******************************************************************************
 *
 * Copyright (C) 2016-2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "GyroscopeSensorViewController.h"

@implementation GyroscopeSensorViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    self.sensor = self.device.gyroscope;
    chartAutoScale = FALSE;
    chartMin = 0;
    chartMax = 360;

    self.modelView.model = [GLModel modelWithContentsOfFile:@"gyro.obj"];
    self.modelView.blendColor = [UIColor colorWithRed:0.400 green:0.725 blue:0.929 alpha:1.000];
    self.modelView.modelTransform = CATransform3DMakeTranslation(0.0f, 0.0f, -2.0f);

    self.gyroscopeIntegrationLabel.text = [NSString stringWithUTF8String:"\xce\xb4\xce\xb8"]; // delta theta
    self.gyroscopeIntegrationLabel.hidden = YES;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onConfigurationReport:) name:IotSensorsManagerConfigurationReport object:nil];
    if (self.device.features.hasIntegrationEngine)
        self.gyroscopeIntegrationLabel.hidden = !self.device.integrationEngine;
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IotSensorsManagerConfigurationReport object:nil];
}

- (void) onConfigurationReport:(NSNotification*)notification {
    if (self.device.features.hasIntegrationEngine)
        self.gyroscopeIntegrationLabel.hidden = !self.device.integrationEngine;
}

- (ChartDataEntryBuffer3D*) graphData3D {
    return self.device.gyroscopeGraphData;
}

- (void) updateUI {
    if (!self.sensor.validValue)
        return;

    IotSensorValue* value = [self.sensor performSelector:@selector(accumulatedRotation)];
    CATransform3D transform = CATransform3DMakeTranslation(0.0f, 0.0f, -2.0f);
    transform = CATransform3DRotate(transform, value.x * M_PI / 180.f, 1.f, 0.f, 0.f);
    transform = CATransform3DRotate(transform, value.y * M_PI / 180.f, 0.f, 1.f, 0.f);
    transform = CATransform3DRotate(transform, value.z * M_PI / 180.f, 0.f, 0.f, 1.f);
    self.modelView.modelTransform = transform;
}

@end


@implementation GyroscopeGraphValueProcessor

#define GYROSCOPE_GRAPH_HEIGHT 360

- (IotSensorValue*) process:(IotSensorValue*)v {
    return [[IotSensorValue3D alloc] initWithX:v.x + GYROSCOPE_GRAPH_HEIGHT / 2
                                             Y:v.y + GYROSCOPE_GRAPH_HEIGHT / 2
                                             Z:v.z + GYROSCOPE_GRAPH_HEIGHT / 2];
}

@end
