/*
 *******************************************************************************
 *
 * Copyright (C) 2016-2018 Dialog Semiconductor.
 * This computer program includes Confidential, Proprietary Information
 * of Dialog Semiconductor. All Rights Reserved.
 *
 *******************************************************************************
 */

#import "MagnetoSensorViewController.h"

@implementation MagnetoSensorViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    self.sensor = self.device.magnetometer;
    chartAutoScale = FALSE;
    chartMin = 0;
    chartMax = 400;

    self.modelView.model = [GLModel modelWithContentsOfFile:@"arrow.obj"];
    self.modelView.blendColor = [UIColor colorWithRed:0.400 green:0.725 blue:0.929 alpha:1.000];
    self.modelView.modelTransform = CATransform3DMakeTranslation(0.0f, 0.0f, -1.0f);;

    self.imageViewCalibrated.hidden = YES;
    self.imageViewWarning.hidden = YES;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateMagnetometerState:) name:IotSensorsManagerMagnetometerState object:nil];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IotSensorsManagerMagnetometerState object:nil];
}

- (ChartDataEntryBuffer3D*) graphData3D {
    return self.device.magnetometerGraphData;
}

- (void) updateUI {
    if (!self.sensor.validValue)
        return;

    Magnetometer* sensor = (Magnetometer*) self.sensor;
    self.displayLabel.text = [NSString stringWithFormat:@"%d %@", (int) sensor.heading, [Magnetometer getCompassHeading:sensor.heading]];
    CATransform3D transform = CATransform3DMakeTranslation(0.f, 0.f, -1.f);
    transform = CATransform3DRotate(transform, -sensor.rad, 0.f, 0.f, 1.f);
    self.modelView.modelTransform = transform;
}

- (void)didUpdateMagnetometerState:(NSNotification*)notification {
    if (!self.device.isNewVersion)
        return;
    int sensorState = [notification.object[@"sensorState"] intValue];
    // Calibration status indication
    self.imageViewCalibrated.hidden = (sensorState & 0x04) == 0x04;
    // Calibration warning
    self.imageViewWarning.hidden = (sensorState & 0x01) == 0x01 && (sensorState & 0x02) == 0x02;
}

@end


@implementation MagnetometerGraphValueProcessor

#define MAGNETOMETER_GRAPH_HEIGHT 400

- (IotSensorValue*) process:(IotSensorValue*)v {
    return [[IotSensorValue3D alloc] initWithX:v.x + MAGNETOMETER_GRAPH_HEIGHT / 2
                                             Y:v.y + MAGNETOMETER_GRAPH_HEIGHT / 2
                                             Z:v.z + MAGNETOMETER_GRAPH_HEIGHT / 2];
}

@end
